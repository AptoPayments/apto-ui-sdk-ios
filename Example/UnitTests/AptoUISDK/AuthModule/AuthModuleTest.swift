//
//  AuthModuleTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/06/2018.
//
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class AuthModuleTest: XCTestCase {
    private var sut: AuthModule! // swiftlint:disable:this implicitly_unwrapped_optional
    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private let dataProvider = ModelDataProvider.provider
    private lazy var authModuleConfig = AuthModuleConfig(primaryAuthCredential: .phoneNumber,
                                                         secondaryAuthCredential: .email,
                                                         allowedCountries: [dataProvider.usa], mode: .embedded)
    private lazy var uiConfig: UIConfig = dataProvider.uiConfig
    private lazy var initialUserData: DataPointList = dataProvider.phoneNumberDataPointList

    override func setUp() {
        super.setUp()

        sut = AuthModule(serviceLocator: serviceLocator,
                         config: authModuleConfig,
                         initialUserData: initialUserData,
                         initializationData: dataProvider.initializationData)
    }

    func testInitializeConfigurePresenter() {
        // Given
        let presenter = serviceLocator.presenterLocatorFake.authPresenter(authConfig: authModuleConfig,
                                                                          uiConfig: uiConfig)

        // When
        sut.initialize { _ in }

        // Then
        XCTAssertNotNil(presenter.interactor)
        XCTAssertNotNil(presenter.viewController)
        XCTAssertNotNil(presenter.router)
        XCTAssertNotNil(presenter.analyticsManager)
    }

    func testReturnExistingUserWithDataCallCompletion() {
        // Given
        var returnedUserData: AptoUser?
        sut.onExistingUser = { _, userData in
            returnedUserData = userData
        }
        let user = AptoUser(userId: "userId",
                            metadata: "metadata",
                            accessToken: AccessToken(token: "token",
                                                     primaryCredential: .phoneNumber,
                                                     secondaryCredential: .email))

        // When
        sut.returnExistingUser(user)

        // Then
        XCTAssertEqual(user, returnedUserData)
    }

    func testPresentPhoneVerificationConfigureVerifyPhoneModule() {
        // Given
        let verificationParams = VerificationParams.datapoint(PhoneNumber())
        let verifyPhoneModule = serviceLocator.moduleLocatorFake.verifyPhoneModuleSpy

        // When
        sut.presentPhoneVerification(verificationType: verificationParams, completion: nil)

        // Then
        XCTAssertNotNil(verifyPhoneModule.onVerificationPassed)
        XCTAssertNotNil(verifyPhoneModule.onClose)
        XCTAssertTrue(verifyPhoneModule.initializeCalled)
    }

    func testPresentEmailVerificationConfigureVerifyEmailModule() {
        // Given
        let verificationParams = VerificationParams.datapoint(Email())
        let verifyEmailModule = serviceLocator.moduleLocatorFake.verifyEmailModuleSpy

        // When
        sut.presentEmailVerification(verificationType: verificationParams, completion: nil)

        // Then
        XCTAssertNotNil(verifyEmailModule.onVerificationPassed)
        XCTAssertNotNil(verifyEmailModule.onClose)
        XCTAssertTrue(verifyEmailModule.initializeCalled)
    }

    func testPresentBirthDateVerificationConfigureVerifyBirthDateModule() {
        // Given
        let verification = VerificationParams.datapoint(BirthDate())
        let verifyBirthDataModule = serviceLocator.moduleLocatorFake.verifyBirthDateModuleSpy

        // When
        sut.presentBirthdateVerification(verificationType: verification, completion: nil)

        // Then
        XCTAssertNotNil(verifyBirthDataModule.onVerificationPassed)
        XCTAssertNotNil(verifyBirthDataModule.onClose)
        XCTAssertTrue(verifyBirthDataModule.initializeCalled)
    }
}
