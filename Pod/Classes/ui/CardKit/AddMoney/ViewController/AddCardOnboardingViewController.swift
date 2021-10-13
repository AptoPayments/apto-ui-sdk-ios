//
//  AddCardOnboardingViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 15/6/21.
//

import AptoSDK

class AddCardOnboardingViewController: AptoViewController {
    private(set) lazy var mainView = AddCardOnboardingView(uiconfig: uiConfiguration)
    private let viewModel: AddCardOnboardingViewModel
    public typealias CloseCompletionResult = ((UIViewController) -> Void)
    var closeButtonCompletion: CloseCompletionResult?
    var actionButtonCompletion: (() -> Void)?

    init(uiConfiguration: UIConfig, viewModel: AddCardOnboardingViewModel) {
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
        viewModel.fetchInfo()
    }
    
    override func closeTapped() {
        closeButtonCompletion?(self)
        dismiss(animated: true)
    }
    
    // MARK: Private methods
    private func setupBinding() {
        viewModel.onCardLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.showLoadingSpinner()
                self?.mainView.hideView()
            } else {
                self?.hideActivityIndicator()
            }
        }

        viewModel.onCardInfoLoadedSuccessfully = { [weak self] cardData in
            if let cardName = cardData.cardName, let descriptor = cardData.softDescriptor {
                let p1 = "load_funds.add_card.onboarding.explanation".podLocalized().replace(["<<VALUE>>" : cardName])
                let p2 = "load_funds.add_card.onboarding.explanation_2".podLocalized().replace(["<<VALUE>>" : descriptor])
                self?.mainView.configure(firstParagraph: p1, secondParagraph: p2)
            }
        }
        
        viewModel.onErrorCardLoading = { [weak self] error in
            self?.show(error: error)
        }
        
        mainView.actionButton.addTarget(self, action: #selector(didTapOnActionButton), for: .touchUpInside)
    }
    
    private func hideActivityIndicator() {
        hideLoadingSpinner()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.mainView.showView()
        }
    }
    
    @objc func didTapOnActionButton() {
        LoadFundsOnBoardingHelper.markAsPresented()
        dismiss(animated: true) { [weak self] in
            self?.actionButtonCompletion?()
        }
    }
}
