//
//  PhysicalCardActivationSucceedTestDoubles.swift
//  ShifSDK
//
//  Created by Takeichi Kanzaki on 22/10/2018.
//

import AptoSDK
@testable import AptoUISDK

class PhysicalCardActivationSucceedPresenterSpy: PhysicalCardActivationSucceedPresenterProtocol {
    let viewModel = PhysicalCardActivationSucceedViewModel()
    // swiftlint:disable implicitly_unwrapped_optional
    var interactor: PhysicalCardActivationSucceedInteractorProtocol!
    weak var router: PhysicalCardActivationSucceedRouter!
    // swiftlint:enable implicitly_unwrapped_optional
    var analyticsManager: AnalyticsServiceProtocol?

    private(set) var viewLoadedCalled = false
    func viewLoaded() {
        viewLoadedCalled = true
    }

    private(set) var getPinTappedCalled = false
    func getPinTapped() {
        getPinTappedCalled = true
    }

    private(set) var closeTappedCalled = false
    func closeTapped() {
        closeTappedCalled = true
    }
}

class PhysicalCardActivationSucceedInteractorSpy: PhysicalCardActivationSucceedInteractorProtocol {
    var card = ModelDataProvider.provider.cardWithIVR

    private(set) var provideCardCalled = false
    func provideCard(callback _: (_ card: Card) -> Void) {
        provideCardCalled = true
    }
}

class PhysicalCardActivationSucceedInteractorFake: PhysicalCardActivationSucceedInteractorSpy {
    override func provideCard(callback: (_ card: Card) -> Void) {
        super.provideCard(callback: callback)
        callback(card)
    }
}

class PhysicalCardActivationSucceedModuleSpy: UIModuleSpy, PhysicalCardActivationSucceedModuleProtocol {
    var activationCompletion: (() -> Void)?

    private(set) var callURLCalled = false
    func call(url _: URL, completion _: () -> Void) {
        callURLCalled = true
    }

    private(set) var showSetPinCalled = false
    func showSetPin() {
        showSetPinCalled = true
    }

    private(set) var showVoIPCalled = false
    func showVoIP() {
        showVoIPCalled = true
    }

    private(set) var getPinFinishedCalled = false
    func getPinFinished() {
        getPinFinishedCalled = true
    }
}

class PhysicalCardActivationSucceedModuleFake: PhysicalCardActivationSucceedModuleSpy {
    override func call(url: URL, completion: () -> Void) {
        super.call(url: url, completion: completion)
        completion()
    }
}
