//
//  IssueCardTestDoubles.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import AptoSDK
@testable import AptoUISDK

final class CardAdditionalFieldsSpy: CardAdditionalFieldsProtocol {
    public private(set) var setCalled = false
    func set(_: AdditionalFields) {
        setCalled = true
    }

    public private(set) var getCalled = false
    func get() -> AdditionalFields? {
        getCalled = true
        return nil
    }
}

class IssueCardPresenterSpy: IssueCardPresenterProtocol {
    let viewModel = IssueCardViewModel(state: .loading, errorAsset: nil)
    var analyticsManager: AnalyticsServiceProtocol?

    private(set) var viewLoadedCalled = false
    func viewLoaded() {
        viewLoadedCalled = true
    }

    private(set) var requestCardTappedCalled = false
    func requestCardTapped() {
        requestCardTappedCalled = true
    }

    private(set) var retryTappedCalled = false
    func retryTapped() {
        retryTappedCalled = true
    }

    private(set) var closeTappedCalled = false
    func closeTapped() {
        closeTappedCalled = true
    }

    private(set) var showURLCalled = false
    private(set) var lastURLToShow: TappedURL?
    func show(url: TappedURL) {
        showURLCalled = true
        lastURLToShow = url
    }
}

class IssueCardInteractorSpy: IssueCardInteractorProtocol {
    private(set) var issueCardCalled = false
    private(set) var lastIssueCardCompletion: Result<Card, NSError>.Callback?
    func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
        issueCardCalled = true
        lastIssueCardCompletion = completion
    }
}

class IssueCardInteractorFake: IssueCardInteractorSpy {
    var nextIssueCardResult: Result<Card, NSError>?
    override func issueCard(completion: @escaping Result<Card, NSError>.Callback) {
        super.issueCard(completion: completion)

        if let result = nextIssueCardResult {
            completion(result)
        }
    }
}

class IssueCardModuleSpy: UIModuleSpy, IssueCardModuleProtocol {
    private(set) var cardIssuedCalled = false
    private(set) var lastCardIssued: Card?
    func cardIssued(_ card: Card) {
        cardIssuedCalled = true
        lastCardIssued = card
    }

    private(set) var closeTappedCalled = false
    func closeTapped() {
        closeTappedCalled = true
    }

    private(set) var showURLCalled = false
    func show(url _: TappedURL) {
        showURLCalled = true
    }
}
