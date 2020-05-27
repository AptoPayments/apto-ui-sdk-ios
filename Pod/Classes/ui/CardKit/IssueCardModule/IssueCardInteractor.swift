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
  
  init(
    platform: AptoPlatformProtocol,
    application: CardApplication,
    cardAdditionalFields: CardAdditionalFieldsProtocol)
  {
    self.platform = platform
    self.application = application
    self.cardAdditionalFields = cardAdditionalFields
  }

  func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
    platform.issueCard(
      applicationId: application.id,
      additionalFields: cardAdditionalFields.get(),
      callback: completion
    )
  }
}
