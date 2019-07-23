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

  init(platform: AptoPlatformProtocol, application: CardApplication) {
    self.platform = platform
    self.application = application
  }

  func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
    platform.issueCard(applicationId: application.id, callback: completion)
  }
}
