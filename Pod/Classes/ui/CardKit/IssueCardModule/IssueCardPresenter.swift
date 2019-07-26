//
//  IssueCardPresenter.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 29/06/2018.
//
//

import AptoSDK
import Bond

class IssueCardPresenter: IssueCardPresenterProtocol {
  private unowned let router: IssueCardRouter
  private let interactor: IssueCardInteractorProtocol
  private let configuration: IssueCardActionConfiguration?
  let viewModel = IssueCardViewModel(state: .loading, errorAsset: nil)
  var analyticsManager: AnalyticsServiceProtocol?

  init(router: IssueCardRouter, interactor: IssueCardInteractorProtocol, configuration: IssueCardActionConfiguration?) {
    self.router = router
    self.interactor = interactor
    self.configuration = configuration
  }

  func viewLoaded() {
    if let errorAsset = configuration?.errorAsset {
      viewModel.errorAsset.send(errorAsset)
    }
    if let legalNotice = configuration?.legalNotice {
      viewModel.state.send(IssueCardViewState.showLegalNotice(content: legalNotice))
    }
    else {
      issueCard()
    }
    analyticsManager?.track(event: Event.issueCard)
  }

  func requestCardTapped() {
    issueCard()
  }

  func retryTapped() {
    issueCard()
  }

  func closeTapped() {
    router.closeTapped()
  }

  func show(url: TappedURL) {
    router.show(url: url)
  }

  private func trackError(error: BackendError?) {
    guard let backendError = error else {
      analyticsManager?.track(event: Event.issueCardUnknownError)
      return
    }
    switch backendError {
    case _ where backendError.isBalanceInsufficientFundsError:
      analyticsManager?.track(event: Event.issueCardInsufficientFunds)
    case _ where backendError.isBalanceValidationsInsufficientApplicationLimit:
      analyticsManager?.track(event: Event.issueCardInsufficientApplicationLimit)
    case _ where backendError.isBalanceValidationsEmailSendsDisabled:
      analyticsManager?.track(event: Event.issueCardEmailSendsDisabled)
    default:
      analyticsManager?.track(event: Event.issueCardUnknownError)
    }
  }

  private func issueCard() {
    viewModel.state.send(IssueCardViewState.loading)
    interactor.issueCard { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.trackError(error: error as? BackendError)
        let backendError = (error as? BackendError) ?? BackendError(code: .undefinedError)
        self.viewModel.state.send(IssueCardViewState.error(error: backendError))
      case .success(let card):
        self.viewModel.state.send(.done)
        self.router.cardIssued(card)
      }
    }
  }
}
