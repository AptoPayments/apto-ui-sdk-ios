//
//  ModelDataProvider.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/06/2018.
//
//

import Foundation
@testable import AptoSDK
@testable import AptoUISDK
import SwiftyJSON

class ModelDataProvider {
  static let provider: ModelDataProvider = ModelDataProvider()
  private init() {
  }

  lazy var emptyJSON = JSON()

  lazy var user = ShiftUser(userId: "userId", accessToken: AccessToken(token: "AccessToken",
                                                                       primaryCredential: .email,
                                                                       secondaryCredential: .phoneNumber))

  lazy var userJSON = JSON(dictionaryLiteral: ("user_id", "user_id"), ("user_token", "user_token"))

  lazy var teamConfig = TeamConfiguration(logoUrl: nil, name: "Test team")

  lazy var amountRangeConfiguration = AmountRangeConfiguration(min: 0, max: 1000, def: 100, inc: 100)

  lazy var workflowAction: WorkflowAction = {
    let configuration = SelectBalanceStoreActionConfiguration(allowedBalanceTypes: [balanceType],
                                                              assetUrl: nil)
    return WorkflowAction(actionId: nil,
                          name: nil,
                          order: nil,
                          status: nil,
                          actionType: .selectBalanceStore,
                          configuration: configuration)
  }()

  lazy var waitListAction: WorkflowAction = {
    let configuration = WaitListActionConfiguration(asset: "asset", backgroundImage: "image", backgroundColor: "color")
    return WorkflowAction(actionId: nil,
                          name: nil,
                          order: nil,
                          status: nil,
                          actionType: .waitList,
                          configuration: configuration)
  }()

  lazy var projectBranding: ProjectBranding = {
    return ProjectBranding(uiBackgroundPrimaryColor: "ffffff",
                           uiBackgroundSecondaryColor: "ffffff",
                           iconPrimaryColor: "ffffff",
                           iconSecondaryColor: "ffffff",
                           iconTertiaryColor: "ffffff",
                           textPrimaryColor: "ffffff",
                           textSecondaryColor: "ffffff",
                           textTertiaryColor: "ffffff",
                           textTopBarPrimaryColor: "ffffff",
                           textTopBarSecondaryColor: "ffffff",
                           textLinkColor: "ffffff",
                           textLinkUnderlined: true,
                           textButtonColor: "ffffff",
                           buttonCornerRadius: 12,
                           uiPrimaryColor: "ffffff",
                           uiSecondaryColor: "ffffff",
                           uiTertiaryColor: "ffffff",
                           uiErrorColor: "ffffff",
                           uiSuccessColor: "ffffff",
                           uiNavigationPrimaryColor: "ffffff",
                           uiNavigationSecondaryColor: "ffffff",
                           uiBackgroundOverlayColor: "ffffff",
                           textMessageColor: "ffffff",
                           badgeBackgroundPositiveColor: "ffffff",
                           badgeBackgroundNegativeColor: "ffffff",
                           showToastTitle: true,
                           transactionDetailsCollapsable: true,
                           disclaimerBackgroundColor: "ffffff",
                           uiStatusBarStyle: "auto",
                           logoUrl: nil,
                           uiTheme: "theme_1")
  }()

  lazy var projectConfiguration: ProjectConfiguration = {
    return ProjectConfiguration(name: "Test project",
                                summary: nil,
                                allowUserLogin: true,
                                primaryAuthCredential: .email,
                                secondaryAuthCredential: .phoneNumber,
                                skipSteps: true,
                                strictAddressValidation: false,
                                defaultCountryCode: 1,
                                products: [.link],
                                incomeTypes: [IncomeType(incomeTypeId: 1)],
                                housingTypes: [HousingType(housingTypeId: 1)],
                                salaryFrequencies: [SalaryFrequency(salaryFrequencyId: 1)],
                                timeAtAddressOptions: [TimeAtAddressOption(timeAtAddressId: 1)],
                                creditScoreOptions: [CreditScoreOption(creditScoreId: 1)],
                                grossIncomeRange: amountRangeConfiguration,
                                welcomeScreenAction: workflowAction,
                                supportEmailAddress: nil,
                                branding: projectBranding,
                                allowedCountries: [Country(isoCode: "US", name: "United States")],
                                isTrackerActive: false,
                                trackerAccessToken: nil)
  }()

  lazy var contextConfiguration = ContextConfiguration(teamConfiguration: teamConfig,
                                                       projectConfiguration: projectConfiguration)

  lazy var uiConfig: UIConfig = UIConfig(projectConfiguration: projectConfiguration)

  lazy var phoneDataPoint: DataPoint = DataPoint(type: .phoneNumber, verified: true, notSpecified: false)
  lazy var emailDataPoint: DataPoint = DataPoint(type: .email, verified: true, notSpecified: false)

  lazy var phoneNumberDataPointList: DataPointList = {
    let list = DataPointList()
    _ = list.getForcingDataPointOf(type: .phoneNumber, defaultValue: PhoneNumber())

    return list
  }()
  lazy var emailDataPointList: DataPointList = {
    let list = DataPointList()
    _ = list.getForcingDataPointOf(type: .email, defaultValue: Email())

    return list
  }()
  lazy var birthDateDataPointList: DataPointList = {
    let list = DataPointList()
    _ = list.getForcingDataPointOf(type: .birthDate, defaultValue: BirthDate())

    return list
  }()
  lazy var ssnDataPointList: DataPointList = {
    let list = DataPointList()
    _ = list.getForcingDataPointOf(type: .idDocument, defaultValue: IdDocument())

    return list
  }()

  lazy var cardApplication: CardApplication = CardApplication(id: "id",
                                                              status: .created,
                                                              applicationDate: Date(),
                                                              workflowObjectId: "workflow_id",
                                                              nextAction: workflowAction)

  lazy var waitListCardApplication = CardApplication(id: "id",
                                                     status: .created,
                                                     applicationDate: Date(),
                                                     workflowObjectId: "workflow_id",
                                                     nextAction: waitListAction)

  lazy var cardJSON = JSON(dictionaryLiteral: ("account_id", "account_id"), ("state", "created"), ("last_four", "1234"))

  lazy var card: Card = {
    let card = Card(accountId: "card_id",
                    cardProductId: "card_product_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .received,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    card.details = cardDetails
    return card
  }()

  lazy var cardWithoutCardProductId: Card = {
    let card = Card(accountId: "card_id",
                    cardProductId: nil,
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .received,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    card.details = cardDetails
    return card
  }()

  lazy var cardWithoutDetails: Card = Card(accountId: "card_id",
                                           cardProductId: "card_product_id",
                                           cardNetwork: .other,
                                           cardIssuer: .shift,
                                           cardBrand: "Shift",
                                           state: .active,
                                           cardHolder: "Holder Name",
                                           lastFourDigits: "7890",
                                           spendableToday: Amount(value: 12.34, currency: "GBP"),
                                           nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                                           totalBalance: Amount(value: 12.34, currency: "GBP"),
                                           nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                                           kyc: .passed,
                                           orderedStatus: .received,
                                           panToken: "pan_token",
                                           cvvToken: "cvv_token",
                                           verified: true)

  lazy var cardWithIVR: Card = {
    let phoneNumber = PhoneNumber(countryCode: 1, phoneNumber: "2342303796")
    let ivr = IVR(status: .enabled, phone: phoneNumber)
    let features = CardFeatures(setPin: FeatureAction(source: .ivr(ivr), status: .enabled),
                                getPin: FeatureAction(source: .ivr(ivr), status: .enabled),
                                allowedBalanceTypes: [balanceType], activation: nil, ivrSupport: ivr)
    let card = Card(accountId: "card_id",
                    cardProductId: "card_product_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .received,
                    features: features,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    return card
  }()

  lazy var cardWithVoIP: Card = {
    let phoneNumber = PhoneNumber(countryCode: 1, phoneNumber: "2342303796")
    let ivr = IVR(status: .enabled, phone: phoneNumber)
    let features = CardFeatures(setPin: FeatureAction(source: .voIP, status: .enabled),
                                getPin: FeatureAction(source: .voIP, status: .enabled),
                                allowedBalanceTypes: [balanceType], activation: nil, ivrSupport: ivr)
    let card = Card(accountId: "card_id",
                    cardProductId: "card_product_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .received,
                    features: features,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    return card
  }()

  lazy var cardWithChangePIN: Card = {
    let phoneNumber = PhoneNumber(countryCode: 1, phoneNumber: "2342303796")
    let ivr = IVR(status: .enabled, phone: phoneNumber)
    let features = CardFeatures(setPin: FeatureAction(source: .api, status: .enabled),
                                getPin: FeatureAction(source: .api, status: .enabled),
                                allowedBalanceTypes: [balanceType], activation: nil, ivrSupport: ivr)
    let card = Card(accountId: "card_id",
                    cardProductId: "card_product_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .received,
                    features: features,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    return card
  }()

  lazy var cardWithChangePINAndIVR: Card = {
    let phoneNumber = PhoneNumber(countryCode: 1, phoneNumber: "2342303796")
    let ivr = IVR(status: .enabled, phone: phoneNumber)
    let features = CardFeatures(setPin: FeatureAction(source: .api, status: .enabled),
                                getPin: FeatureAction(source: .ivr(ivr), status: .enabled),
                                allowedBalanceTypes: [balanceType], activation: nil, ivrSupport: ivr)
    let card = Card(accountId: "card_id",
                    cardProductId: "card_product_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .received,
                    features: features,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    return card
  }()

  lazy var cardWithUnknownSource: Card = {
    let phoneNumber = PhoneNumber(countryCode: 1, phoneNumber: "2342303796")
    let ivr = IVR(status: .enabled, phone: phoneNumber)
    let features = CardFeatures(setPin: FeatureAction(source: .unknown, status: .enabled),
                                getPin: FeatureAction(source: .unknown, status: .enabled),
                                allowedBalanceTypes: [balanceType], activation: nil, ivrSupport: ivr)
    let card = Card(accountId: "card_id",
                    cardProductId: "card_product_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .received,
                    features: features,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    return card
  }()

  lazy var orderedCard: Card = {
    let card = Card(accountId: "card_id",
                    cardProductId: "card_product_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .ordered,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true)
    return card
  }()

  lazy var waitListedCard: Card = {
    let card = Card(accountId: "card_id",
                    cardProductId: "card_product_id",
                    cardNetwork: .other,
                    cardIssuer: .shift,
                    cardBrand: "Shift",
                    state: .active,
                    cardHolder: "Holder Name",
                    lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"),
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"),
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"),
                    kyc: .passed,
                    orderedStatus: .ordered,
                    panToken: "pan_token",
                    cvvToken: "cvv_token",
                    verified: true,
                    isInWaitList: true)
    return card
  }()

  lazy var cardInactive: Card = {
    let card = Card(accountId: "card_id", cardProductId: "card_product_id", cardNetwork: .other, cardIssuer: .shift,
                    cardBrand: "Shift", state: .inactive, cardHolder: "Holder Name", lastFourDigits: "7890",
                    spendableToday: Amount(value: 12.34, currency: "GBP"), 
                    nativeSpendableToday: Amount(value: 0.034, currency: "BTC"), 
                    totalBalance: Amount(value: 12.34, currency: "GBP"),
                    nativeTotalBalance: Amount(value: 0.034, currency: "BTC"), kyc: .passed, orderedStatus: .received,
                    panToken: "pan_token", cvvToken: "cvv_token", verified: true)
    card.details = cardDetails
    return card
  }()

  lazy var cardDetails = CardDetails(expiration: "99-03", pan: "1234234134124123", cvv: "123")

  lazy var transaction = transactionWith(transactionId: "transactionId")

  func transactionWith(transactionId: String) -> Transaction {
    return Transaction(transactionId: transactionId,
                       transactionType: .purchase,
                       createdAt: Date(),
                       transactionDescription: "transactionDescription",
                       lastMessage: "lastMessage",
                       declineCode: nil,
                       merchant: nil,
                       store: nil,
                       localAmount: Amount(value: 10, currency: "USD"),
                       billingAmount: Amount(value: 10, currency: "USD"),
                       holdAmount: nil,
                       cashbackAmount: nil,
                       feeAmount: nil,
                       nativeBalance: Amount(value: 0.001, currency: "BTC"),
                       settlement: nil,
                       ecommerce: true,
                       international: false,
                       cardPresent: false,
                       emv: false,
                       cardNetwork: .visa,
                       state: .complete,
                       adjustments: nil,
                       fundingSourceName: "Bitcoin")
  }

  lazy var fundingSource = FundingSource(fundingSourceId: "fundingSourceId",
                                         type: .custodianWallet,
                                         balance: Amount(value: 1000, currency: "USD"),
                                         amountHold: nil,
                                         state: .valid)

  lazy var invalidFundingSource = FundingSource(fundingSourceId: "fundingSourceId",
                                                type: .custodianWallet,
                                                balance: Amount(value: 1000, currency: "USD"),
                                                amountHold: nil,
                                                state: .invalid)

  lazy var externalOauthModuleConfig = ExternalOAuthModuleConfig(title: "title", 
                                                                 explanation: "explanation",
                                                                 callToAction: "callToAction",
                                                                 newUserAction: "newUserAction",
                                                                 allowedBalanceTypes: [balanceType],
                                                                 assetUrl: url,
                                                                 oauthErrorMessageKeys: nil)

  lazy var custodian = Custodian(custodianType: "custodian", name: "Custodian")

  lazy var oauthCredential = OauthCredential(oauthTokenId: "oauth_token_id")

  lazy var oauthAttempt = OauthAttempt(id: "attempt_id",
                                       status: .passed,
                                       url: url,
                                       credentials: oauthCredential,
                                       error: nil,
                                       errorMessage: nil)

  lazy var oauthErrorAttempt = OauthAttempt(id: "attempt_id",
                                            status: .failed,
                                            url: nil,
                                            credentials: nil,
                                            error: "unauthorised_access",
                                            errorMessage: "unauthorised_access")

  lazy var usa = Country(isoCode: "US", name: "United States")

  lazy var balanceType = AllowedBalanceType(type: "custodian", baseUri: "baseUri")

  lazy var url = URL(string: "https://shiftpayments.com")! // swiftlint:disable:this implicitly_unwrapped_optional

  lazy var categorySpending = CategorySpending(categoryId: .food,
                                               spending: Amount(value: 100, currency: "USD"),
                                               difference: 10)

  func monthlySpending(date: Date, previousSpendingExists: Bool = true, nextSpendingExists: Bool = true) -> MonthlySpending {
    return MonthlySpending(previousSpendingExists: previousSpendingExists,
                           nextSpendingExists: nextSpendingExists,
                           spending: [categorySpending],
                           date: date)
  }

  lazy var monthlySpendingJSON = JSON(parseJSON:"""
{
  "next_spending_exists": false,
  "prev_spending_exists": true,
  "spending": {
    "data": [
      {
        "category_id": "plane",
        "difference": "-13.13",
        "spending": {
          "amount": 90,
          "currency": "USD",
          "type": "money"
        },
        "type": "category_spending"
      }
    ],
    "has_more": false,
    "page": 0,
    "rows": 12,
    "total_count": 1,
    "type": "list"
  },
  "type": "monthly_spending"
}
""")

  lazy var cardProduct = CardProduct(id: "id",
                                     teamId: "teamId",
                                     name: "Name",
                                     summary: "Summary",
                                     website: nil,
                                     cardholderAgreement: .plainText("cardholder agreement"),
                                     privacyPolicy: .plainText("privacy policy"),
                                     termsAndConditions: .plainText("terms and conditions"),
                                     faq: .plainText("faq"),
                                     status: .enabled,
                                     shared: false,
                                     disclaimerAction: workflowAction,
                                     cardIssuer: "Shift",
                                     waitListBackgroundImage: "image",
                                     waitListBackgroundColor: "color",
                                     waitListAsset: "asset")
  lazy var paymentSuccessfulGroup = NotificationGroup(groupId: .paymentSuccessful,
                                                      category: .cardActivity,
                                                      state: .disabled,
                                                      channel: NotificationGroup.Channel(push: true, email: true))
  lazy var atmWithdrawalGroup = NotificationGroup(groupId: .atmWithdrawal,
                                                  category: .cardActivity,
                                                  state: .enabled,
                                                  channel: NotificationGroup.Channel(push: true, email: false))

  lazy var notificationPreferences = NotificationPreferences(preferences: [paymentSuccessfulGroup, atmWithdrawalGroup])

  lazy var oauthUserData = OAuthUserData(userData: phoneNumberDataPointList)

  lazy var oauthSaveUserDataSucceed = OAuthSaveUserDataResult(result: .valid,
                                                              userData: nil)

  lazy var oauthSaveUserDataFailure = OAuthSaveUserDataResult(result: .invalid,
                                                              userData: phoneNumberDataPointList)

  lazy var voIPToken = VoIPToken(accessToken: "access_token", requestToken: "request_token", provider: "twilio")

  lazy var monthlyStatementReportJSON = JSON(dictionaryLiteral: ("type", "monthly_statement_report"), ("id", "id"), 
                                             ("month", 2), ("year", 2019),
                                             ("download_url", "https://aptopayments.com"), 
                                             ("url_expiration", "2019-02-11T17:17:13.564128+00:00"))

  lazy var monthlyStatementReport = MonthlyStatementReport(id: "id", month: 2, year: 2019,
                                                           downloadUrl: "https://aptopyaments.com",
                                                           urlExpirationDate: Date().add(3, units: .month))
  lazy var monthlyStatementReportExpired = MonthlyStatementReport(id: "id", month: 2, year: 2019,
                                                                  downloadUrl: "https://aptopyaments.com", 
                                                                  urlExpirationDate: Date.distantPast)
  lazy var monthlyStatementReportWithoutUrl = MonthlyStatementReport(id: "id", month: 2, year: 2019, downloadUrl: nil,
                                                                     urlExpirationDate: Date.distantPast)
  lazy var monthlyStatementReportWithoutExpiration = MonthlyStatementReport(id: "id", month: 2, year: 2019,
                                                                            downloadUrl: nil, urlExpirationDate: nil)

  lazy var monthJSON: JSON = ["type": "month", "month": 2, "year": 2019]

  lazy var month = Month(month: 2, year: 2019)

  lazy var monthlyStatementsPeriodJSON: JSON = [
    "type": "monthly_statements_period",
    "start": [
      "type": "month",
      "year": 2019,
      "month": 5
    ],
    "end": [
      "type": "month",
      "year": 2019,
      "month": 9
    ]
  ]

  lazy var monthlyStatementsPeriod = MonthlyStatementsPeriod(start: Month(month: 5, year: 2019),
                                                             end: Month(month: 9, year: 2019))
}
