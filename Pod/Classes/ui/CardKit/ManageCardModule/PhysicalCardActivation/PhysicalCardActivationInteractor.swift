//
// PhysicalCardActivationInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-10.
//

import AptoSDK
import Foundation

class PhysicalCardActivationInteractor: PhysicalCardActivationInteractorProtocol {
    private let card: Card
    private let platform: AptoPlatformProtocol

    init(card: Card, platform: AptoPlatformProtocol) {
        self.card = card
        self.platform = platform
    }

    func fetchCard(callback: @escaping Result<Card, NSError>.Callback) {
        callback(.success(card))
    }

    func fetchUpdatedCard(callback: @escaping Result<Card?, NSError>.Callback) {
        platform.fetchCard(card.accountId, forceRefresh: true) { result in
            callback(result.flatMap { financialAccount -> Result<Card?, NSError> in
                guard let shiftCard = financialAccount as? Card else {
                    return .success(nil)
                }
                return .success(shiftCard)
            })
        }
    }

    func fetchCurrentUser(callback: @escaping Result<AptoUser, NSError>.Callback) {
        platform.fetchCurrentUserInfo(callback: callback)
    }

    func activatePhysicalCard(code: String, callback: @escaping Result<Void, NSError>.Callback) {
        platform.activatePhysicalCard(card.accountId, code: code) { result in
            switch result {
            case let .failure(error):
                callback(.failure(error))
            case let .success(activationResult):
                if activationResult.type == .activated {
                    callback(.success(()))
                } else {
                    let error: BackendError
                    if let rawErrorCode = activationResult.errorCode,
                       let errorCode = BackendError.ErrorCodes(rawValue: rawErrorCode)
                    {
                        error = BackendError(code: errorCode)
                    } else {
                        // This should never happen
                        error = BackendError(code: .other)
                    }
                    callback(.failure(error))
                }
            }
        }
    }
}
