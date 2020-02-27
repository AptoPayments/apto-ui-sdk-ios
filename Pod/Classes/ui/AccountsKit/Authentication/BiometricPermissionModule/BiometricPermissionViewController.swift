//
//  BiometricPermissionViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 11/02/2020.
//

import UIKit
import AptoSDK
import SnapKit
import Bond
import ReactiveKit

class BiometricPermissionViewController: ShiftViewController {
  private let disposeBag = DisposeBag()
  private unowned let presenter: BiometricPermissionPresenterProtocol
  private let titleLabel: UILabel
  private let explanationLabel: UILabel
  private let disclosureLabel: UILabel
  private let imageViewContainer = UIView()
  private let imageView = UIImageView()
  private var callToAction: UIButton! // swiftlint:disable:this implicitly_unwrapped_optional

  init(uiConfiguration: UIConfig, presenter: BiometricPermissionPresenterProtocol) {
    self.presenter = presenter
    self.titleLabel = ComponentCatalog.largeTitleLabelWith(text: " ", multiline: false, uiConfig: uiConfiguration)
    self.explanationLabel = ComponentCatalog.formLabelWith(text: " ", multiline: true,
                                                           lineSpacing: uiConfiguration.lineSpacing,
                                                           letterSpacing: uiConfiguration.letterSpacing,
                                                           uiConfig: uiConfiguration)
    self.disclosureLabel = ComponentCatalog.instructionsLabelWith(text: " ", uiConfig: uiConfiguration)
    super.init(uiConfiguration: uiConfiguration)
    self.callToAction = ComponentCatalog.buttonWith(title: " ", showShadow: false,
                                                    uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.requestPermissionTapped()
    }
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
}

private extension BiometricPermissionViewController {
  func setUpViewModelSubscriptions() {
    let viewModel = presenter.viewModel
    viewModel.biometryType.observeNext { [weak self] biometryType in
      self?.updateContent(for: biometryType)
    }.dispose(in: disposeBag)
  }

  func updateContent(for biometryType: BiometryType) {
    switch biometryType {
    case .touchID:
      updateContentForTouchID()
    default:
      updateContentForFaceID()
    }
  }

  func updateContentForTouchID() {
    titleLabel.updateAttributedText("biometric.permission.touch_id.title".podLocalized())
    explanationLabel.updateAttributedText("biometric.permission.touch_id.explanation".podLocalized())
    callToAction.updateAttributedTitle("biometric.permission.touch_id.cta".podLocalized(), for: .normal)
    disclosureLabel.updateAttributedText("biometric.permission.touch_id.disclosure".podLocalized())
    imageView.image = UIImage.imageFromPodBundle("touchID")?.asTemplate()
  }

  func updateContentForFaceID() {
    titleLabel.updateAttributedText("biometric.permission.face_id.title".podLocalized())
    explanationLabel.updateAttributedText("biometric.permission.face_id.explanation".podLocalized())
    callToAction.updateAttributedTitle("biometric.permission.face_id.cta".podLocalized(), for: .normal)
    disclosureLabel.updateAttributedText("biometric.permission.face_id.disclosure".podLocalized())
    imageView.image = UIImage.imageFromPodBundle("faceID")?.asTemplate()
  }
}

// MARK: - Set up UI
private extension BiometricPermissionViewController {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    setUpTitleLabel()
    setUpExplanationLabel()
    setUpDisclosureLabel()
    setUpCallToAction()
    setUpImageViewContainer()
    setUpImageView()
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
      make.top.equalTo(titleLabel.snp.bottom).offset(8)
    }
  }

  func setUpDisclosureLabel() {
    view.addSubview(disclosureLabel)
    disclosureLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(28)
      make.bottom.equalTo(bottomConstraint).inset(20)
    }
  }

  func setUpCallToAction() {
    view.addSubview(callToAction)
    callToAction.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(20)
      make.bottom.equalTo(disclosureLabel.snp.top).offset(-24)
    }
  }

  func setUpImageViewContainer() {
    imageViewContainer.backgroundColor = .clear
    view.addSubview(imageViewContainer)
    imageViewContainer.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(explanationLabel.snp.bottom).offset(8)
      make.bottom.equalTo(callToAction.snp.top).offset(-8)
    }
  }

  func setUpImageView() {
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = uiConfiguration.uiPrimaryColor
    imageViewContainer.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
