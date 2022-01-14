//
// PhysicalCardActivationContract.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-10.
//

import AptoSDK
import Bond
import Foundation

protocol PhysicalCardActivationInteractorProtocol: AnyObject {
    func fetchCard(callback: @escaping Result<Card, NSError>.Callback)
    func fetchUpdatedCard(callback: @escaping Result<Card?, NSError>.Callback)
    func fetchCurrentUser(callback: @escaping Result<AptoUser, NSError>.Callback)
    func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback)
}

protocol PhysicalCardActivationPresenterProtocol: AnyObject {
    var viewModel: PhysicalCardActivationViewModel { get }
    var router: PhysicalCardActivationModuleProtocol? { get set }
    var interactor: PhysicalCardActivationInteractorProtocol? { get set }
    var analyticsManager: AnalyticsServiceProtocol? { get set }

    func viewLoaded()
    func activateCardTapped()
    func show(url: URL)
}

protocol PhysicalCardActivationModuleProtocol: UIModuleProtocol {
    func show(url: URL)
    func call(url: URL, completion: @escaping () -> Void)
    func cardActivationFinish()
}

class PhysicalCardActivationViewModel {
    public let cardHolder: Observable<String?> = Observable(nil)
    public let cardNetwork: Observable<CardNetwork?> = Observable(nil)
    public let cardStyle: Observable<CardStyle?> = Observable(nil)
    public let address: Observable<Address?> = Observable(nil)
}
