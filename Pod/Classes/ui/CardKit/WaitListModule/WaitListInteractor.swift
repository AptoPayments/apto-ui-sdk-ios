//
//  WaitListInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 27/02/2019.
//

import AptoSDK

class WaitListInteractor: WaitListInteractorProtocol {
    private let application: CardApplication
    private let platform: AptoPlatformProtocol

    init(application: CardApplication, platform: AptoPlatformProtocol) {
        self.application = application
        self.platform = platform
    }

    func reloadApplication(completion: @escaping Result<CardApplication, NSError>.Callback) {
        platform.fetchCardApplicationStatus(application.id, callback: completion)
    }
}
