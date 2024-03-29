//
//  ExternalOAuthModuleTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 04/07/2018.
//
//

import AptoSDK
@testable import AptoUISDK

class ExternalOAuthPresenterSpy: ExternalOAuthPresenterProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    var router: ExternalOAuthRouterProtocol!
    var interactor: ExternalOAuthInteractorProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    private(set) var viewModel = ExternalOAuthViewModel()
    var analyticsManager: AnalyticsServiceProtocol?

    private(set) var viewLoadedCalled = false
    func viewLoaded() {
        viewLoadedCalled = true
    }

    private(set) var showErrorCalled = false
    private(set) var lastErrorShown: Error?
    func show(error: NSError) {
        showErrorCalled = true
        lastErrorShown = error
    }

    private(set) var showUrlCalled = false
    private(set) var lastUrlShown: URL?
    func show(url: URL) {
        showUrlCalled = true
        lastUrlShown = url
    }

    private(set) var newUserTappedCalled = false
    private(set) var lastNewUserURL: URL?
    func newUserTapped(url: URL) {
        newUserTappedCalled = true
        lastNewUserURL = url
    }

    private(set) var custodianSelectedCalled = false
    private(set) var lastCustodianSelected: Custodian?
    func custodianStatusUpdated(_ custodian: Custodian?) {
        custodianSelectedCalled = true
        lastCustodianSelected = custodian
    }

    private(set) var closeTappedCalled = false
    func closeTapped() {
        closeTappedCalled = true
    }

    private(set) var balanceTypeTappedCalled = false
    private(set) var lastBalanceTypeSelected: AllowedBalanceType?
    func balanceTypeTapped(_ balanceType: AllowedBalanceType) {
        balanceTypeTappedCalled = true
        lastBalanceTypeSelected = balanceType
    }
}

class ExternalOAuthModuleSpy: UIModuleSpy, ExternalOAuthModuleProtocol {
    var onOAuthSucceeded: ((_ externalOAuthModule: ExternalOAuthModuleProtocol, _ custodian: Custodian) -> Void)?

    override init(serviceLocator: ServiceLocatorProtocol) {
        super.init(serviceLocator: serviceLocator)
    }

    private(set) var backInExternalOAuthCalled = false
    private(set) var lastBackAnimated: Bool?
    func backInExternalOAuth(_ animated: Bool) {
        backInExternalOAuthCalled = true
        lastBackAnimated = animated
    }

    private(set) var oauthSucceededCalled = false
    private(set) var lastOauthCustodian: Custodian?
    func oauthSucceeded(_ custodian: Custodian) {
        oauthSucceededCalled = true
        lastOauthCustodian = custodian
    }

    private(set) var showUrlCalled = false
    private(set) var lastUrlShown: URL?
    private(set) var lastShowUrlCompletion: (() -> Void)?
    func show(url: URL, completion: @escaping () -> Void) {
        showUrlCalled = true
        lastUrlShown = url
        lastShowUrlCompletion = completion
    }

    func showLoadingSpinner() {
        showLoadingSpinner(position: .center)
    }
}

class ExternalOAuthModuleFake: ExternalOAuthModuleSpy {
    override func show(url: URL, completion: @escaping () -> Void) {
        super.show(url: url, completion: completion)

        completion()
    }

    override func oauthSucceeded(_ custodian: Custodian) {
        super.oauthSucceeded(custodian)

        onOAuthSucceeded?(self, custodian)
    }
}

class ExternalOAuthInteractorSpy: ExternalOAuthInteractorProtocol {
    var presenter: ExternalOAuthPresenterProtocol! // swiftlint:disable:this implicitly_unwrapped_optional

    private(set) var balanceTypeSelectedCalled = false
    private(set) var lastBalanceTypeSelected: AllowedBalanceType?
    func balanceTypeSelected(_ balanceType: AllowedBalanceType) {
        balanceTypeSelectedCalled = true
        lastBalanceTypeSelected = balanceType
    }

    private(set) var verifyOauthAttemptStatus = false
    private(set) var lastVerifyOAuthAttemptStatusCallback: ((Result<OauthAttempt, NSError>) -> Void)?
    func verifyOauthAttemptStatus(callback: @escaping (Result<OauthAttempt, NSError>) -> Void) {
        verifyOauthAttemptStatus = true
        lastVerifyOAuthAttemptStatusCallback = callback
    }
}

class ExternalOAuthInteractorFake: ExternalOAuthInteractorSpy {
    var nextVerifyOauthAttemptStatusResult: Result<OauthAttempt, NSError>?
    override func verifyOauthAttemptStatus(callback: @escaping (Result<OauthAttempt, NSError>) -> Void) {
        super.verifyOauthAttemptStatus(callback: callback)
        if let result = nextVerifyOauthAttemptStatusResult {
            callback(result)
        }
    }
}
