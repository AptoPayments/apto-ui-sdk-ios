//
//  OrderPhysicalCardViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 25/3/21.
//

import Foundation
import AptoSDK
import SnapKit

final class OrderPhysicalCardViewController: AptoViewController {
    private var viewModel: OrderPhysicalCardViewModel
    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    private(set) lazy var orderCardView = OrderPhysicalCardView(uiconfig: uiConfiguration)
    var cardOrderedCompletion: (() -> Void)?
    var cardConfigErrorCompletion: ((NSError) -> Void)?

    init(uiConfiguration: UIConfig, viewModel: OrderPhysicalCardViewModel) {
        self.viewModel = viewModel
        super.init(uiConfiguration: uiConfiguration)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraint()
        setupBindings()
        viewModel.loadConfig()
        viewModel.track(event: .orderPhysicalCardStart)
    }
    
    // MARK: Private methods
    private func setupView() {
        [orderCardView, activityIndicator].forEach(view.addSubview)
    }
    
    private func setupConstraint() {
        orderCardView.snp.makeConstraints { $0.edges.equalToSuperview() }
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    private func setupBindings() {
        orderCardView.actionButton.addTarget(self, action: #selector(didTapOnActionButton), for: .touchUpInside)
        orderCardView.cancelButton.addTarget(self, action: #selector(didTapOnCancelButton), for: .touchUpInside)
        
        viewModel.onOrderCardLoadingStateChange = { [orderCardView, activityIndicator] isLoading in
            if isLoading {
                orderCardView.viewButtons(enable: false)
                activityIndicator.startAnimating()
            } else {
                orderCardView.viewButtons(enable: true)
                activityIndicator.stopAnimating()
            }
        }
        
        viewModel.onOrderCardConfigLoaded = { [weak self] orderCardData in
            self?.orderCardView.configure(card: orderCardData.card,
                                    cardFee: orderCardData.config.issuanceFee?.text)
        }
        
        viewModel.onOrderCardError = { [weak self] error in
            self?.show(error: error)
            if let backendError = error as? BackendError,
               backendError.isBalanceInsufficientFundsError {
                self?.viewModel.track(event: .orderPhysicalCardInsufficientFunds)
            } else {
                self?.viewModel.track(event: .orderPhysicalCardError)
            }
        }
        
        viewModel.onOrderCardConfigError = { [weak self] error in
            self?.dismiss(animated: false, completion: {
                self?.cardConfigErrorCompletion?(error)
                self?.viewModel.track(event: .orderPhysicalCardError)
            })
        }
        
        viewModel.onCardOrdered = { [weak self] card in
            self?.gotToSuccess(card)
        }
    }
    
    private func gotToSuccess(_ card: Card) {
        let successViewController = OrderPhysicalCardSuccessViewController(card: card, uiConfiguration: uiConfiguration)
        successViewController.onCompletion = cardOrderedCompletion
        navigationController?.pushViewController(successViewController, animated: true)
    }
    
    // MARK: Internal
    @objc func didTapOnActionButton() {
        viewModel.performCardOrder()
        viewModel.track(event: .orderPhysicalCardRequested)
    }
    
    @objc func didTapOnCancelButton() {
        dismiss(animated: true) { [viewModel] in
            viewModel.track(event: .orderPhysicalCardDiscarded)
        }
    }
    
    @objc override func closeTapped() {
        didTapOnCancelButton()
    }
}
