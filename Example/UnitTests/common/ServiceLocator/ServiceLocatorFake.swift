//
//  ServiceLocatorFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/06/2018.
//
//

@testable import AptoSDK
@testable import AptoUISDK

class ServiceLocatorFake: AptoUISDK.ServiceLocatorProtocol {
    lazy var moduleLocator: ModuleLocatorProtocol = moduleLocatorFake
    lazy var moduleLocatorFake = ModuleLocatorFake(serviceLocator: self)

    lazy var presenterLocator: PresenterLocatorProtocol = presenterLocatorFake
    lazy var presenterLocatorFake = PresenterLocatorFake()

    lazy var interactorLocator: InteractorLocatorProtocol = interactorLocatorFake
    lazy var interactorLocatorFake = InteractorLocatorFake()

    lazy var viewLocator: ViewLocatorProtocol = ViewLocatorFake()

    lazy var systemServicesLocator: SystemServicesLocatorProtocol = systemServicesLocatorFake
    lazy var systemServicesLocatorFake = SystemServicesLocatorFake()

    private(set) var platformFake = AptoPlatformFake()
    var platform: AptoPlatformProtocol {
        return platformFake
    }

    var uiConfig: UIConfig! = UIConfig(projectConfiguration: ModelDataProvider.provider.projectConfiguration)

    lazy var analyticsManagerSpy = AnalyticsManagerSpy()
    var analyticsManager: AnalyticsServiceProtocol {
        return analyticsManagerSpy
    }

    lazy var notificationHandlerFake = NotificationHandlerFake()
    lazy var notificationHandler: NotificationHandler = notificationHandlerFake
}

// Session configuration methods
extension ServiceLocatorFake {
    func setUpSessionForContextConfigurationSuccess() {
        let dataProvider = ModelDataProvider.provider
        let contextConfiguration = ContextConfiguration(teamConfiguration: dataProvider.teamConfig,
                                                        projectConfiguration: dataProvider.projectConfiguration)
        platformFake.nextFetchContextConfigurationResult = .success(contextConfiguration)
    }

    func setUpSessionForContextConfigurationFailure() {
        platformFake.nextFetchContextConfigurationResult = .failure(defaultError())
    }

    func setUpSessionForLoginUserWithVerificationSuccess() {
        platformFake.nextLoginUserResult = .success(ModelDataProvider.provider.user)
    }

    func setUpSessionForLoginUserWithVerificationFailure() {
        platformFake.nextLoginUserResult = .failure(defaultError())
    }

    func setUpSessionForCreateUserSuccess() {
        platformFake.nextCreateUserResult = .success(ModelDataProvider.provider.user)
    }

    func setUpSessionForCreateUserFailure() {
        platformFake.nextCreateUserResult = .failure(defaultError())
    }

    private func defaultError() -> NSError {
        return NSError(domain: "com.aptopayments.error", code: 1)
    }
}
