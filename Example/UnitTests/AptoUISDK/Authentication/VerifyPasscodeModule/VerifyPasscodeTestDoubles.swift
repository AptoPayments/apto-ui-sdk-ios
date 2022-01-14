//
//  VerifyPasscodeTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

@testable import AptoSDK
@testable import AptoUISDK

class VerifyPasscodeModuleSpy: UIModuleSpy, VerifyPasscodeModuleProtocol {
    private(set) var showForgotPINCalled = false
    func showForgotPIN() {
        showForgotPINCalled = true
    }
}

class VerifyPasscodeInteractorSpy: VerifyPasscodeInteractorProtocol {
    private(set) var verifyCodeCalled = false
    private(set) var lastVerifyCode: String?
    func verify(code: String, callback _: @escaping Result<Bool, Never>.Callback) {
        verifyCodeCalled = true
        lastVerifyCode = code
    }
}

class VerifyPasscodeInteractorFake: VerifyPasscodeInteractorSpy {
    var nextVerifyCodeResult: Result<Bool, Never>?
    override func verify(code: String, callback: @escaping Result<Bool, Never>.Callback) {
        super.verify(code: code, callback: callback)
        if let result = nextVerifyCodeResult {
            callback(result)
        }
    }
}

class VerifyPasscodePresenterSpy: VerifyPasscodePresenterProtocol {
    let viewModel = VerifyPasscodeViewModel()
    var interactor: VerifyPasscodeInteractorProtocol?
    var router: VerifyPasscodeModuleProtocol?
    var analyticsManager: AnalyticsServiceProtocol?

    private(set) var viewLoadedCalled = false
    func viewLoaded() {
        viewLoadedCalled = true
    }

    private(set) var pinEnteredCalled = false
    private(set) var lastPinEnteredCode: String?
    func pinEntered(_ code: String) {
        pinEnteredCalled = true
        lastPinEnteredCode = code
    }

    private(set) var forgotPINTappedCalled = false
    func forgotPINTapped() {
        forgotPINTappedCalled = true
    }
}
