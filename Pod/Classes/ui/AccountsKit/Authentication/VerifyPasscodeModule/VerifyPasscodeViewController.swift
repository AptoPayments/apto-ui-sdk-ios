//
//  VerifyPasscodeViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class VerifyPasscodeViewController: AptoViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: VerifyPasscodePresenterProtocol
  private let logoImageView = UIImageView()
  private let pinEntryView: SecretPasscodeView
  private let forgotButton: UIButton

  init(uiConfiguration: UIConfig, presenter: VerifyPasscodePresenterProtocol) {
    self.presenter = presenter
    self.pinEntryView = SecretPasscodeView(uiConfig: uiConfiguration)
    let forgotPasscodeTitle = "biometric.verify_pin.forgot.cta".podLocalized()
    self.forgotButton = ComponentCatalog.formTextLinkButtonWith(
      title: forgotPasscodeTitle, uiConfig: uiConfiguration) { [unowned presenter] in
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

private extension VerifyPasscodeViewController {
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
private extension VerifyPasscodeViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpLogoImageView()
    setUpForgutButton()
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
      make.top.equalTo(topConstraint).offset(topMargin)
    }
  }

  var topMargin: CGFloat {
    switch UIDevice.deviceType() {
    case .iPhone5:
      return 56
    case .iPhone678:
      return 80
    default:
      return 124
    }
  }

  func setUpForgutButton() {
    view.addSubview(forgotButton)
    forgotButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(42)
      make.bottom.equalTo(bottomConstraint).inset(20)
    }
  }

  func setUpPinEntryView() {
    pinEntryView.delegate = self
    view.addSubview(pinEntryView)
    pinEntryView.snp.makeConstraints { make in
      make.top.equalTo(logoImageView.snp.bottom).offset(24)
      make.left.right.equalToSuperview().inset(24)
      make.bottom.equalTo(forgotButton.snp.top)
    }
  }
}

extension VerifyPasscodeViewController: SecretPasscodeViewDelegate {
  func secretPasscodeView(_ secretPasscodeView: SecretPasscodeView, didEnterPIN pin: String) {
    presenter.pinEntered(pin)
  }
}
