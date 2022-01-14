//
//  CardApplicationStorageSpy.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 26/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

@testable import AptoSDK
import Foundation

class CardApplicationStorageSpy: CardApplicationsStorageProtocol {
    func createApplication(_: String, userToken _: String, cardProduct _: CardProduct, callback _: @escaping Result<CardApplication, NSError>.Callback) {}

    func applicationStatus(_: String, userToken _: String, applicationId _: String, callback _: @escaping Result<CardApplication, NSError>.Callback) {}

    func setBalanceStore(_: String, userToken _: String, applicationId _: String, custodian _: Custodian, callback _: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {}

    func acceptDisclaimer(_: String, userToken _: String, workflowObject _: WorkflowObject, workflowAction _: WorkflowAction, callback _: @escaping Result<Void, NSError>.Callback) {}

    func cancelCardApplication(_: String, userToken _: String, applicationId _: String, callback _: @escaping Result<Void, NSError>.Callback) {}

    func issueCard(_: String, userToken _: String, applicationId _: String, metadata _: String?, design _: IssueCardDesign?, callback _: @escaping Result<Card, NSError>.Callback) {}
}
