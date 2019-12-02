//
//  CreatePINViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class CreatePINViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: CreatePINPresenterProtocol
  private let titleLabel: UILabel
  private let agreementView: ContentPresenterView
  private let pinEntryView: SecretPINView
  private let pinConfirmationView: SecretPINView
  private var currentCode = ""

  init(uiConfiguration: UIConfig, presenter: CreatePINPresenterProtocol) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: "biometric.create_pin.title".podLocalized(),
                                                           multiline: false, uiConfig: uiConfiguration)
    self.agreementView = ContentPresenterView(uiConfig: uiConfiguration)
    self.pinEntryView = SecretPINView(uiConfig: uiConfiguration)
    self.pinConfirmationView = SecretPINView(uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setUpViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }

  private func showEntryPIN() {
    pinEntryView.resetCode()
    titleLabel.updateAttributedText("biometric.create_pin.title".podLocalized())
    pinConfirmationView.isHidden = true
    view.bringSubviewToFront(pinEntryView)
  }

  private func showPINConfirmation() {
    pinConfirmationView.resetCode()
    titleLabel.updateAttributedText("biometric.create_pin.confirmation_title".podLocalized())
    pinConfirmationView.isHidden = false
    view.bringSubviewToFront(pinConfirmationView)
  }
}

private extension CreatePINViewController {
  func setUpViewModelSubscriptions() {
    presenter.viewModel.error.ignoreNils().observeNext { [weak self] error in
      self?.showEntryPIN()
      self?.show(error: error)
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension CreatePINViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpTitleLabel()
    setUpAgreementView()
    setUpPinEntryView()
    setUpPinConfirmationView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.hideShadow()
    navigationController?.navigationBar.setUp(barTintColor: uiConfiguration.uiNavigationPrimaryColor,
                                              tintColor: uiConfiguration.textTopBarPrimaryColor)
    hideNavPreviousButton()
  }

  func setUpTitleLabel() {
    titleLabel.adjustsFontSizeToFitWidth = true
    view.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.top.equalToSuperview().offset(16)
    }
  }

  func setUpAgreementView() {
    agreementView.textColor = uiConfiguration.textSecondaryColor
    agreementView.linkColor = uiConfiguration.textSecondaryColor
    agreementView.textAlignment = .center
    agreementView.delegate = self
    agreementView.set(content: .plainText("biometric.create_pin.agreement".podLocalized()))
    view.addSubview(agreementView)
    agreementView.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalTo(bottomConstraint).inset(24)
    }
  }

  func setUpPinEntryView() {
    pinEntryView.delegate = self
    view.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(24)
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalTo(agreementView.snp.top)
    }
  }

  func setUpPinConfirmationView() {
    pinConfirmationView.delegate = self
    pinConfirmationView.isHidden = true
    view.addSubview(pinConfirmationView)
    pinConfirmationView.snp.makeConstraints { make in
      make.edges.equalTo(pinEntryView)
    }
  }
}

extension CreatePINViewController: ContentPresenterViewDelegate {
  func linkTapped(url: TappedURL) {
    presenter.show(url: url)
  }
}

extension CreatePINViewController: SecretPINViewDelegate {
  func secretPINView(_ secretPINView: SecretPINView, didEnterPIN pin: String) {
    if secretPINView === pinEntryView {
      currentCode = pin
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
        self.showPINConfirmation()
      }
    }
    else {
      if currentCode == pin {
        presenter.pinEntered(currentCode)
      }
      else {
        show(message: "biometric.create_pin.error.pin_not_match".podLocalized(),
             title: "biometric.create_pin.error.title".podLocalized(), isError: true)
        showEntryPIN()
        pinEntryView.shake()
      }
    }
  }
}
