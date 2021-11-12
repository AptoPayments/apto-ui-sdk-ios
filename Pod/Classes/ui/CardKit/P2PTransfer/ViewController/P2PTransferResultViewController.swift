//
//  P2PTransferResultViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 7/10/21.
//

import Foundation
import AptoSDK

class P2PTransferResultViewController: AptoViewController {
    private(set) lazy var resultView: GenericResultScreenView = {
        let summary = resultSummary()
        let view = GenericResultScreenView(uiconfig: uiConfiguration, bottomViewItemCount: summary.count)
        view.configure(for: .success, text: headerTitleText())
        view.configureBottomItems(with: summary)
        return view
    }()
    private let transferResponse: P2PTransferResponse
    
    init(uiConfiguration: UIConfig, transferResponse: P2PTransferResponse) {
        self.transferResponse = transferResponse
        super.init(uiConfiguration: uiConfiguration)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        self.view = resultView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = ""
        navigationItem.hidesBackButton = true
        let closeImageIcon = UIImage.imageFromPodBundle("top_close_default")
        let closeButton = UIBarButtonItem(image: closeImageIcon, style: .plain, target: self, action: #selector(didTapOnClose))
        navigationItem.leftBarButtonItem = closeButton
        resultView.doneButton.addTarget(self, action: #selector(didTapOnDoneButton), for: .touchUpInside)
    }
    
    // MARK: Private methods
    private func headerTitleText() -> String {
        let recipient = (transferResponse.recipientFirstName ?? "") + " " + (transferResponse.recipientLastName ?? "")
        var headerTitle = ""
        switch transferResponse.status {
        case .pending:
            headerTitle = "p2p_transfer.transfer_funds.success.pending.title"
                .podLocalized()
                .replace(["<<VALUE>>": recipient])
        case .processed:
            let amount = transferResponse.amount?.amount.value ?? 0
            let value = "\(transferResponse.amount?.currencySymbol ?? "")\(String(format: "%.2f", amount))"
            headerTitle = "p2p_transfer.transfer_funds.success.completed.title"
                .podLocalized()
                .replace(["<<VALUE>>": value, "<<NAME>>": recipient])
        default: break
        }
        return headerTitle
    }
    
    private func statusTitleText() -> String {
        var status = ""
        switch transferResponse.status {
        case .pending:
            status = "p2p_transfer.transfer_funds.success.status.pending.title".podLocalized()
        case .processed:
            status = "p2p_transfer.transfer_funds.success.status.processed.title".podLocalized()
        default: break
        }
        return status
    }
    
    private func resultSummary() -> [BottomItemModel] {
        var summary = [
            BottomItemModel(info: "p2p_transfer.transfer_funds.success.status.title".podLocalized(),
                            value: statusTitleText())
        ]
        if let transactionDate = transferResponse.createdAt {
            let dateFormatter = DateFormatter.dateTimeFormatter()
            dateFormatter.timeStyle = .medium
            summary.append(BottomItemModel(info: "p2p_transfer.transfer_funds.success.time.title".podLocalized(),
                                           value: dateFormatter.string(from: transactionDate)))
        }
        return summary
    }
    
    // MARK: Public methods
    @objc public func didTapOnDoneButton() {
        navigationController?.dismiss(animated: true)
    }
    
    @objc func didTapOnClose() {
        navigationController?.dismiss(animated: true)
    }
}
