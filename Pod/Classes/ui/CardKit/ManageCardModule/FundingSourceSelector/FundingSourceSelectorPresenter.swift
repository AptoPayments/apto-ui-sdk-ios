//
// FundingSourceSelectorPresenter.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/12/2018.
//

import AptoSDK
import Foundation

class FundingSourceSelectorPresenter: FundingSourceSelectorPresenterProtocol {
    // swiftlint:disable implicitly_unwrapped_optional
    weak var router: FundingSourceSelectorModuleProtocol!
    var interactor: FundingSourceSelectorInteractorProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    let viewModel = FundingSourceSelectorViewModel()
    let config: FundingSourceSelectorPresenterConfig
    var analyticsManager: AnalyticsServiceProtocol?

    init(config: FundingSourceSelectorPresenterConfig) {
        self.config = config
    }

    func viewLoaded() {
        viewModel.hideReconnectButton.send(config.hideFundingSourcesReconnectButton)
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
                case .failure:
                    self.router.show(message: "manage_card.funding_source_selector.error.message".podLocalized(),
                                     title: "manage_card.funding_source_selector.error.title".podLocalized(),
                                     isError: true)
                    self.router.close()
                case .success:
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
            switch result {
            case let .failure(error):
                self.viewModel.showLoadingSpinner.send(false)
                self.router.show(error: error)
            case let .success(fundingSources):
                let sortedFundingSources = fundingSources.sorted {
                    $0.balance?.amount.value ?? 0 > $1.balance?.amount.value ?? 0
                }
                self.interactor.activeCardFundingSource(forceRefresh: forceRefresh) { [weak self] result in
                    guard let self = self else { return }
                    self.viewModel.showLoadingSpinner.send(false)
                    switch result {
                    case let .failure(error):
                        self.router.show(error: error)
                    case let .success(fundingSource):
                        self.viewModel.fundingSources.send(sortedFundingSources)
                        if let idx = sortedFundingSources.firstIndex(where: {
                            $0.fundingSourceId == fundingSource?.fundingSourceId
                        }) {
                            self.viewModel.activeFundingSourceIdx.send(idx)
                        } else {
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
