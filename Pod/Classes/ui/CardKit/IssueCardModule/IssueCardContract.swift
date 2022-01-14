//
// IssueCardContract.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/11/2018.
//

import AptoSDK
import Bond

enum IssueCardViewState: Equatable {
    case showLegalNotice(content: Content)
    case loading
    case error(error: BackendError)
    case done
}

class IssueCardViewModel {
    let state: Observable<IssueCardViewState>
    let errorAsset: Observable<String?>

    init(state: IssueCardViewState, errorAsset: String?) {
        self.state = Observable(state)
        self.errorAsset = Observable(errorAsset)
    }
}

protocol IssueCardInteractorProtocol {
    func issueCard(completion: @escaping Result<Card, NSError>.Callback)
}

protocol IssueCardPresenterProtocol: AnyObject {
    var viewModel: IssueCardViewModel { get }
    var analyticsManager: AnalyticsServiceProtocol? { get set }
    func viewLoaded()
    func requestCardTapped()
    func retryTapped()
    func closeTapped()
    func show(url: TappedURL)
}

protocol IssueCardRouter: AnyObject {
    func cardIssued(_ card: Card)
    func show(error: Error)
    func closeTapped()
    func show(url: TappedURL)
}

protocol IssueCardModuleProtocol: UIModuleProtocol, IssueCardRouter {}
