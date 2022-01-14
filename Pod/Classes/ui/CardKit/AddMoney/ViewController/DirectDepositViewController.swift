//
//  DirectDepositViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 27/1/21.
//

import AptoSDK

class DirectDepositViewController: AptoViewController {
    private(set) lazy var mainView = DirectDepositView(uiconfig: uiConfiguration)
    private let viewModel: DirectDepositViewModel
    typealias CardProductsResult = Result<CardProduct, NSError>

    init(uiConfiguration: UIConfig, viewModel: DirectDepositViewModel) {
        self.viewModel = viewModel
        super.init(uiConfiguration: uiConfiguration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        viewModel.load()
        viewModel.trackEvent()
        title = "load_funds.direct_deposit.title".podLocalized()
    }

    override func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: Private methods

    private func setupBinding() {
        let longPressGestureOnAccountNumber = UILongPressGestureRecognizer(
            target: self, action: #selector(longPressOnAccountNumberField(_:))
        )
        longPressGestureOnAccountNumber.minimumPressDuration = 0.3
        mainView.accountNumberInfoView.valueLabel.addGestureRecognizer(longPressGestureOnAccountNumber)

        let longPressGestureOnRoutingNumber = UILongPressGestureRecognizer(
            target: self, action: #selector(longPressOnRoutingNumberField(_:))
        )
        longPressGestureOnRoutingNumber.minimumPressDuration = 0.3
        mainView.routingNumberInfoView.valueLabel.addGestureRecognizer(longPressGestureOnRoutingNumber)

        viewModel.onCardLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.mainView.activityIndicator.startAnimating()
                self?.mainView.hideView()
            } else {
                self?.hideActivityIndicator()
            }
        }

        viewModel.onErrorCardLoading = { [weak self] error in
            self?.show(error: error)
        }

        viewModel.onCardLoadedSuccessfully = { [weak self] viewData in
            self?.mainView.configure(with: viewData)
        }
    }

    private func hideActivityIndicator() {
        mainView.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.mainView.showView()
        }
    }

    private func copyToClipboard(from gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .ended,
           let label = gestureReconizer.view as? UILabel,
           let string = label.text
        {
            let pasteboard = UIPasteboard.general
            pasteboard.string = string

            showMessage("load_funds.ach_account_details.copied_to_clipboard".podLocalized())
        }
    }

    @objc func longPressOnAccountNumberField(_ gestureReconizer: UILongPressGestureRecognizer) {
        copyToClipboard(from: gestureReconizer)
    }

    @objc func longPressOnRoutingNumberField(_ gestureReconizer: UILongPressGestureRecognizer) {
        copyToClipboard(from: gestureReconizer)
    }
}
