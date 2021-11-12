//
//  P2PTransferLoaderSpy.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 28/7/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
@testable import AptoSDK
@testable import AptoUISDK

class P2PTransferLoaderSpy: AptoPlatformFake {
    private var fetchConfigCompletions = [(Result<ContextConfiguration, NSError>) -> Void]()
    private var recipientCompletions = [(P2PTransferRecipientResult) -> Void]()
    private var inviteCompletions = [(P2PInviteResult) -> Void]()
    private var transferCompletions = [(P2PTransferResult) -> Void]()
    private var fetchFundingSourceCompletions = [(Result<FundingSource?, NSError>) -> Void]()

    var fetchConfigurationLoadCallCount: Int {
        fetchConfigCompletions.count
    }
    var findRecipientLoadCallCount: Int {
        recipientCompletions.count
    }
    var inviteLoadCallCount: Int {
        inviteCompletions.count
    }
    var transferLoadCallCount: Int {
        transferCompletions.count
    }
    var fetchFundingSourceLoadCallCount: Int {
        fetchFundingSourceCompletions.count
    }

    override func p2pFindRecipient(phone: PhoneNumber?, email: String?, callback: @escaping (P2PTransferRecipientResult) -> Void) {
        recipientCompletions.append(callback)
    }

    override func p2pMakeTransfer(transferRequest: P2PTransferRequest, callback: @escaping (P2PTransferResult) -> Void) {
        transferCompletions.append(callback)
    }
    
    override func fetchContextConfiguration(_ forceRefresh: Bool, callback: @escaping Result<ContextConfiguration, NSError>.Callback) {
        fetchConfigCompletions.append(callback)
    }
    
    override func fetchCardFundingSource(_ cardId: String, forceRefresh: Bool, callback: @escaping Result<FundingSource?, NSError>.Callback) {
        fetchFundingSourceCompletions.append(callback)
    }
    
    func completeConfiguration(with configuration: ContextConfiguration = ModelDataProvider.provider.contextConfiguration, at index: Int = 0) {
        fetchConfigCompletions[index](.success(configuration))
    }
    
    func completeFundingSource(with fundingSource: FundingSource = ModelDataProvider.provider.fundingSource, at index: Int = 0) {
        fetchFundingSourceCompletions[index](.success(fundingSource))
    }
    
    func completeInviteLoading(with invite: Void = (), at index: Int = 0) {
        inviteCompletions[index](.success(invite))
    }
    
    func completeFindRecipient(with recipient: CardholderData = ModelDataProvider.provider.recipient, at index: Int = 0) {
        recipientCompletions[index](.success(recipient))
    }

    func completeFindRecipient(with error: NSError, at index: Int = 0) {
        recipientCompletions[index](.failure(error))
    }

    func completeTransfer(with transfer: P2PTransferResponse = ModelDataProvider.provider.transferResponse, at index: Int = 0) {
        transferCompletions[index](.success(transfer))
    }
}

