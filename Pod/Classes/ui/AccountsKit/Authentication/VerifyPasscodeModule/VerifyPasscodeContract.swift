//
//  VerifyPasscodeContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 26/11/2019.
//

import AptoSDK
import Bond

protocol VerifyPasscodeModuleProtocol: UIModuleProtocol {
    func showForgotPIN()
}

protocol VerifyPasscodeInteractorProtocol {
    func verify(code: String, callback: @escaping Result<Bool, Never>.Callback)
}

class VerifyPasscodeViewModel {
    let logoURL: Observable<String?> = Observable(nil)
    let error: Observable<NSError?> = Observable(nil)
}

struct VerifyPasscodePresenterConfig {
    let logoURL: String?
}

protocol VerifyPasscodePresenterProtocol: AnyObject {
    var router: VerifyPasscodeModuleProtocol? { get set }
    var interactor: VerifyPasscodeInteractorProtocol? { get set }
    var viewModel: VerifyPasscodeViewModel { get }
    var analyticsManager: AnalyticsServiceProtocol? { get set }

    func viewLoaded()
    func pinEntered(_ code: String)
    func forgotPINTapped()
}

class WrongPINError: NSError {
    init() {
        let errorMessage = "biometric.verify_pin.error.wrong_pin".podLocalized()
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: errorMessage]
        super.init(domain: "com.aptopayments.sdk.error.save_file", code: 1002, userInfo: userInfo)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
