//
//  P2PTransferFundsViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 6/9/21.
//

import Foundation
import AptoSDK

class P2PTransferFundsViewController: AptoViewController, UITextFieldDelegate {
    private let viewModel: P2PTransferFundsViewModel
    private(set) lazy var transferFundsView = P2PTransferFundsView(uiconfig: self.uiConfiguration)
    private let keyboardWatcher = KeyboardWatcher()
    private var transferModel: P2PTransferModel
    private var amountLimit: Double?
    private var currencySymbol: String?
    private var currency: String?
    private var sourceId: String?
    var onTransferCompletion: ((P2PTransferResponse) -> Void)?

    init(uiConfiguration: UIConfig, viewModel: P2PTransferFundsViewModel, transferModel: P2PTransferModel) {
        self.viewModel = viewModel
        self.transferModel = transferModel
        super.init(uiConfiguration: uiConfiguration)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        self.view = transferFundsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = uiConfiguration.uiSecondaryColor
        setupBinding()
        watchKeyboard()
        let action: (() -> Void) = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        if let mappedModel = P2PTransferModelMapper.mapToCardConfig(transferModel, action: action) {
            transferFundsView.configure(with: mappedModel)
        }
        viewModel.fetchFundingSource()
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.hidesBackButton = true
        let closeImageIcon = UIImage.imageFromPodBundle("top_close_default")
        let closeButton = UIBarButtonItem(image: closeImageIcon, style: .plain, target: self, action: #selector(didTapOnClose))
        navigationItem.leftBarButtonItem = closeButton
        self.title = "p2p_transfer.transfer_funds.screen.title".podLocalized()
    }

    // MARK: Private methods
    private func setupBinding() {
        transferFundsView.amountTextField.delegate = self
        transferFundsView.actionButton.addTarget(self, action: #selector(didTapOnActionButton), for: .touchUpInside)
        
        viewModel.onBalanceFetched = { [weak self] fundingSource in
            guard let balance = fundingSource.balance,
                  let amount = balance.amount.value else { return }
            self?.amountLimit = amount
            self?.currencySymbol = balance.currencySymbol
            self?.currency = balance.currency.value
            self?.transferFundsView.amountTextField.becomeFirstResponder()
            self?.sourceId = fundingSource.fundingSourceId
        }
        
        viewModel.onTransferDone = { [weak self] response in
            if response.status == .failed {
                self?.view.endEditing(true)
                self?.transferFundsView.showActionButton(false)
                self?.show(message: "p2p_transfer.transfer_funds.error.description".podLocalized(),
                           title: "p2p_transfer.transfer_funds.error.title".podLocalized())
                return
            }
            self?.onTransferCompletion?(response)
        }
        
        viewModel.onLoadingStateChange = { [weak self] loading in
            if loading {
                self?.showLoadingView()
                self?.transferFundsView.actionButton.isEnabled = false
            } else {
                self?.hideLoadingView()
                self?.transferFundsView.actionButton.isEnabled = true
            }
        }
        
        viewModel.onErrorRequest = { [weak self] error in
            self?.view.endEditing(true)
            self?.transferFundsView.showActionButton(false)
            self?.transferFundsView.updateViewContraints(to: 6)
            self?.show(message: "p2p_transfer.transfer_funds.error.description".podLocalized(),
                       title: "p2p_transfer.transfer_funds.error.title".podLocalized(), onMessageDismissed: { [weak self] in self?.resetFundsScreen() } )
        }
    }
    
    private func watchKeyboard() {
        keyboardWatcher.startWatching(onKeyboardShown: { [weak self] size in
            self?.transferFundsView.updateViewContraints(to: size.height + 10)
        })
    }
    
    private func isValidAmount(_ value: String) -> Bool {
        guard let _ = Double(value) else { return false }
        return true
    }
    
    private func amountExceedsLimit(_ amount: String, _ amountLimit: Double?) -> Bool {
        guard let currentAmount = Double(amount),
              let amountLimit = amountLimit,
           currentAmount > amountLimit else { return false }
        return true
    }
    
    private func decimalsBelow(limit: Int, amount: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "\\..{\(limit),}", options: [])
        let matches = regex.matches(in: amount, options:[], range:NSMakeRange(0, amount.count))
        return matches.count == 0
    }

    private func resetFundsScreen() {
        transferFundsView.amountTextField.becomeFirstResponder()
        if let text = transferFundsView.amountTextField.text {
            transferFundsView.showActionButton(isValidAmount(text))
        }
    }
    
    // MARK: UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        transferFundsView.showLimitError("", show: false)
        
        guard let text = textField.text else { return false }
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if (string == "." || string == "0") && text.count == 0 { return false }

        transferFundsView.showActionButton(isValidAmount(newText))
        if string.isEmpty { return true }

        if amountExceedsLimit(text + string, amountLimit) {
            let amount = (currencySymbol ?? "") + " " + String(amountLimit ?? 0)
            transferFundsView.showLimitError(amount, show: true)
            return false
        }
        
        if !decimalsBelow(limit: 3, amount: text + string) {
            return false
        }
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            var decimalCount = 0
            for character in text {
                if character == "." {
                    decimalCount += 1
                }
            }
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        default:
            return string.count == 0
        }
    }
    
    // MARK: Public methods
    @objc func didTapOnActionButton() {
        guard let sourceId = sourceId,
              let amountTextField = transferFundsView.amountTextField.text,
              let amountToTransfer = Double(amountTextField),
              let currency = currency,
              let cardholder = transferModel.cardholder,
              let cardholderId = cardholder.cardholderId else { return }
        let amount = Amount(value: amountToTransfer, currency: currency)
        let transferRequest = P2PTransferRequest(sourceId: sourceId, recipientId: cardholderId, amount: amount)
        viewModel.performTransferRequest(model: transferRequest)
    }
    
    @objc func didTapOnClose() {
        navigationController?.dismiss(animated: true)
    }
}
