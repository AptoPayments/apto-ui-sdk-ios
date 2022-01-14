//
//  VerifyDocumentPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 22/03 /2018.
//
//

import Bond

protocol InputDocumentRouterProtocol: AnyObject {
    func closeTappedInInputDocument()
    func willShowFirstViewController()
    func inputDocumentViewControllerDocumentsSelected(documentImages: [UIImage], selfie: UIImage?)
}

public enum InputDocumentState {
    case loading
    case captureFrontPhoto
    case checkFrontPhoto(UIImage)
    case captureBackPhoto
    case checkBackPhoto(UIImage)
    case captureSelfie
    case checkSelfie(UIImage)
}

open class InputDocumentViewModel {
    open var state: Observable<InputDocumentState> = Observable(.loading)
    open var screenTitle: Observable<String?> = Observable(nil)
    open var frameNote: Observable<String?> = Observable(nil)
    open var actionTitle: Observable<String?> = Observable(nil)
    open var actionDescription: Observable<String?> = Observable(nil)
    open var okButtonTitle: Observable<String?> = Observable(nil)
    open var retakeButtonTitle: Observable<String?> = Observable(nil)
    open var canSkip: Observable<Bool> = Observable(false)
}

class InputDocumentPresenter: InputDocumentEventHandler {
    weak var router: InputDocumentRouterProtocol! // swiftlint:disable:this implicitly_unwrapped_optional
    var viewModel: InputDocumentViewModel
    var images: [UIImage] = []
    var selfie: UIImage?

    init() {
        viewModel = InputDocumentViewModel()
    }

    func viewLoaded() {
        showCaptureFrontDocument()
    }

    func viewWillAppear() {
        router.willShowFirstViewController()
    }

    public func retakePictures() {
        showCaptureFrontDocument()
    }

    public func retakeSelfie() {
        showCaptureSelfie()
    }

    func skipTapped() {
        showCaptureSelfie()
    }

    func imageFound(image: UIImage) {
        switch viewModel.state.value {
        case .captureFrontPhoto:
            showCheckFrontDocument(image: image)
        case .captureBackPhoto:
            showCheckBackDocument(image: image)
        case .captureSelfie:
            showCheckSelfieDocument(image: image)
        default:
            break
        }
    }

    func imageChecked(image: UIImage) {
        switch viewModel.state.value {
        case let .checkFrontPhoto(image):
            images.append(image)
            showCaptureBackDocument()
        case let .checkBackPhoto(image):
            images.append(image)
            showCaptureSelfie()
        case let .checkSelfie(image):
            selfie = image
            // All the document images captured. Continue
            router.inputDocumentViewControllerDocumentsSelected(documentImages: images, selfie: selfie)
        default:
            break
        }
    }

    func retakeTapped() {
        switch viewModel.state.value {
        case .checkFrontPhoto:
            showCaptureFrontDocument()
        case .checkBackPhoto:
            showCaptureBackDocument()
        case .checkSelfie:
            showCaptureSelfie()
        default:
            break
        }
    }

    func closeTapped() {
        router.closeTappedInInputDocument()
    }

    func previousTapped() {
        switch viewModel.state.value {
        case .checkFrontPhoto, .captureBackPhoto:
            showCaptureFrontDocument()
        case .checkBackPhoto, .captureSelfie:
            showCaptureBackDocument()
        case .checkSelfie:
            showCaptureSelfie()
        default:
            router.closeTappedInInputDocument()
        }
    }

    fileprivate func showCaptureFrontDocument() {
        images = []
        configureTexts(screenTitle: "verify-document.title.id-document-authentication".podLocalized(),
                       frameNote: "verify-document.frame-note".podLocalized(),
                       actionTitle: "verify-document.action.front-card.title".podLocalized(),
                       actionDescription: "verify-document.action.front-card.description".podLocalized(),
                       okButtonTitle: "verify-document.ok-button.title".podLocalized(),
                       retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
        viewModel.state.send(.captureFrontPhoto)
        viewModel.canSkip.send(false)
    }

    fileprivate func showCaptureBackDocument() {
        images = [images.first!] // swiftlint:disable:this force_unwrapping
        configureTexts(screenTitle: "verify-document.title.id-document-authentication".podLocalized(),
                       frameNote: "verify-document.frame-note".podLocalized(),
                       actionTitle: "verify-document.action.back-card.title".podLocalized(),
                       actionDescription: "verify-document.action.back-card.description".podLocalized(),
                       okButtonTitle: "verify-document.ok-button.title".podLocalized(),
                       retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
        viewModel.state.send(.captureBackPhoto)
        viewModel.canSkip.send(true)
    }

    fileprivate func showCaptureSelfie() {
        selfie = nil
        configureTexts(screenTitle: "verify-document.title.selfie".podLocalized(),
                       frameNote: nil,
                       actionTitle: nil,
                       actionDescription: "verify-document.action.selfie.description".podLocalized(),
                       okButtonTitle: "verify-document.ok-button-selfie.title".podLocalized(),
                       retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
        viewModel.state.send(.captureSelfie)
        viewModel.canSkip.send(false)
    }

    fileprivate func showCheckFrontDocument(image: UIImage) {
        configureTexts(screenTitle: "verify-document.title.id-document-authentication".podLocalized(),
                       frameNote: nil,
                       actionTitle: "verify-document.action.check-readability.title".podLocalized(),
                       actionDescription: "verify-document.action.check-readability.description".podLocalized(),
                       okButtonTitle: "verify-document.ok-button.title".podLocalized(),
                       retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
        viewModel.state.send(.checkFrontPhoto(image))
    }

    fileprivate func showCheckBackDocument(image: UIImage) {
        configureTexts(screenTitle: "verify-document.title.id-document-authentication".podLocalized(),
                       frameNote: nil,
                       actionTitle: "verify-document.action.check-readability.title".podLocalized(),
                       actionDescription: "verify-document.action.check-readability.description".podLocalized(),
                       okButtonTitle: "verify-document.ok-button.title".podLocalized(),
                       retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
        viewModel.state.send(.checkBackPhoto(image))
    }

    fileprivate func showCheckSelfieDocument(image: UIImage) {
        configureTexts(screenTitle: "verify-document.title.selfie".podLocalized(),
                       frameNote: nil,
                       actionTitle: nil,
                       actionDescription: nil,
                       okButtonTitle: "verify-document.ok-button-selfie.title".podLocalized(),
                       retakeButtonTitle: "verify-document.retake-button.title".podLocalized())
        viewModel.state.send(.checkSelfie(image))
    }

    // swiftlint:disable:next function_parameter_count
    fileprivate func configureTexts(screenTitle: String?,
                                    frameNote: String?,
                                    actionTitle: String?,
                                    actionDescription: String?,
                                    okButtonTitle: String?,
                                    retakeButtonTitle: String?)
    {
        viewModel.frameNote.send(frameNote)
        viewModel.screenTitle.send(screenTitle)
        viewModel.actionTitle.send(actionTitle)
        viewModel.actionDescription.send(actionDescription)
        viewModel.okButtonTitle.send(okButtonTitle)
        viewModel.retakeButtonTitle.send(retakeButtonTitle)
    }
}
