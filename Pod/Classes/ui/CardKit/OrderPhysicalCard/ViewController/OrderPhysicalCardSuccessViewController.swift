//
//  OrderPhysicalCardSuccessViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/3/21.
//

import AptoSDK
import SnapKit

final class OrderPhysicalCardSuccessViewController: AptoViewController {
    private(set) lazy var mainView = OrderPhysicalCardSuccessView(uiconfig: uiConfiguration)
    var onCompletion: (() -> Void)?
    private let card: Card

    init(card: Card, uiConfiguration: UIConfig) {
        self.card = card
        super.init(uiConfiguration: uiConfiguration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.configure(card: card)
        mainView.actionButton.addTarget(self, action: #selector(didTapOnActionButton), for: .touchUpInside)
        navigationItem.setHidesBackButton(true, animated: false)
    }

    @objc func didTapOnActionButton() {
        dismiss(animated: true) { [onCompletion] in
            onCompletion?()
        }
    }
}
