//
//  ShowGenericMessagePresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 17/02/16.
//
//

import Foundation
import AptoSDK

protocol ShowGenericMessageRouterProtocol {
  func close()
  func showExternal(url:URL, headers:[String:String]?, useSafari: Bool?, alternativeTitle: String?)
  func callToActionTapped()
  func secondaryCallToActionTapped()
}

protocol ShowGenericMessageInteractorProtocol {
  func provideContent()
}

protocol ShowGenericMessageViewProtocol {
  func set(title: String, logo: String?, content: Content?, callToAction: CallToAction?)
}

class ShowGenericMessagePresenter: ShowGenericMessageEventHandler, ShowGenericMessageDataReceiver {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ShowGenericMessageViewProtocol!
  var router: ShowGenericMessageRouterProtocol!
  var interactor: ShowGenericMessageInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional

  func viewLoaded() {
    interactor.provideContent()
  }

  func set(title: String, content: Content?, callToAction: CallToAction?) {
    view.set(title: title, logo: nil, content: content, callToAction: callToAction)
  }

  func callToActionTapped() {
    router.callToActionTapped()
  }

  func secondaryCallToActionTapped() {
    router.secondaryCallToActionTapped()
  }

  func closeTapped() {
    router.close()
  }

  func linkTapped(_ url:URL) {
    router.showExternal(url:url, headers:nil, useSafari: false, alternativeTitle: nil)
  }
}
