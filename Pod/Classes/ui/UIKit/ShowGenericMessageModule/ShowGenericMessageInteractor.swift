//
//  ShowGenericMessageInteractor.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import Foundation
import AptoSDK

protocol ShowGenericMessageDataReceiver {
  func set(title: String, content: Content?, callToAction: CallToAction?)
}

class ShowGenericMessageInteractor: ShowGenericMessageInteractorProtocol {
  private let showGenericMessageAction: WorkflowAction
  private let dataReceiver: ShowGenericMessageDataReceiver

  init(showGenericMessageAction: WorkflowAction, dataReceiver: ShowGenericMessageDataReceiver) {
    self.showGenericMessageAction = showGenericMessageAction
    self.dataReceiver = dataReceiver
  }

  func provideContent() {
    guard let actionConfig = showGenericMessageAction.configuration as? ShowGenericMessageActionConfiguration else {
      // This shouldn't happen
      return
    }
    dataReceiver.set(title: actionConfig.title, content: actionConfig.content, callToAction: actionConfig.callToAction)
  }
}
