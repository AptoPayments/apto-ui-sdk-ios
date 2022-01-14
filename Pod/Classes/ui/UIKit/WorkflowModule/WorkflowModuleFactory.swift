//
//  WorkflowModuleFactory.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 15/11/2017.
//

import AptoSDK
import UIKit

protocol WorkflowModuleFactory {
    func getModuleFor(workflowAction: WorkflowAction) -> UIModuleProtocol?
}

class WorkflowModuleFactoryImpl: WorkflowModuleFactory {
    let serviceLocator: ServiceLocatorProtocol
    let workflowObject: WorkflowObject
    private let initializationData: InitializationData?

    init(serviceLocator: ServiceLocatorProtocol,
         workflowObject: WorkflowObject,
         initializationData: InitializationData?)
    {
        self.serviceLocator = serviceLocator
        self.workflowObject = workflowObject
        self.initializationData = initializationData
    }

    // swiftlint:disable:next cyclomatic_complexity
    func getModuleFor(workflowAction: WorkflowAction) -> UIModuleProtocol? {
        switch workflowAction.actionType {
        case .showGenericMessage:
            return ShowGenericMessageModule(serviceLocator: serviceLocator, showGenericMessageAction: workflowAction)
        case .collectUserData:
            guard let config = workflowAction.configuration as? CollectUserDataActionConfiguration else {
                fatalError("Wrong configuration for collectUserData action.")
            }
            return serviceLocator.moduleLocator.userDataCollectorModule(userRequiredData: config.requiredDataPointsList,
                                                                        mode: .continueFlow,
                                                                        backButtonMode: .back)
        case .issueCard:
            guard var application = workflowObject as? CardApplication else {
                return nil
            }
            application.nextAction = workflowAction
            return serviceLocator
                .moduleLocator
                .issueCardModule(application: application, initializationData: initializationData)
        case .selectBalanceStore:
            guard var application = workflowObject as? CardApplication else {
                return nil
            }
            application.nextAction = workflowAction
            return serviceLocator.moduleLocator.selectBalanceStoreModule(application: application)
        case .showDisclaimer:
            guard workflowAction.configuration is Content else {
                return nil
            }
            return serviceLocator.moduleLocator.showDisclaimerActionModule(workflowObject: workflowObject,
                                                                           workflowAction: workflowAction)
        case .verifyIDDocument:
            return serviceLocator.moduleLocator.verifyDocumentModule(workflowObject: workflowObject)
        case .waitList:
            guard var application = workflowObject as? CardApplication else {
                return nil
            }
            application.nextAction = workflowAction
            return serviceLocator.moduleLocator.waitListModule(application: application)
        case .notSupportedActionType:
            return notSupportedActionModule()
        }
    }

    fileprivate func notSupportedActionModule() -> UIModule {
        return UIModule(serviceLocator: serviceLocator)
    }
}
