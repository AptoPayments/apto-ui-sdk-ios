//
//  AddMoneyViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/1/21.
//

import AptoSDK

class AddMoneyViewController: ShiftViewController {
    private(set) lazy var bottomView = AddMoneyView(uiconfig: self.uiConfiguration)
    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        return view
    }()
    private(set) var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    var directDepositAction: (() -> Void)?
    private let viewModel: AddMoneyViewModel

    init(uiConfiguration: UIConfig, viewModel: AddMoneyViewModel) {
        self.viewModel = viewModel
        super.init(uiConfiguration: uiConfiguration)
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
        [backView, bottomView, activityIndicator].forEach(view.addSubview)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(closeAddMoney))
        backView.addGestureRecognizer(recognizer)
        
        let item2Recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnDirectDepositItem))
        bottomView.item2ActionDetailView.addGestureRecognizer(item2Recognizer)
    }
    
    private func setupConstraints() {
        backView.snp.makeConstraints { $0.edges.equalToSuperview() }
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(bottomConstraint).inset(10)
            make.height.equalTo(200)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    @objc func closeAddMoney() {
        dismiss(animated: false)
    }
    
    @objc func didTapOnDirectDepositItem() {
        directDepositAction?()
    }
    
    // MARK: Private methods
    private func setupBinding() {
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
        
        viewModel.onCardProductNameLoadedSuccessfully = { [bottomView] cardProductName in
            bottomView.configure(with: cardProductName)
        }
    }    
}

