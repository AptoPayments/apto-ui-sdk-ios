//
//  AuthenticationManagerTest.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/11/2019.
//

@testable import AptoSDK
@testable import AptoUISDK
import XCTest

class AuthenticationManagerTest: XCTestCase {
    private var sut: AuthenticationManager! // swiftlint:disable:this implicitly_unwrapped_optional

    // Collaborators
    private let serviceLocator = ServiceLocatorFake()
    private lazy var systemServiceLocator = serviceLocator.systemServicesLocatorFake
    private lazy var fileManager = systemServiceLocator.fileManagerFake
    private lazy var dateProvider = systemServiceLocator.dateProviderFake
    private lazy var aptoPlatform = serviceLocator.platformFake
    private let authenticator = AuthenticatorFake()
    private let code = "1111"

    override func setUp() {
        super.setUp()
        sut = AuthenticationManager(fileManager: fileManager, dateProvider: dateProvider, aptoPlatform: aptoPlatform,
                                    authenticator: authenticator)
    }

    // MARK: - biometry type

    func testBiometryTypesReturnsAuthenticatorValue() {
        // Given
        let allTypes = BiometryType.allCases

        allTypes.forEach { type in
            // When
            authenticator.biometryType = type

            // Then
            XCTAssertEqual(type, sut.biometryType)
        }
    }

    // MARK: - should request biometric permission

    func testIsBiometricEnabledByUserReturnTrue() {
        // Given
        aptoPlatform.nextIsBiometricEnabledResult = true

        // When
        let shouldRequestPermission = sut.shouldRequestBiometricPermission

        // Then
        XCTAssertFalse(shouldRequestPermission)
    }

    func testBiometryTypeIsNoneReturnFalse() {
        // Given
        aptoPlatform.nextIsBiometricEnabledResult = false
        authenticator.biometryType = .none

        // When
        let shouldRequestPermission = sut.shouldRequestBiometricPermission

        // Then
        XCTAssertFalse(shouldRequestPermission)
    }

    func testBiometricTypeNotNoneBiometricAvailableReturnsTrue() {
        // Given
        aptoPlatform.nextIsBiometricEnabledResult = false
        authenticator.biometryType = .faceID
        authenticator.isBiometryAvailable = true

        // When
        let shouldRequestPermission = sut.shouldRequestBiometricPermission

        // Then
        XCTAssertTrue(shouldRequestPermission)
    }

    func testBiometricTypeNotNoneBiometricNotAvailableReturnsFalse() {
        // Given
        aptoPlatform.nextIsBiometricEnabledResult = false
        authenticator.biometryType = .faceID
        authenticator.isBiometryAvailable = false

        // When
        let shouldRequestPermission = sut.shouldRequestBiometricPermission

        // Then
        XCTAssertFalse(shouldRequestPermission)
    }

    // MARK: - Save code

    func testSaveCallFileManager() {
        // When
        _ = sut.save(code: code)

        // Then
        XCTAssertTrue(fileManager.saveCalled)
    }

    func testSaveFileDoNotThrowReturnSuccess() {
        // Given
        fileManager.shouldThrow = false

        // When
        let result = sut.save(code: code)

        // Then
        XCTAssertTrue(result.isSuccess)
    }

    func testSaveThrowErrorReturnError() {
        // Given
        fileManager.shouldThrow = true

        // When
        let result = sut.save(code: code)

        // Then
        XCTAssertTrue(result.isFailure)
        XCTAssertTrue(result.error is PINSaveError)
    }

    // MARK: - Code exists

    func testNotCodeCodeExistsReturnFalse() {
        // When
        let codeExists = sut.codeExists()

        // Then
        XCTAssertFalse(codeExists)
    }

    func testFileManagerThrowReturnFalse() {
        // Given
        fileManager.shouldThrow = true

        // When
        let codeExists = sut.codeExists()

        // Then
        XCTAssertFalse(codeExists)
    }

    func testCodeSavedCodeExistsReturnTrue() {
        // Given
        _ = sut.save(code: code)

        // When
        let codeExists = sut.codeExists()

        // Then
        XCTAssertTrue(codeExists)
    }

    // MARK: - Is code valid

    func testNoCodeIsValidReturnFalse() {
        // When
        let isValid = sut.isValid(code: code)

        // Then
        XCTAssertFalse(isValid)
    }

    func testCodeSavedIsDifferentCodeValidReturnFalse() {
        // Given
        _ = sut.save(code: code)

        // When
        let isValid = sut.isValid(code: "abcd")

        // Then
        XCTAssertFalse(isValid)
    }

    func testCodeSavedIsSameCodeValidReturnTrue() {
        // Given
        _ = sut.save(code: code)

        // When
        let isValid = sut.isValid(code: code)

        // Then
        XCTAssertTrue(isValid)
    }

    // MARK: - Should create code

    func testCodeExistsShouldCreateCodeReturnFalse() {
        // Given
        _ = sut.save(code: code)

        // When
        let shouldCreateCode = sut.shouldCreateCode()

        // Then
        XCTAssertFalse(shouldCreateCode)
    }

    func testCodeDoNotExistsAuthenticateOnStartUpEnabledShouldCreateCodeReturnTrue() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: true]))

        // When
        let shouldCreateCode = sut.shouldCreateCode()

        // Then
        XCTAssertTrue(shouldCreateCode)
    }

    func testCodeDoNotExistsAuthenticateWithPINOnPCIEnabledShouldCreateCodeReturnTrue() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: false], authenticateOnPCI: .pinOrBiometrics))

        // When
        let shouldCreateCode = sut.shouldCreateCode()

        // Then
        XCTAssertTrue(shouldCreateCode)
    }

    func testCodeDoNotExistsAuthenticationFlagsDisabledShouldCreateCodeReturnFalse() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: false], authenticateOnPCI: .biometrics))

        // When
        let shouldCreateCode = sut.shouldCreateCode()

        // Then
        XCTAssertFalse(shouldCreateCode)
    }

    // MARK: - Can change code

    func testAuthenticateOnStartUpEnabledAndCodeExistsReturnTrue() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: true], authenticateOnPCI: .biometrics))
        _ = sut.save(code: code)

        // When
        let canChangeCode = sut.canChangeCode()

        // Then
        XCTAssertTrue(canChangeCode)
    }

    func testAuthenticateWithPINOnPCIEnabledAndCodeExistsReturnTrue() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: false], authenticateOnPCI: .pinOrBiometrics))
        _ = sut.save(code: code)

        // When
        let canChangeCode = sut.canChangeCode()

        // Then
        XCTAssertTrue(canChangeCode)
    }

    func testAuthenticateOnStartUpEnabledAndCodeDoNotExistsReturnFalse() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: true], authenticateOnPCI: .biometrics))

        // When
        let canChangeCode = sut.canChangeCode()

        // Then
        XCTAssertFalse(canChangeCode)
    }

    func testAuthenticateWithPINOnPCIEnabledAndCodeDoNotExistsReturnFalse() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: false], authenticateOnPCI: .pinOrBiometrics))

        // When
        let canChangeCode = sut.canChangeCode()

        // Then
        XCTAssertFalse(canChangeCode)
    }

    func testFeaturesDisabledAndDoNotCodeExistsReturnFalse() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: false], authenticateOnPCI: .biometrics))

        // When
        let canChangeCode = sut.canChangeCode()

        // Then
        XCTAssertFalse(canChangeCode)
    }

    func testFeaturesDisabledAndCodeExistsReturnFalse() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: false], authenticateOnPCI: .biometrics))
        _ = sut.save(code: code)

        // When
        let canChangeCode = sut.canChangeCode()

        // Then
        XCTAssertFalse(canChangeCode)
    }

    // MARK: - Should authenticate on start up

    func testAuthenticateOnOpenDisabledShouldAuthenticateReturnFalse() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: false]))

        // When
        let shouldAuthenticate = sut.shouldAuthenticateOnStartUp()

        // Then
        XCTAssertFalse(shouldAuthenticate)
    }

    func testNotCodeShouldAuthenticateReturnFalse() {
        // When
        let shouldAuthenticate = sut.shouldAuthenticateOnStartUp()

        // Then
        XCTAssertFalse(shouldAuthenticate)
    }

    func testCodeExistsNotPreviousAuthShouldAuthenticateReturnTrue() {
        // Given
        fileManager.nextReadResult = code.data(using: .utf8)

        // When
        let shouldAuthenticate = sut.shouldAuthenticateOnStartUp()

        // Then
        XCTAssertTrue(shouldAuthenticate)
    }

    func testCodeCreateLessThan60SecondsElapsedShouldAuthenticateReturnFalse() {
        // Given
        // swiftlint:disable:next force_unwrapping
        dateProvider.nextDateToProvide = Date.dateFromISO8601(string: "2019-02-11T17:17:00.000000+00:00")!
        _ = sut.save(code: code)

        // When
        // swiftlint:disable:next force_unwrapping
        dateProvider.nextDateToProvide = Date.dateFromISO8601(string: "2019-02-11T17:17:59.000000+00:00")!
        let shouldAuthenticate = sut.shouldAuthenticateOnStartUp()

        // Then
        XCTAssertFalse(shouldAuthenticate)
    }

    func testAlreadyAuthenticatedLessThan60SecondsElapsedShouldAuthenticateReturnFalse() {
        // Given
        // swiftlint:disable:next force_unwrapping
        dateProvider.nextDateToProvide = Date.dateFromISO8601(string: "2019-02-11T17:17:00.000000+00:00")!
        _ = sut.save(code: code)
        // swiftlint:disable:next force_unwrapping
        dateProvider.nextDateToProvide = Date.dateFromISO8601(string: "2019-02-11T17:20:00.000000+00:00")!
        _ = sut.isValid(code: code)

        // When
        // swiftlint:disable:next force_unwrapping
        dateProvider.nextDateToProvide = Date.dateFromISO8601(string: "2019-02-11T17:20:59.000000+00:00")!
        let shouldAuthenticate = sut.shouldAuthenticateOnStartUp()

        // Then
        XCTAssertFalse(shouldAuthenticate)
    }

    func testAlreadyAuthenticatedMoreThan60SecondsElapsedShouldAuthenticateReturnFalse() {
        // Given
        // swiftlint:disable:next force_unwrapping
        dateProvider.nextDateToProvide = Date.dateFromISO8601(string: "2019-02-11T17:17:00.000000+00:00")!
        _ = sut.save(code: code)
        // swiftlint:disable:next force_unwrapping
        dateProvider.nextDateToProvide = Date.dateFromISO8601(string: "2019-02-11T17:20:00.000000+00:00")!
        _ = sut.isValid(code: code)

        // When
        // swiftlint:disable:next force_unwrapping
        dateProvider.nextDateToProvide = Date.dateFromISO8601(string: "2019-02-11T17:21:01.000000+00:00")!
        let shouldAuthenticate = sut.shouldAuthenticateOnStartUp()

        // Then
        XCTAssertTrue(shouldAuthenticate)
    }

    // MARK: - Authenticate

    func testAuthenticateCallAuthenticator() {
        // Given
        let module = UIModuleSpy(serviceLocator: serviceLocator)

        // When
        sut.authenticate(from: module) { _ in }

        // Then
        XCTAssertTrue(authenticator.authenticateCalled)
    }

    func testAuthenticationSucceedCallbackAccessGranted() {
        // Given
        let module = UIModuleSpy(serviceLocator: serviceLocator)
        authenticator.nextAuthenticateResult = true

        // When
        sut.authenticate(from: module) { accessGranted in
            // Then
            XCTAssertTrue(accessGranted)
        }
    }

    func testAuthenticationFailsCallbackAccessDenied() {
        // Given
        let module = UIModuleSpy(serviceLocator: serviceLocator)
        authenticator.nextAuthenticateResult = false

        // When
        sut.authenticate(from: module) { accessGranted in
            // Then
            XCTAssertFalse(accessGranted)
        }
    }

    func testAuthenticateCalledTwiceWithDifferentModeCallAuthenticator() {
        // Given
        let module = UIModuleSpy(serviceLocator: serviceLocator)
        sut.authenticate(from: module, mode: .allAvailables) { _ in }
        authenticator.resetSpies()
        XCTAssertFalse(authenticator.authenticateCalled)

        // When
        sut.authenticate(from: module, mode: .biometry) { _ in }

        // Then
        XCTAssertTrue(authenticator.authenticateCalled)
    }

    func testAuthenticateCalledTwiceWithSameModeDoNotCallAuthenticatorTwice() {
        // Given
        let module = UIModuleSpy(serviceLocator: serviceLocator)
        sut.authenticate(from: module, mode: .allAvailables) { _ in }
        authenticator.resetSpies()
        XCTAssertFalse(authenticator.authenticateCalled)

        // When
        sut.authenticate(from: module, mode: .allAvailables) { _ in }

        // Then
        XCTAssertFalse(authenticator.authenticateCalled)
    }

    func testAuthenticateUsePasscodeIfBiometricIsDisabledByUser() {
        // Given
        aptoPlatform.setCardOptions(CardOptions(features: [.authenticateOnStartUp: true], authenticateOnPCI: .pinOrBiometrics))
        let module = UIModuleSpy(serviceLocator: serviceLocator)
        aptoPlatform.nextIsBiometricEnabledResult = false

        // When
        sut.authenticate(from: module, mode: .allAvailables) { _ in }

        // Then
        XCTAssertEqual(.passcode, authenticator.lastAuthenticationMode)
    }

    // MARK: - Invalidate current code

    func testInvalidateCurrentCodeDeleteLocalFile() {
        // When
        sut.invalidateCurrentCode()

        // Then
        XCTAssertTrue(fileManager.deleteCalled)
    }
}
