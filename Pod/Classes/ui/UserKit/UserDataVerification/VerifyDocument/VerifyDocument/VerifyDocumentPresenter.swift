//
//  VerifyDocumentPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 22/03 /2018.
//
//

import AptoSDK
import Bond

protocol VerifyDocumentInteractorProtocol {
  func startVerification()
  func checkVerificationStatus()
}

public enum VerifyDocumentState {
  case processing
  case success
  case error(String?)
  case selfieDoNotMatch(String)
}

open class VerifyDocumentViewModel {
  open var state: Observable<VerifyDocumentState> = Observable(.processing)
}

class VerifyDocumentPresenter: VerifyDocumentEventHandler, VerifyDocumentDataReceiver {
  var interactor: VerifyDocumentInteractorProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
  var router: VerifyDocumentRouterProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
  var viewModel: VerifyDocumentViewModel
  var verification: Verification?

  init() {
    self.viewModel = VerifyDocumentViewModel()
  }

  func viewLoaded() {
    self.interactor.startVerification()
  }

  func closeTapped() {
    router.closeTappedInVerifyDocument()
  }

  func startingVerification() {
    viewModel.state.send(.processing)
  }

  func verificationFailed(_ error: Error?) {
    viewModel.state.send(.error("verify_document.explanation.error".podLocalized()))
  }

  func verificationReceived(_ verification: Verification) {
    viewModel.state.send(.processing)
  }

  func verificationSucceeded(_ verification: Verification) {
    self.verification = verification
    guard let documentVerificationResult = verification.documentVerificationResult,
          documentVerificationResult.docCompletionStatus == .ok else {
      viewModel.state.send(.error("Can't verify Document"))
      return
    }
    guard documentVerificationResult.docAuthenticity == .authentic else {
      viewModel.state.send(.error("Invalid Document: \(documentVerificationResult.docAuthenticity.description())"))
      return
    }
    guard documentVerificationResult.faceComparisonResult == .faceMatch else {
      viewModel.state.send(.selfieDoNotMatch(documentVerificationResult.faceComparisonResult.description()))
      return
    }
    viewModel.state.send(.success)
  }

  func continueTapped() {
    if let verification = verification {
      router.nextTappedInVerifyDocumentWith(verification: verification)
    }
  }

  func retakePicturesTapped() {
    router.retakePicturesTappedInVerifyDocument()
  }

  func retakeSelfieTapped() {
    router.retakeSelfieTappedInVerifyDocument()
  }
}
