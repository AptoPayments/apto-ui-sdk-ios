//
// SetPinViewControllerThemeTwo.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import AptoSDK
import Bond
import ReactiveKit
import SnapKit
import UIKit

class SetCodeViewController: AptoViewController {
    private let disposeBag = DisposeBag()
    private unowned let presenter: SetCodePresenterProtocol
    private let texts: SetCodeViewControllerTexts
    private let titleLabel: UILabel
    private let explanationLabel: UILabel
    private var pinEntryContainerView = UIView()
    private var pinEntryView: UIPinEntryTextField
    private var pin: String?

    init(uiConfiguration: UIConfig, presenter: SetCodePresenterProtocol, texts: SetCodeViewControllerTexts) {
        self.presenter = presenter
        self.texts = texts
        titleLabel = ComponentCatalog.largeTitleLabelWith(text: texts.setCode.title,
                                                          multiline: false, uiConfig: uiConfiguration)
        explanationLabel = ComponentCatalog.formLabelWith(text: texts.setCode.explanation,
                                                          multiline: true, lineSpacing: uiConfiguration.lineSpacing,
                                                          letterSpacing: uiConfiguration.letterSpacing,
                                                          uiConfig: uiConfiguration)
        pinEntryView = UIPinEntryTextField(size: 4, frame: .zero)
        super.init(uiConfiguration: uiConfiguration)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpViewModelSubscriptions()
        presenter.viewLoaded()
    }

    override func closeTapped() {
        if pin != nil {
            updateUIForPin()
        } else {
            presenter.closeTapped()
        }
    }
}

extension SetCodeViewController: UIPinEntryTextFieldDelegate {
    func pinEntryTextField(didFinishInput frPinView: UIPinEntryTextField) {
        let newPin = frPinView.getText()
        if let pin = pin {
            handlePinConfirmation(pin: pin, newPin: newPin)
        } else {
            pin = newPin
            updateUIForPinConfirmation()
        }
    }

    func handlePinConfirmation(pin: String, newPin: String) {
        if pin == newPin {
            presenter.codeEntered(pin)
        } else {
            updateUIForPin()
            showPinDoNotMatchErrorMessage()
        }
    }

    func updateUIForPin() {
        view.fadeIn(animations: { [weak self] in // swiftlint:disable:this trailing_closure
            self?.titleLabel.updateAttributedText(self?.texts.setCode.title)
            self?.explanationLabel.updateAttributedText(self?.texts.setCode.explanation)
            self?.pinEntryView.resetText()
            self?.pinEntryView.focus()
            self?.navigationItem.leftBarButtonItem = nil
            self?.showNavCancelButton()
            self?.pin = nil
        })
    }

    func updateUIForPinConfirmation() {
        view.fadeIn(animations: { [weak self] in // swiftlint:disable:this trailing_closure
            self?.titleLabel.updateAttributedText(self?.texts.confirmCode.title)
            self?.explanationLabel.updateAttributedText(self?.texts.confirmCode.explanation)
            self?.pinEntryView.resetText()
            self?.pinEntryView.focus()
            self?.navigationItem.leftBarButtonItem = nil
            self?.showNavPreviousButton()
        })
    }
}

private extension SetCodeViewController {
    func setUpViewModelSubscriptions() {
        let viewModel = presenter.viewModel
        viewModel.showLoading.ignoreNils().observeNext { [weak self] showLoading in
            self?.handleShowLoading(showLoading)
        }.dispose(in: disposeBag)
        viewModel.error.ignoreNils().observeNext { [weak self] error in
            self?.show(error: error)
        }.dispose(in: disposeBag)
    }

    func handleShowLoading(_ showLoading: Bool) {
        if showLoading {
            showLoadingView()
        } else {
            hideLoadingView()
        }
    }
}

// MARK: - Set up UI

private extension SetCodeViewController {
    func setUpUI() {
        view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
        setUpTitle()
        setUpNavigationBar()
        setUpTitleLabel()
        setUpExplanationLabel()
        setUpPinEntryContainer()
        setUpPinEntryView()
    }

    func setUpTitle() {
        title = ""
    }

    func setUpNavigationBar() {
        navigationController?.navigationBar.hideShadow()
        navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                                  tintColor: uiConfiguration.textTopBarPrimaryColor)
    }

    func setUpTitleLabel() {
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(16)
        }
    }

    func setUpExplanationLabel() {
        view.addSubview(explanationLabel)
        explanationLabel.snp.makeConstraints { make in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
    }

    func setUpPinEntryContainer() {
        pinEntryContainerView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
        pinEntryContainerView.layer.cornerRadius = uiConfiguration.fieldCornerRadius
        pinEntryContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        pinEntryContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        pinEntryContainerView.layer.shadowOpacity = 1
        pinEntryContainerView.layer.shadowRadius = 4
        view.addSubview(pinEntryContainerView)
        pinEntryContainerView.snp.makeConstraints { make in
            make.top.equalTo(explanationLabel.snp.bottom).offset(48)
            make.left.right.equalTo(titleLabel)
            make.height.equalTo(uiConfiguration.formRowHeight)
        }
    }

    func setUpPinEntryView() {
        pinEntryView.delegate = self
        pinEntryView.showMiddleSeparator = false
        pinEntryView.pinBorderWidth = 0
        pinEntryView.pinBorderColor = .clear
        pinEntryView.font = uiConfiguration.fontProvider.formFieldFont
        pinEntryView.textColor = uiConfiguration.textSecondaryColor
        pinEntryView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
        pinEntryView.tintColor = uiConfiguration.uiPrimaryColor
        pinEntryView.placeholder = "-"
        pinEntryContainerView.addSubview(pinEntryView)
        pinEntryView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(48)
            make.height.equalTo(44)
        }
        pinEntryView.resetText()
        pinEntryView.focus()
    }

    func showPinDoNotMatchErrorMessage() {
        _ = pinEntryView.resignFirstResponder()
        show(message: texts.setCode.wrongCodeMessage, title: texts.setCode.wrongCodeTitle, isError: true)
    }
}
