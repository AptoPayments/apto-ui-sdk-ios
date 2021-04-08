//
//  FinancialAccountStorageTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/08/2019.
//

import Foundation
@testable import AptoSDK

class FinancialAccountsStorageSpy: FinancialAccountsStorageProtocol {
  func get(financialAccountsOfType accountType: FinancialAccountType, apiKey: String, userToken: String,
           callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
  }

  func getFinancialAccounts(_ apiKey: String, userToken: String,
                            callback: @escaping Result<[FinancialAccount], NSError>.Callback) {
  }

  func getFinancialAccount(_ apiKey: String, userToken: String, accountId: String, forceRefresh: Bool,
                           retrieveBalances: Bool, callback: @escaping Result<FinancialAccount, NSError>.Callback) {
  }

  func getCardDetails(_ apiKey: String, userToken: String, accountId: String,
                      callback: @escaping Result<CardDetails, NSError>.Callback) {
  }

  func getFinancialAccountTransactions(_ apiKey: String, userToken: String, accountId: String,
                                       filters: TransactionListFilters, forceRefresh: Bool,
                                       callback: @escaping Result<[Transaction], NSError>.Callback) {
  }

  func getFinancialAccountFundingSource(_ apiKey: String, userToken: String, accountId: String,
                                        forceRefresh: Bool,
                                        callback: @escaping Result<FundingSource?, NSError>.Callback) {
  }

  func setFinancialAccountFundingSource(_ apiKey: String, userToken: String, accountId: String, fundingSourceId: String,
                                        callback: @escaping Result<FundingSource, NSError>.Callback) {
  }

  func activatePhysical(_ apiKey: String, userToken: String, accountId: String, code: String,
                        callback: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {
  }

  func updateFinancialAccountState(_ apiKey: String, userToken: String, accountId: String, state: FinancialAccountState,
                                   callback: @escaping Result<FinancialAccount, NSError>.Callback) {
  }

  func updateFinancialAccountPIN(_ apiKey: String, userToken: String, accountId: String, pin: String,
                                 callback: @escaping Result<FinancialAccount, NSError>.Callback) {
  }

  private(set) var setCardPassCodeCalled = false
  private(set) var lastSetCardPassCodeApiKey: String?
  private(set) var lastSetCardPassCodeUserToken: String?
  private(set) var lastSetCardPassCodeCardId: String?
  private(set) var lastSetCardPassCodePassCode: String?
  private(set) var lastSetCardPassCodeVerificationId: String?
  func setCardPassCode(_ apiKey: String, userToken: String, cardId: String, passCode: String, verificationId: String?,
                       callback: @escaping Result<Void, NSError>.Callback) {
    setCardPassCodeCalled = true
    lastSetCardPassCodeApiKey = apiKey
    lastSetCardPassCodeUserToken = userToken
    lastSetCardPassCodeCardId = cardId
    lastSetCardPassCodePassCode = passCode
    lastSetCardPassCodeVerificationId = verificationId
  }

  func financialAccountFundingSources(_ apiKey: String, userToken: String, accountId: String, page: Int?, rows: Int?,
                                      forceRefresh: Bool,
                                      callback: @escaping Result<[FundingSource], NSError>.Callback) {
  }

  func addFinancialAccountFundingSource(_ apiKey: String, userToken: String, accountId: String, custodian: Custodian,
                                        callback: @escaping Result<FundingSource, NSError>.Callback) {
  }

  private(set) var fetchMonthlySpendingCalled = false
  private(set) var lastFetchMonthlySpendingApiKey: String?
  private(set) var lastFetchMonthlySpendingUserToken: String?
  private(set) var lastFetchMonthlySpendingAccountId: String?
  private(set) var lastFetchMonthlySpendingMonth: Int?
  private(set) var lastFetchMonthlySpendingYear: Int?
  func fetchMonthlySpending(_ apiKey: String, userToken: String, accountId: String, month: Int, year: Int,
                            callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    fetchMonthlySpendingCalled = true
    lastFetchMonthlySpendingApiKey = apiKey
    lastFetchMonthlySpendingUserToken = userToken
    lastFetchMonthlySpendingAccountId = accountId
    lastFetchMonthlySpendingMonth = month
    lastFetchMonthlySpendingYear = year
  }

  private(set) var issueCardCalled = false
  private(set) var lastIssueCardApiKey: String?
  private(set) var lastIssueCardUserToken: String?
  private(set) var lastIssueCardCardProduct: CardProduct?
  private(set) var lastIssueCardCustodian: Custodian?
  private(set) var lastIssueCardAdditionalFields: [String: AnyObject]?
  private(set) var lastIssueCardInitialFundingSourceId: String?
  func issueCard(_ apiKey: String, userToken: String, cardProduct: CardProduct, custodian: Custodian?,
                 additionalFields: [String: AnyObject]?, initialFundingSourceId: String?,
                 callback: @escaping Result<Card, NSError>.Callback) {
    issueCardCalled = true
    lastIssueCardApiKey = apiKey
    lastIssueCardUserToken = userToken
    lastIssueCardCardProduct = cardProduct
    lastIssueCardCustodian = custodian
    lastIssueCardAdditionalFields = additionalFields
    lastIssueCardInitialFundingSourceId = initialFundingSourceId
  }
    
    func orderPhysicalCard(_ apiKey: String,
                           userToken: String,
                           accountId: String,
                           completion: @escaping (Result<Card, NSError>) -> Void) {}
    
    func getOrderPhysicalCardConfig(_ apiKey: String,
                                    userToken: String,
                                    accountId: String,
                                    completion: @escaping (Result<PhysicalCardConfig, NSError>) -> Void) {}
}

class FinancialAccountsStorageFake: FinancialAccountsStorageSpy {
  var nextFetchMonthlySpendingResult: Result<MonthlySpending, NSError>?
  override func fetchMonthlySpending(_ apiKey: String, userToken: String, accountId: String, month: Int, year: Int,
                                     callback: @escaping Result<MonthlySpending, NSError>.Callback) {
    super.fetchMonthlySpending(apiKey, userToken: userToken, accountId: accountId, month: month, year: year,
                               callback: callback)
    if let result = nextFetchMonthlySpendingResult {
      callback(result)
    }
  }

  var nextIssueCardResult: Result<Card, NSError>?
  override func issueCard(_ apiKey: String, userToken: String, cardProduct: CardProduct, custodian: Custodian?,
                          additionalFields: [String: AnyObject]?, initialFundingSourceId: String?,
                          callback: @escaping Result<Card, NSError>.Callback) {
    super.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                    additionalFields: additionalFields, initialFundingSourceId: initialFundingSourceId,
                    callback: callback)
    if let result = nextIssueCardResult {
      callback(result)
    }
  }
}
