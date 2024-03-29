@testable import AptoSDK
@testable import AptoUISDK

final class FundingSourceSelectorModuleSpy: UIModuleSpy, FundingSourceSelectorModuleProtocol {
    private(set) var fundingSourceChangedCalled = false
    private(set) var addFundingSourceCalled = false

    func fundingSourceChanged() {
        fundingSourceChangedCalled = true
    }

    func addFundingSource(completion _: @escaping (FundingSource) -> Void) {
        addFundingSourceCalled = true
    }
}

final class FundingSourceSelectorInteractorSpy: FundingSourceSelectorInteractorProtocol {
    private(set) var loadFundingSourcesForceRefresh = false
    private(set) var setActiveCalled = false
    private(set) var activeCardFundingSourceCalled = false

    var nextSetActiveResult: Result<FundingSource, NSError>?

    func loadFundingSources(forceRefresh: Bool, callback _: @escaping Result<[FundingSource], NSError>.Callback) {
        loadFundingSourcesForceRefresh = forceRefresh
    }

    func activeCardFundingSource(forceRefresh _: Bool, callback _: @escaping Result<FundingSource?, NSError>.Callback) {
        activeCardFundingSourceCalled = true
    }

    func setActive(fundingSource _: FundingSource, callback: @escaping Result<FundingSource, NSError>.Callback) {
        setActiveCalled = true
        if let result = nextSetActiveResult {
            callback(result)
        }
    }
}
