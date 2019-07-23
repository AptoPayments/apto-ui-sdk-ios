//
// TransactionListCellControllerTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-14.
//

import Foundation
import AptoSDK

class TransactionListCellControllerTheme2: CellController {
  private let transaction: Transaction
  private let uiConfiguration: UIConfig
  private var cell: TransactionListCellTheme2?

  var isLastCellInSection: Bool = false {
    didSet {
      cell?.isLastCellInSection = isLastCellInSection
    }
  }

  init(transaction: Transaction, uiConfiguration: UIConfig) {
    self.transaction = transaction
    self.uiConfiguration = uiConfiguration
    super.init()
  }

  override func cellClass() -> AnyClass? {
    return TransactionListCellTheme2.classForCoder()
  }

  override func reuseIdentificator() -> String? {
    return NSStringFromClass(TransactionListCellTheme2.classForCoder())
  }

  override func setupCell(_ cell: UITableViewCell) {
    guard let cell = cell as? TransactionListCellTheme2 else {
      return
    }
    self.cell = cell
    cell.setUIConfiguration(uiConfiguration)
    cell.set(mcc: transaction.merchant?.mcc,
             amount: transaction.localAmountRepresentation,
             nativeAmount: transaction.nativeBalance?.absText,
             transactionDescription: transaction.transactionDescription,
             date: transaction.createdAt,
             state: transaction.state)
    cell.cellController = self
  }
}

