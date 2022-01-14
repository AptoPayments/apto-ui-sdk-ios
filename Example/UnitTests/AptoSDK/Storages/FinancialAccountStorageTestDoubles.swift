//
//  FinancialAccountStorageTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/08/2019.
//

@testable import AptoSDK
import Foundation

class FinancialAccountsStorageSpy: FinancialAccountsStorageProtocol {
    func get(financialAccountsOfType _: FinancialAccountType, apiKey _: String, userToken _: String,
             callback _: @escaping Result<[FinancialAccount], NSError>.Callback) {}

    func getFinancialAccounts(_: String, userToken _: String,
                              callback _: @escaping Result<[FinancialAccount], NSError>.Callback) {}

    func getFinancialAccount(_: String, userToken _: String, accountId _: String, forceRefresh _: Bool,
                             retrieveBalances _: Bool, callback _: @escaping Result<FinancialAccount, NSError>.Callback) {}

    func getCardDetails(_: String, userToken _: String, accountId _: String,
                        callback _: @escaping Result<CardDetails, NSError>.Callback) {}

    func getFinancialAccountTransactions(_: String, userToken _: String, accountId _: String,
                                         filters _: TransactionListFilters, forceRefresh _: Bool,
                                         callback _: @escaping Result<[Transaction], NSError>.Callback) {}

    func getFinancialAccountFundingSource(_: String, userToken _: String, accountId _: String,
                                          forceRefresh _: Bool,
                                          callback _: @escaping Result<FundingSource?, NSError>.Callback) {}

    func setFinancialAccountFundingSource(_: String, userToken _: String, accountId _: String, fundingSourceId _: String,
                                          callback _: @escaping Result<FundingSource, NSError>.Callback) {}

    func activatePhysical(_: String, userToken _: String, accountId _: String, code _: String,
                          callback _: @escaping Result<PhysicalCardActivationResult, NSError>.Callback) {}

    func updateFinancialAccountState(_: String, userToken _: String, accountId _: String, state _: FinancialAccountState,
                                     callback _: @escaping Result<FinancialAccount, NSError>.Callback) {}

    func updateFinancialAccountPIN(_: String, userToken _: String, accountId _: String, pin _: String,
                                   callback _: @escaping Result<FinancialAccount, NSError>.Callback) {}

    func getUserCardsList(_: String, userToken _: String, pagination _: PaginationQuery?, completion _: @escaping CardsListResult) {}

    private(set) var setCardPassCodeCalled = false
    private(set) var lastSetCardPassCodeApiKey: String?
    private(set) var lastSetCardPassCodeUserToken: String?
    private(set) var lastSetCardPassCodeCardId: String?
    private(set) var lastSetCardPassCodePassCode: String?
    private(set) var lastSetCardPassCodeVerificationId: String?
    func setCardPassCode(_ apiKey: String, userToken: String, cardId: String, passCode: String, verificationId: String?,
                         callback _: @escaping Result<Void, NSError>.Callback)
    {
        setCardPassCodeCalled = true
        lastSetCardPassCodeApiKey = apiKey
        lastSetCardPassCodeUserToken = userToken
        lastSetCardPassCodeCardId = cardId
        lastSetCardPassCodePassCode = passCode
        lastSetCardPassCodeVerificationId = verificationId
    }

    func financialAccountFundingSources(_: String, userToken _: String, accountId _: String, page _: Int?, rows _: Int?,
                                        forceRefresh _: Bool,
                                        callback _: @escaping Result<[FundingSource], NSError>.Callback) {}

    func addFinancialAccountFundingSource(_: String, userToken _: String, accountId _: String, custodian _: Custodian,
                                          callback _: @escaping Result<FundingSource, NSError>.Callback) {}

    private(set) var fetchMonthlySpendingCalled = false
    private(set) var lastFetchMonthlySpendingApiKey: String?
    private(set) var lastFetchMonthlySpendingUserToken: String?
    private(set) var lastFetchMonthlySpendingAccountId: String?
    private(set) var lastFetchMonthlySpendingMonth: Int?
    private(set) var lastFetchMonthlySpendingYear: Int?
    func fetchMonthlySpending(_ apiKey: String, userToken: String, accountId: String, month: Int, year: Int,
                              callback _: @escaping Result<MonthlySpending, NSError>.Callback)
    {
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
                   callback _: @escaping Result<Card, NSError>.Callback)
    {
        issueCardCalled = true
        lastIssueCardApiKey = apiKey
        lastIssueCardUserToken = userToken
        lastIssueCardCardProduct = cardProduct
        lastIssueCardCustodian = custodian
        lastIssueCardAdditionalFields = additionalFields
        lastIssueCardInitialFundingSourceId = initialFundingSourceId
    }

    func orderPhysicalCard(_: String,
                           userToken _: String,
                           accountId _: String,
                           completion _: @escaping (Result<Card, NSError>) -> Void) {}

    func getOrderPhysicalCardConfig(_: String,
                                    userToken _: String,
                                    accountId _: String,
                                    completion _: @escaping (Result<PhysicalCardConfig, NSError>) -> Void) {}
}

class FinancialAccountsStorageFake: FinancialAccountsStorageSpy {
    var nextFetchMonthlySpendingResult: Result<MonthlySpending, NSError>?
    override func fetchMonthlySpending(_ apiKey: String, userToken: String, accountId: String, month: Int, year: Int,
                                       callback: @escaping Result<MonthlySpending, NSError>.Callback)
    {
        super.fetchMonthlySpending(apiKey, userToken: userToken, accountId: accountId, month: month, year: year,
                                   callback: callback)
        if let result = nextFetchMonthlySpendingResult {
            callback(result)
        }
    }

    var nextIssueCardResult: Result<Card, NSError>?
    override func issueCard(_ apiKey: String, userToken: String, cardProduct: CardProduct, custodian: Custodian?,
                            additionalFields: [String: AnyObject]?, initialFundingSourceId: String?,
                            callback: @escaping Result<Card, NSError>.Callback)
    {
        super.issueCard(apiKey, userToken: userToken, cardProduct: cardProduct, custodian: custodian,
                        additionalFields: additionalFields, initialFundingSourceId: initialFundingSourceId,
                        callback: callback)
        if let result = nextIssueCardResult {
            callback(result)
        }
    }
}
