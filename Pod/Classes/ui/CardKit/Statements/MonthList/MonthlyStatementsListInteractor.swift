//
// MonthlyStatementsListInteractor.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/09/2019.
//

import Foundation
import AptoSDK

class MonthlyStatementsListInteractor: MonthlyStatementsListInteractorProtocol {
  private let platform: AptoPlatformProtocol

  init(platform: AptoPlatformProtocol) {
    self.platform = platform
  }

  func fetchStatementsPeriod(callback: @escaping Result<MonthlyStatementsPeriod, NSError>.Callback) {
    platform.fetchMonthlyStatementsPeriod(callback: callback)
  }
}
