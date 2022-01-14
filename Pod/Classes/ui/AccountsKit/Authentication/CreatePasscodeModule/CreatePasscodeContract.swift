//
//  CreatePasscodeModuleModuleContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import AptoSDK
import Bond

protocol CreatePasscodeModuleProtocol: UIModuleProtocol {}

protocol CreatePasscodeInteractorProtocol {
    func save(code: String, callback: @escaping Result<Void, NSError>.Callback)
}

class CreatePasscodeViewModel {
    let error: Observable<NSError?> = Observable(nil)
}

protocol CreatePasscodePresenterProtocol: AnyObject {
    var router: CreatePasscodeModuleProtocol? { get set }
    var interactor: CreatePasscodeInteractorProtocol? { get set }
    var viewModel: CreatePasscodeViewModel { get }
    var analyticsManager: AnalyticsServiceProtocol? { get set }

    func viewLoaded()
    func closeTapped()
    func pinEntered(_ code: String)
}
