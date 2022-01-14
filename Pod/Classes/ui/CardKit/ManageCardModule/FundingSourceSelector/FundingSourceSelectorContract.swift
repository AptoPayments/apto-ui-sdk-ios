//
//  FundingSourceSelectorContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 18/12/2018.
//

import AptoSDK
import Bond
import Foundation

protocol FundingSourceSelectorModuleProtocol: UIModuleProtocol {
    func fundingSourceChanged()
    func addFundingSource(completion: @escaping (FundingSource) -> Void)
}

protocol FundingSourceSelectorInteractorProtocol {
    func loadFundingSources(forceRefresh: Bool, callback: @escaping Result<[FundingSource], NSError>.Callback)
    func activeCardFundingSource(forceRefresh: Bool, callback: @escaping Result<FundingSource?, NSError>.Callback)
    func setActive(fundingSource: FundingSource, callback: @escaping Result<FundingSource, NSError>.Callback)
}

protocol FundingSourceSelectorPresenterProtocol: AnyObject {
    // swiftlint:disable implicitly_unwrapped_optional
    var router: FundingSourceSelectorModuleProtocol! { get set }
    var interactor: FundingSourceSelectorInteractorProtocol! { get set }
    // swiftlint:enable implicitly_unwrapped_optional
    var viewModel: FundingSourceSelectorViewModel { get }
    var analyticsManager: AnalyticsServiceProtocol? { get set }

    func viewLoaded()
    func closeTapped()
    func refreshDataTapped()
    func fundingSourceSelected(index: Int)
    func addFundingSourceTapped()
}

class FundingSourceSelectorViewModel {
    let fundingSources: Observable<[FundingSource]> = Observable([])
    let activeFundingSourceIdx: Observable<Int?> = Observable(nil)
    let dataLoaded: Observable<Bool> = Observable(false)
    let showLoadingSpinner: Observable<Bool> = Observable(false)
    let hideReconnectButton: Observable<Bool> = Observable(false)
}

struct FundingSourceSelectorPresenterConfig {
    public let hideFundingSourcesReconnectButton: Bool
}
