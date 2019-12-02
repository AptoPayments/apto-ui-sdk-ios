//
//  ChangePINModule.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 28/11/2019.
//

import Foundation
import AptoSDK

class ChangePINModule: UIModule, ChangePINModuleProtocol {
  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let verifyPINModule = serviceLocator.moduleLocator.verifyPINModule()
    verifyPINModule.onFinish = { [unowned self] _ in
      self.showCreatePINModule { [unowned self] in
        self.finish()
      }
    }
    addChild(module: verifyPINModule, completion: completion)
  }

  private func showCreatePINModule(_ completion: @escaping () -> Void) {
    let createPINModule = serviceLocator.moduleLocator.createPINModule()
    createPINModule.onFinish = { [unowned self] _ in
      self.dismissModule(animated: false) {}
      completion()
    }
    present(module: createPINModule, animated: false) { _ in }
  }
}
