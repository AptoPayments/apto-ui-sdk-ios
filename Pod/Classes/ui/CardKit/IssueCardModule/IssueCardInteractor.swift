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
    private let initializationData: InitializationData?
    
    init(
        platform: AptoPlatformProtocol,
        application: CardApplication,
        cardAdditionalFields: CardAdditionalFieldsProtocol,
        initializationData: InitializationData?)
    {
        self.platform = platform
        self.application = application
        self.cardAdditionalFields = cardAdditionalFields
        self.initializationData = initializationData
    }
    
    func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
        platform.issueCard(
            applicationId: application.id,
            metadata: initializationData?.cardMetadata ?? "",
            design: initializationData?.design) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let card):
                completion(.success(card))
            }
        }
    }
}
