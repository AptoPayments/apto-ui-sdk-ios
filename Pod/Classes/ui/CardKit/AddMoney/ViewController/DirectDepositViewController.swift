//
//  DirectDepositViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 27/1/21.
//

import AptoSDK

class DirectDepositViewController: ShiftViewController {
    private(set) lazy var mainView = DirectDepositView(uiconfig: uiConfiguration)
    private let viewModel: DirectDepositViewModel
    typealias CardProductsResult = Result<CardProduct, NSError>
    
    init(uiConfiguration: UIConfig, viewModel: DirectDepositViewModel) {
        self.viewModel = viewModel
        super.init(uiConfiguration: uiConfiguration)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
        viewModel.load()
        viewModel.trackEvent()
        title = "load_funds.selector_dialog.direct_deposit.title".podLocalized()
    }
    
    override func closeTapped() {
        dismiss(animated: true)
    }
    
    // MARK: Private methods
    private func setupBinding() {
        viewModel.onCardLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.mainView.activityIndicator.startAnimating()
                self?.mainView.alpha = 0
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
            self?.mainView.alpha = 1
        }
    }
}
