//
//  CardApplicationStorageSpy.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 26/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
@testable import AptoSDK

class CardApplicationStorageSpy: CardApplicationsStorageProtocol {
    func createApplication(_ apiKey: String, userToken: String, cardProduct: CardProduct, callback: @escaping Result<CardApplication, NSError>.Callback) {}
    
    func applicationStatus(_ apiKey: String, userToken: String, applicationId: String, callback: @escaping Result<CardApplication, NSError>.Callback) {}
    
    func setBalanceStore(_ apiKey: String, userToken: String, applicationId: String, custodian: Custodian, callback: @escaping Result<SelectBalanceStoreResult, NSError>.Callback) {}
    
    func acceptDisclaimer(_ apiKey: String, userToken: String, workflowObject: WorkflowObject, workflowAction: WorkflowAction, callback: @escaping Result<Void, NSError>.Callback) {}
    
    func cancelCardApplication(_ apiKey: String, userToken: String, applicationId: String, callback: @escaping Result<Void, NSError>.Callback) {}
    
    func issueCard(_ apiKey: String, userToken: String, applicationId: String, metadata: String?, design: IssueCardDesign?, callback: @escaping Result<Card, NSError>.Callback) {}
}
