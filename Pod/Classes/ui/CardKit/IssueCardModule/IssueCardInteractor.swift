//
//  IssueCardInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import AptoSDK

class IssueCardInteractor: IssueCardInteractorProtocol {
    private let platform: AptoPlatformProtocol
    private let application: CardApplication
    private let cardAdditionalFields: CardAdditionalFieldsProtocol
    private let cardMetadata: String?
    
    init(
        platform: AptoPlatformProtocol,
        application: CardApplication,
        cardAdditionalFields: CardAdditionalFieldsProtocol,
        cardMetadata: String?)
    {
        self.platform = platform
        self.application = application
        self.cardAdditionalFields = cardAdditionalFields
        self.cardMetadata = cardMetadata
    }
    
    func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
        platform.issueCard(
            applicationId: application.id,
            additionalFields: cardAdditionalFields.get(),
            metadata: cardMetadata ?? "") { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let card):
                completion(.success(card))
            }
        }
    }
}
