//
//  TransactionListCellControllerTheme1.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 20/03/16.
//
//

import Foundation
import AptoSDK

class TransactionListCellControllerTheme1: CellController {
  private let transaction: Transaction
  private let uiConfiguration: UIConfig

  init(transaction: Transaction, uiConfiguration: UIConfig) {
    self.transaction = transaction
    self.uiConfiguration = uiConfiguration
    super.init()
  }

  override func cellClass() -> AnyClass? {
    return TransactionListCellTheme1.classForCoder()
  }

  override func reuseIdentificator() -> String? {
    return NSStringFromClass(TransactionListCellTheme1.classForCoder())
  }

  override func setupCell(_ cell: UITableViewCell) {
    guard let cell = cell as? TransactionListCellTheme1 else {
      return
    }
    cell.setUIConfiguration(uiConfiguration)
    cell.set(mcc: transaction.merchant?.mcc,
             amount: transaction.localAmountRepresentation,
             transactionDescription: transaction.transactionDescription,
             date: transaction.createdAt)
    cell.cellController = self
  }
}
