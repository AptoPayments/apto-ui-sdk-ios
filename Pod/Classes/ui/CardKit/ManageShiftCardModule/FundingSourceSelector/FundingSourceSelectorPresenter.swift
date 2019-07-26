//
// FundingSourceSelectorPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/12/2018.
//

import Foundation
import AptoSDK

class FundingSourceSelectorPresenter: FundingSourceSelectorPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  weak var router: FundingSourceSelectorModuleProtocol!
  var interactor: FundingSourceSelectorInteractorProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  let viewModel = FundingSourceSelectorViewModel()
  var analyticsManager: AnalyticsServiceProtocol?

  func viewLoaded() {
    refreshData(forceRefresh: false)
    analyticsManager?.track(event: Event.manageCardFundingSourceSelector)
  }

  func closeTapped() {
    router.close()
  }

  func refreshDataTapped() {
    refreshData(forceRefresh: true)
  }

  func fundingSourceSelected(index: Int) {
    guard index != viewModel.activeFundingSourceIdx.value else {
      return
    }
    let fundingSources = viewModel.fundingSources.value
    if index < fundingSources.count {
      viewModel.showLoadingSpinner.send(true)
      interactor.setActive(fundingSource: fundingSources[index]) { [weak self] result in
        guard let self = self else { return }
        self.viewModel.showLoadingSpinner.send(false)
        switch result {
        case .failure(_):
          self.router.show(message: "manage_card.funding_source_selector.error.message".podLocalized(),
                           title: "manage_card.funding_source_selector.error.title".podLocalized(),
                           isError: true)
          self.router.close()
        case .success(_):
          self.router.show(message: "manage_card.funding_source_selector.success.message".podLocalized(),
                           title: "manage_card.funding_source_selector.success.title".podLocalized(),
                           isError: false)
          self.router.fundingSourceChanged()
        }
      }
    }
  }

  func addFundingSourceTapped() {
    router.addFundingSource { [weak self] _ in
      self?.refreshData(forceRefresh: true)
    }
  }

  // MARK: - Private methods
  private func refreshData(forceRefresh: Bool) {
    viewModel.showLoadingSpinner.send(true)
    interactor.loadFundingSources(forceRefresh: forceRefresh) { [weak self] result in
      guard let self = self else { return }
      self.viewModel.showLoadingSpinner.send(false)
      switch result {
      case .failure(let error):
        self.router.show(error: error)
      case .success(let fundingSources):
        self.viewModel.showLoadingSpinner.send(true)
        self.interactor.activeCardFundingSource(forceRefresh: forceRefresh) { [weak self] result in
          guard let self = self else { return }
          self.viewModel.showLoadingSpinner.send(false)
          switch result {
          case .failure(let error):
            self.router.show(error: error)
          case .success(let fundingSource):
            self.viewModel.fundingSources.send(fundingSources)
            if let idx = fundingSources.firstIndex(where: { $0.fundingSourceId == fundingSource?.fundingSourceId }) {
              self.viewModel.activeFundingSourceIdx.send(idx)
            }
            else {
              self.viewModel.activeFundingSourceIdx.send(nil)
            }
            if self.viewModel.dataLoaded.value == false {
              self.viewModel.dataLoaded.send(true)
            }
          }
        }
      }
    }
  }
}
