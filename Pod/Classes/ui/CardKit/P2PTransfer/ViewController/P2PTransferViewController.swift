//
//  P2PTransferViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 22/7/21.
//

import AptoSDK
import SnapKit

class P2PTransferViewController: AptoViewController {
    private(set) lazy var transferView: P2PTransferView = {
        guard let config = self.projectConfiguration,
              let defaultCountry = config.allowedCountries.first else {
            return P2PTransferView(uiconfig: self.uiConfiguration, defaultCountry: "")
        }
        return P2PTransferView(uiconfig: self.uiConfiguration, defaultCountry: defaultCountry.isoCode)
    }()
    private let viewModel: P2PTransferViewModel
    private(set) var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    private let projectConfiguration: ProjectConfiguration?
    private var debounceTimer: Timer?
    var debounceDelay: TimeInterval = 0.8
    private let keyboardWatcher = KeyboardWatcher()
    private var transferModel: P2PTransferModel?
    var continueTransferCompletion: ((P2PTransferModel) -> Void)?
    
    init(uiConfiguration: UIConfig, viewModel: P2PTransferViewModel, projectConfiguration: ProjectConfiguration?) {
        self.viewModel = viewModel
        self.projectConfiguration = projectConfiguration
        super.init(uiConfiguration: uiConfiguration)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupBinding()
        if let projectConfiguration = projectConfiguration {
            setupInputTextField(with: projectConfiguration.primaryAuthCredential)
        } else {
            viewModel.loadConfiguration()
        }
        watchKeyboard()
        navigationController?.navigationBar.hideShadow()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeResponder()
    }
    
    // MARK: Private methods
    private func setupView() {
        view.backgroundColor = .white
        [transferView, activityIndicator].forEach(view.addSubview)
    }

    private func setupConstraints() {
        transferView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupBinding() {
        viewModel.onConfigurationLoaded = { [weak self] authMethod in
            self?.setupInputTextField(with: authMethod)
        }
        
        viewModel.onErrorRequest = { [weak self] error in
            self?.show(error: error)
        }

        viewModel.onLoadingStateChange = { [activityIndicator] isLoading in
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
        
        viewModel.onRecipientLoadingStateChange = { [transferView] isLoading in
            if isLoading {
                transferView.hideResultsView()
                transferView.startLoading()
            } else {
                transferView.stopLoading()
            }
        }
        
        viewModel.onFindRecipientError = { [transferView] error in
            transferView.showNoResults(error.localizedDescription)
        }
        
        viewModel.onRecipientFound = { [weak self] result in
            if let phone = result.phone,
               let prefix = phone.countryCode.value,
               let number = phone.phoneNumber.value {
                self?.transferView.showResult(with: result.recipient, contact: "+" + String(prefix) + number)
                self?.transferModel = P2PTransferModel(phone: phone, email: nil, cardholder: result.recipient)
            } else if let email = result.email {
                self?.transferView.showResult(with: result.recipient, contact: email)
                self?.transferModel = P2PTransferModel(phone: nil, email: email, cardholder: result.recipient)
            }
        }
        
        transferView.phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        transferView.emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        transferView.continueButton.addTarget(self, action: #selector(didTapOnContinueButton), for: .touchUpInside)
    }
    
    private func becomeResponder() {
        if !transferView.phoneTextField.isHidden {
            transferView.phoneTextField.becomeFirstResponder()
        } else if !transferView.emailTextField.isHidden {
            transferView.emailTextField.becomeFirstResponder()
        }
    }
    
    @objc private func process(_ textField: UITextField) {
        guard let input = textField.text else { return }
        switch textField {
        case transferView.phoneTextField:
            let isValid = viewModel.isValidPhoneNumber(input)
            transferView.set(textField, invalid: !isValid)
            if isValid {
                viewModel.findRecipient(phone: input)
            }
        case transferView.emailTextField:
            let isValid = viewModel.isValidEmail(input)
            transferView.set(textField, invalid: !isValid)
            if isValid {
                viewModel.findRecipient(email: input)
            }
        default:
            break
        }
    }
    
    private func setupInputTextField(with authMethod: DataPointType) {
        switch authMethod {
        case .email:
            transferView.configureView(for: .email, intro: "p2p_transfer.main_screen.intro.email_description")
        case .phoneNumber:
            transferView.configureView(for: .phone, intro: "p2p_transfer.main_screen.intro.phone_number.description")
        default: break
        }
    }
    
    private func watchKeyboard() {
        keyboardWatcher.startWatching(onKeyboardShown: { [weak self] size in
            self?.transferView.updateButtonPosition(to: size.height)
        })
    }

    // MARK: Public methods
    @objc override func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        transferView.hideResultsView()
        if let timer = debounceTimer {
            timer.invalidate()
        }
        if debounceDelay == 0 {
            process(textField)
        } else {
            debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceDelay, repeats: false) { [weak self] timer in
                self?.process(textField)
            }
        }
    }
    
    @objc func didTapOnContinueButton() {
        if let transferModel = transferModel {
            continueTransferCompletion?(transferModel)
        }
    }
}
