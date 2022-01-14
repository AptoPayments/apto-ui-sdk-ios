//
//  VerifyDocumentModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 22/03/2018.
//
//

import AptoSDK
import UIKit

protocol VerifyDocumentRouterProtocol {
    func closeTappedInVerifyDocument()
    func nextTappedInVerifyDocumentWith(verification: Verification)
    func retakePicturesTappedInVerifyDocument()
    func retakeSelfieTappedInVerifyDocument()
}

class VerifyDocumentModule: UIModule {
    private var inputDocumentPresenter: InputDocumentPresenter?
    private let workflowObject: WorkflowObject?

    init(serviceLocator: ServiceLocatorProtocol, workflowObject: WorkflowObject?) {
        self.workflowObject = workflowObject

        super.init(serviceLocator: serviceLocator)
    }

    open var onVerificationPassed: ((_ verifyDocumenteModule: VerifyDocumentModule,
                                     _ verificationResult: DocumentVerificationResult) -> Void)?

    override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
        let presenter = InputDocumentPresenter()
        let viewController = InputDocumentViewController(uiConfiguration: uiConfig, eventHandler: presenter)
        presenter.router = self
        inputDocumentPresenter = presenter
        addChild(viewController: viewController, completion: completion)
    }

    fileprivate func showVerifyDocumentViewController(documentImages: [UIImage], selfie: UIImage?,
                                                      livenessData: [String: AnyObject]?,
                                                      completion _: @escaping Result<Void, NSError>.Callback)
    {
        let presenter = VerifyDocumentPresenter()
        let viewController = VerifyDocumentViewController(uiConfiguration: uiConfig, eventHandler: presenter)
        let interactor = VerifyDocumentInteractor(platform: platform, documentImages: documentImages, selfie: selfie,
                                                  livenessData: livenessData, workflowObject: workflowObject,
                                                  dataReceiver: presenter)
        presenter.router = self
        presenter.interactor = interactor
        push(viewController: viewController) {}
    }
}

extension VerifyDocumentModule: InputDocumentRouterProtocol {
    func closeTappedInInputDocument() {
        close()
    }

    func willShowFirstViewController() {
        makeNavigationBarTransparent()
    }

    func inputDocumentViewControllerDocumentsSelected(documentImages: [UIImage], selfie: UIImage?) {
        showVerifyDocumentViewController(documentImages: documentImages, selfie: selfie, livenessData: nil) { _ in }
    }
}

extension VerifyDocumentModule: VerifyDocumentRouterProtocol {
    func closeTappedInVerifyDocument() {
        restoreNavigationBarFromTransparentState()
        close()
    }

    func retakePicturesTappedInVerifyDocument() {
        guard let presenter = inputDocumentPresenter else {
            return
        }
        presenter.retakePictures()
        popViewController {}
    }

    func retakeSelfieTappedInVerifyDocument() {
        guard let presenter = inputDocumentPresenter else {
            return
        }
        presenter.retakeSelfie()
        popViewController {}
    }

    func nextTappedInVerifyDocumentWith(verification: Verification) {
        restoreNavigationBarFromTransparentState()
        onVerificationPassed?(self, verification.documentVerificationResult!) // swiftlint:disable:this force_unwrapping
        finish()
    }
}
