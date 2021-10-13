//
//  AddMoneyViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/1/21.
//

import AptoSDK
import SnapKit

class AddMoneyViewController: AptoViewController {
    private(set) lazy var addMoneyView = AddMoneyView(uiconfig: self.uiConfiguration)
    private(set) var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    var directDepositAction: (() -> Void)?
    var debitCardAction: (() -> Void)?
    private let viewModel: AddMoneyViewModel
    private let dismissUponPresentation: Bool
    private var bottomSheetBottomConstraint: Constraint?
    
    init(uiConfiguration: UIConfig, viewModel: AddMoneyViewModel, dismissUponPresentation: Bool = true) {
        self.viewModel = viewModel
        self.dismissUponPresentation = dismissUponPresentation
        super.init(uiConfiguration: uiConfiguration)
        transitioningDelegate = self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupBinding()
        viewModel.load()
        viewModel.trackEvent()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        [addMoneyView, activityIndicator].forEach(view.addSubview)
    }
    
    private func setupConstraints() {
        addMoneyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            self.bottomSheetBottomConstraint = make.bottom.equalTo(bottomConstraint).offset(300).constraint
            make.height.equalTo(200)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: Private methods
    private func setupBinding() {
        let item1Recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnDebitaCardItem))
        addMoneyView.item1ActionDetailView.addGestureRecognizer(item1Recognizer)

        let item2Recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnDirectDepositItem))
        addMoneyView.item2ActionDetailView.addGestureRecognizer(item2Recognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeAddMoney))
        addMoneyView.dimView.addGestureRecognizer(tapRecognizer)

        viewModel.onCardLoadingStateChange = { [activityIndicator] isLoading in
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
        
        viewModel.onErrorCardLoading = { [weak self] error in
            self?.show(error: error)
        }        
    }

    // MARK: Public methods
    @objc func closeAddMoney() {
        dismiss(animated: false)
    }
    
    @objc func didTapOnDirectDepositItem() {
        if dismissUponPresentation {
            closeAddMoney()
        }
        directDepositAction?()
    }
    
    @objc func didTapOnDebitaCardItem() {
        if dismissUponPresentation {
            closeAddMoney()
        }
        debitCardAction?()
    }
}

extension AddMoneyViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = AddMoneyAnimationController(with: addMoneyView)
        animationController.direction = .present
        return animationController
    }
}
