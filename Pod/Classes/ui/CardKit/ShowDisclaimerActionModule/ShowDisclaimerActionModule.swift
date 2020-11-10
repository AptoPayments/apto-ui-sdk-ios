//
//  ShowDisclaimerActionModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/06/2018.
//
//

import UIKit
import AptoSDK

protocol ShowDisclaimerActionModuleProtocol: UIModuleProtocol {
}

class ShowDisclaimerActionModule: UIModule, ShowDisclaimerActionModuleProtocol {
  private let workflowObject: WorkflowObject
  private let workflowAction: WorkflowAction
  private let disclaimer: Content
  private let actionConfirmer: ActionConfirmer.Type
  private let analyticsManager: AnalyticsServiceProtocol?

  init(serviceLocator: ServiceLocatorProtocol,
       workflowObject: WorkflowObject,
       workflowAction: WorkflowAction,
       actionConfirmer: ActionConfirmer.Type,
       analyticsManager: AnalyticsServiceProtocol?) {
    guard let disclaimer = workflowAction.configuration as? Content else {
      fatalError("Wrong workflow action")
    }
    self.workflowObject = workflowObject
    self.workflowAction = workflowAction
    self.disclaimer = disclaimer
    self.actionConfirmer = actionConfirmer
    self.analyticsManager = analyticsManager
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping (Result<UIViewController, NSError>) -> Void) {
    let module = buildFullScreenDisclaimerModule()
    addChild(module: module, completion: completion)
  }

  private func buildFullScreenDisclaimerModule() -> FullScreenDisclaimerModuleProtocol {
    let module = serviceLocator.moduleLocator.fullScreenDisclaimerModule(disclaimer: disclaimer)
    module.onClose = { [unowned self] _ in
      self.confirmClose {[unowned self] in
        self.close()
      }
    }
    module.onDisclaimerAgreed = disclaimerAgreed
    return module
  }

  private func disclaimerAgreed(module: UIModuleProtocol) {
    analyticsManager?.track(event: Event.disclaimerAcceptTap, properties: ["action_id": workflowAction.actionId ?? ""])
    showLoadingSpinner()
    platform.acceptDisclaimer(workflowObject: workflowObject, workflowAction: workflowAction) { [weak self] result in
      guard let self = self else { return }
      self.hideLoadingSpinner()
      switch result {
      case .failure(let error):
        self.show(error: error)
      case .success:
        self.finish()
      }
    }
  }

  private func confirmClose(onConfirm: @escaping () -> Void) {
    analyticsManager?.track(event: Event.disclaimerRejectTap, properties: ["action_id": workflowAction.actionId ?? ""])
    if let cardApplication = self.workflowObject as? CardApplication {
      let cancelTitle = "disclaimer.disclaimer.cancel_action.cancel_button".podLocalized()
      actionConfirmer.confirm(title: "disclaimer.disclaimer.cancel_action.title".podLocalized(),
                              message: "disclaimer.disclaimer.cancel_action.message".podLocalized(),
                              okTitle: "disclaimer.disclaimer.cancel_action.ok_button".podLocalized(),
                              cancelTitle: cancelTitle) { [unowned self] action in
        guard let title = action.title, title != cancelTitle else {
          return
        }
        self.showLoadingSpinner()
        self.platform.cancelCardApplication(cardApplication.id) { [unowned self] _ in
          self.hideLoadingSpinner()
          onConfirm()
          self.serviceLocator.notificationHandler.postNotification(.UserTokenSessionClosedNotification)
        }
      }
    }
    else {
      onConfirm()
    }
  }
}
