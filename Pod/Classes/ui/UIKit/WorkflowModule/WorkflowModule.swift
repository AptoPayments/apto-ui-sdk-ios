//
//  WorkflowModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/11/2017.
//

import UIKit
import AptoSDK

class WorkflowModule: UIModule {

  let workflowObjectStatusRequester: WorkflowObjectStatusRequester
  let workflowObject: WorkflowObject
  let workflowModuleFactory: WorkflowModuleFactory
  var lastResult: Any?

  // MARK: - Initializers

  init(serviceLocator: ServiceLocatorProtocol,
       workflowObject: WorkflowObject,
       workflowObjectStatusRequester: WorkflowObjectStatusRequester,
       workflowModuleFactory: WorkflowModuleFactory) {
    self.workflowObject = workflowObject
    self.workflowObjectStatusRequester = workflowObjectStatusRequester
    self.workflowModuleFactory = workflowModuleFactory

    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let module = self.moduleFor(workflowAction: workflowObject.nextAction)
    guard let safeModule = module else {
      completion(.failure(ServiceError(code: .internalIncosistencyError)))
      return
    }
    safeModule.onClose = { [unowned self] _ in
      self.close()
    }
    addChild(module: safeModule, completion: completion)
  }

  // MARK: - Private methods

  fileprivate func moduleFor(workflowAction: WorkflowAction) -> UIModuleProtocol? {
    guard let module = self.workflowModuleFactory.getModuleFor(workflowAction: workflowAction) else {
      return nil
    }
    module.onNext = { [unowned self] _ in
      self.handleNextAction()
    }
    module.onFinish = { [unowned self] moduleResult in
      self.lastResult = moduleResult.result
      self.handleNextAction()
    }

    return module
  }

  fileprivate func nextModuleFor(workflowObject: WorkflowObject,
                                 completion: @escaping(Result<UIModuleProtocol?, NSError>.Callback)) {
    nextActionFor(workflowObject: workflowObject) { [weak self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
        return
      case .success(let nextAction):
        completion(.success(self?.workflowModuleFactory.getModuleFor(workflowAction: nextAction)))
      }
    }
  }

  private func handleNextAction() {
    nextActionFor(workflowObject: workflowObject) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.show(error: error)
      case .success(let nextAction):
        if let module = self.moduleFor(workflowAction: nextAction) {
          if let configuration = nextAction.configuration, configuration.presentationMode == .modal {
            module.onFinish = { [unowned self] moduleResult in
              self.lastResult = moduleResult.result
              self.dismissModule { self.handleNextAction() }
            }
            module.onClose = { [unowned self] _ in
              self.dismissModule {}
            }
            self.present(module: module) { _ in }
          }
          else {
            module.onClose = { [unowned self] _ in
              self.popModule {}
            }
            self.push(module: module) { _ in }
          }
        }
      }
    }
  }

  fileprivate func nextActionFor(workflowObject: WorkflowObject,
                                 completion: @escaping(Result<WorkflowAction, NSError>.Callback)) {
    workflowObjectStatusRequester.getStatusOf(workflowObject: workflowObject) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let workflowObject):
        completion(.success(workflowObject.nextAction))
      }
    }
  }

}
