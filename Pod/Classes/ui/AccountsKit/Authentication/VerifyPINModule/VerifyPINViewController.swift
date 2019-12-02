//
//  VerifyPINViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class VerifyPINViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: VerifyPINPresenterProtocol
  private let logoImageView = UIImageView()
  private let biometricButton = UIButton()
  private let pinEntryView: SecretPINView
  private let forgotButton: UIButton

  init(uiConfiguration: UIConfig, presenter: VerifyPINPresenterProtocol) {
    self.presenter = presenter
    self.pinEntryView = SecretPINView(uiConfig: uiConfiguration)
    self.forgotButton = ComponentCatalog.secondaryButtonWith(title: "biometric.verify_pin.forgot.cta".podLocalized(),
                                                             uiConfig: uiConfiguration) { [unowned presenter] in
      presenter.forgotPINTapped()
    }
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
}

private extension VerifyPINViewController {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.error.ignoreNils().observeNext { [weak self] error in
      self?.pinEntryView.resetCode()
      self?.show(error: error)
    }.dispose(in: disposeBag)
    viewModel.logoURL.ignoreNils().observeNext { [weak self] logoURL in
      if let url = URL(string: logoURL) {
        self?.logoImageView.setImageUrl(url)
      }
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension VerifyPINViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpLogoImageView()
    setUpBiometricsButton()
    setUpPinEntryView()
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.isHidden = true
  }

  func setUpLogoImageView() {
    view.addSubview(logoImageView)
    logoImageView.snp.makeConstraints { make in
      make.height.equalTo(44)
      make.centerX.equalToSuperview()
      make.top.equalTo(topConstraint).offset(44)
    }
  }

  func setUpBiometricsButton() {
    biometricButton.setTitle("Hello", for: .normal)
    biometricButton.isHidden = true
    view.addSubview(biometricButton)
    biometricButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(bottomConstraint).inset(24)
    }
  }

  func setUpPinEntryView() {
    pinEntryView.delegate = self
    view.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.top.equalTo(logoImageView.snp.bottom).offset(24)
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalTo(biometricButton.snp.top)
    }
    pinEntryView.bottomLeftView = forgotButton
  }
}

extension VerifyPINViewController: SecretPINViewDelegate {
  func secretPINView(_ secretPINView: SecretPINView, didEnterPIN pin: String) {
    presenter.pinEntered(pin)
  }
}
