//
//  ShiftCardTransactionDetailsPresenter.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/03/2018.
//
//

import Foundation
import AptoSDK
import Bond

class ShiftCardTransactionDetailsPresenter: ShiftCardTransactionDetailsPresenterProtocol {
  // swiftlint:disable implicitly_unwrapped_optional
  var view: ShiftCardTransactionDetailsViewProtocol!
  var interactor: ShiftCardTransactionDetailsInteractorProtocol!
  var router: ShiftCardTransactionDetailsRouterProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
  var viewModel: ShiftCardTransactionDetailsViewModel
  var analyticsManager: AnalyticsServiceProtocol?
  let rowsPerPage = 20

  init() {
    self.viewModel = ShiftCardTransactionDetailsViewModel()
  }

  func viewLoaded() {
    refreshData()
    analyticsManager?.track(event: Event.transactionDetail)
  }

  fileprivate func refreshData() {
    view?.showLoadingSpinner()
    interactor?.provideTransaction { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.view?.show(error: error)
      case .success(let transaction):
        self.refreshViewModelWith(transaction: transaction)
        self.view?.finishUpdates()
        self.view?.hideLoadingSpinner()
      }
    }
  }

  func previousTapped() {
    router?.backFromTransactionDetails()
  }

  func mapTapped() {
    if let latitude = viewModel.latitude.value, let longitude = viewModel.longitude.value {
      router?.openMapsCenteredIn(latitude: latitude, longitude: longitude)
    }
  }

  private func refreshViewModelWith(transaction: Transaction) {
    viewModel.latitude.send(transaction.store?.latitude)
    viewModel.longitude.send(transaction.store?.longitude)
    viewModel.mccIcon.send(transaction.merchant?.mcc?.icon)
    viewModel.description.send(transaction.transactionDescription?.capitalized)
    viewModel.fiatAmount.send(transaction.localAmountRepresentation)
    viewModel.nativeAmount.send(transaction.nativeBalance?.absText)
    //address
    viewModel.transactionDate.send(self.format(date: transaction.createdAt))
    viewModel.transactionStatus.send(transaction.state.description())
    let genericDeclineReason = "transaction_details.details.decline_default.description".podLocalized()
    viewModel.declineReason.send(transaction.declineCode?.description ?? genericDeclineReason)
    viewModel.category.send(
      transaction.merchant?.mcc?.description() ?? "transaction_details.basic_info.category.unavailable".podLocalized()
    )
    // Funding source
    if let fee = transaction.feeAmount?.amount.value, abs(fee) > Double(0) {
      viewModel.fee.send(transaction.feeAmount?.absText)
    }
    else {
      viewModel.fee.send(nil)
    }
    // Currency exchange???
    if let (nativeAmount, fiatAmount) = computeExchangeRateFor(adjustments: transaction.adjustments),
      let nativeCurrencySymbol = nativeAmount.currencySymbol {
      viewModel.exchangeRate.send("1 \(nativeCurrencySymbol) ≈ \(fiatAmount.exchangeText)")
    }
    else {
      viewModel.exchangeRate.send(nil)
    }
    viewModel.fundingSourceName.send(transaction.fundingSourceName)
    viewModel.deviceType.send(transaction.deviceType.description())
    viewModel.transactionClass.send(transaction.transactionClass.description())
    viewModel.transactionType.send(transaction.transactionType.description())
    viewModel.transactionId.send(transaction.transactionId)
    if let adjustments = transaction.adjustments {
      viewModel.adjustments.insert(contentsOf: adjustments, at: 0)
    }
  }
}

private extension ShiftCardTransactionDetailsPresenter {
  static var dateFormatterWithYear = DateFormatter.customLocalizedDateFormatter(dateFormat: "MMMddYYYYhhmm")

  func format(date: Date?) -> String? {
    guard let date = date else {
      return nil
    }
    return ShiftCardTransactionDetailsPresenter.dateFormatterWithYear.string(from: date)
  }

  func computeExchangeRateFor(adjustments: [TransactionAdjustment]?) -> (Amount, Amount)? {
    guard let adjustments = adjustments else {
      return nil
    }
    var fiatAmount: Double = 0
    var nativeAmount: Double = 0
    for adjustment in adjustments {
      fiatAmount += adjustment.localAmount?.amount.value ?? 0
      nativeAmount += adjustment.nativeAmount?.amount.value ?? 0
    }
    guard nativeAmount != 0 else { return nil }
    return (Amount(value: nativeAmount / nativeAmount, currency: adjustments.first?.nativeAmount?.currency.value),
            Amount(value: fiatAmount / nativeAmount, currency: adjustments.first?.localAmount?.currency.value))
  }
}
