//
//  AptoCardTransactionDetailsContract.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 14/08/2018.
//

import AptoSDK
import Bond
import UIKit

typealias
AptoCardTransactionDetailsViewControllerProtocol =
    AptoViewController & AptoCardTransactionDetailsViewProtocol

protocol AptoCardTransactionDetailsPresenterProtocol: AnyObject {
    // swiftlint:disable implicitly_unwrapped_optional
    var view: AptoCardTransactionDetailsViewProtocol! { get set }
    var interactor: AptoCardTransactionDetailsInteractorProtocol! { get set }
    var router: AptoCardTransactionDetailsRouterProtocol! { get set }
    // swiftlint:enable implicitly_unwrapped_optional
    var viewModel: AptoCardTransactionDetailsViewModel { get }
    var analyticsManager: AnalyticsServiceProtocol? { get set }
    func viewLoaded()
    func previousTapped()
    func mapTapped()
}

protocol AptoCardTransactionDetailsRouterProtocol {
    func backFromTransactionDetails()
    func openMapsCenteredIn(latitude: Double, longitude: Double)
}

protocol AptoCardTransactionDetailsViewProtocol: AnyObject, ViewControllerProtocol {
    func finishUpdates()
    func showLoadingSpinner()
    func show(error: Error)
}

protocol AptoCardTransactionDetailsInteractorProtocol {
    func provideTransaction(callback: @escaping Result<Transaction, NSError>.Callback)
}

open class AptoCardTransactionDetailsViewModel {
    // Map
    public let latitude: Observable<Double?> = Observable(nil)
    public let longitude: Observable<Double?> = Observable(nil)
    public let mccIcon: Observable<MCCIcon?> = Observable(nil)
    // Header
    public let fiatAmount: Observable<String?> = Observable(nil)
    public let nativeAmount: Observable<String?> = Observable(nil)
    public let description: Observable<String?> = Observable(nil)
    // Address
    public let address: Observable<String?> = Observable(nil)
    // Basic Data
    public let transactionDate: Observable<String?> = Observable(nil)
    public let transactionStatus: Observable<String?> = Observable(nil)
    public let declineReason: Observable<String> = Observable("")
    public let category: Observable<String?> = Observable(nil)
    public let fundingSource: Observable<String?> = Observable(nil)
    public let fee: Observable<String?> = Observable(nil)
    public let currencyExchange: Observable<String?> = Observable(nil)
    public let exchangeRate: Observable<String?> = Observable(nil)
    public let fundingSourceName: Observable<String?> = Observable(nil)
    // Detailed Data
    public let deviceType: Observable<String?> = Observable(nil)
    public let transactionType: Observable<String?> = Observable(nil)
    public let transactionClass: Observable<String?> = Observable(nil)
    public let transactionId: Observable<String?> = Observable(nil)
    public let adjustments: MutableObservableArray<TransactionAdjustment> = MutableObservableArray([])
}
