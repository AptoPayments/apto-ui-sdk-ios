//
//  AuthenticationManagerFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 25/11/2019.
//

@testable import AptoUISDK

class AuthenticationManagerFake: AuthenticationManagerProtocol {
    var biometryType: BiometryType = .none
    var shouldRequestBiometricPermission: Bool = false

    private(set) var saveCalled = false
    private(set) var lastSaveCode: String?
    var nextSaveResult: Result<Void, NSError> = .failure(NSError(domain: "com.aptopayments", code: 1, userInfo: nil))
    func save(code: String) -> Result<Void, NSError> {
        saveCalled = true
        lastSaveCode = code
        return nextSaveResult
    }

    private(set) var codeExistsCalled = false
    var nextCodeExistsResult = false
    func codeExists() -> Bool {
        codeExistsCalled = true
        return nextCodeExistsResult
    }

    private(set) var isValidCalled = false
    private(set) var lastIsValidCode: String?
    var nextIsValidResult = false
    func isValid(code: String) -> Bool {
        isValidCalled = true
        lastIsValidCode = code
        return nextIsValidResult
    }

    private(set) var shouldCreateCodeCalled = false
    var nextShouldCreateCodeResult = false
    func shouldCreateCode() -> Bool {
        shouldCreateCodeCalled = true
        return nextShouldCreateCodeResult
    }

    private(set) var canChangeCodeCalled = false
    var nextCanChangeCodeResult = false
    func canChangeCode() -> Bool {
        canChangeCodeCalled = true
        return nextCanChangeCodeResult
    }

    private(set) var shouldRequestCodeCalled = false
    var nextShouldAuthenticateOnStartUpResult = false
    func shouldAuthenticateOnStartUp() -> Bool {
        shouldRequestCodeCalled = true
        return nextShouldAuthenticateOnStartUpResult
    }

    private(set) var authenticateCalled = false
    private(set) var lastAuthenticateMode: AuthenticationMode?
    var nextAuthenticateResult = true
    func authenticate(from _: UIModuleProtocol, mode: AuthenticationMode, completion: @escaping (Bool) -> Void) {
        authenticateCalled = true
        lastAuthenticateMode = mode
        completion(nextAuthenticateResult)
    }

    private(set) var invalidateCurrentCodeCalled = false
    func invalidateCurrentCode() {
        invalidateCurrentCodeCalled = true
    }

    func authenticateOnStartup(from _: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func requestBiometricPermission(from _: UIModuleProtocol, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
