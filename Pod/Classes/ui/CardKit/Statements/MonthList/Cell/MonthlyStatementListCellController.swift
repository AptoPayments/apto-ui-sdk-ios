//
//  MonthlyStatementListCellController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 02/10/2019.
//

import AptoSDK
import Foundation

class MonthlyStatementListCellController: CellController {
    private let month: Month
    private let uiConfig: UIConfig
    private var cell: MonthlyStatementListCell?

    var shouldDrawBottomDivider: Bool = false {
        didSet {
            cell?.shouldDrawBottomDivider = shouldDrawBottomDivider
        }
    }

    init(month: Month, uiConfig: UIConfig) {
        self.month = month
        self.uiConfig = uiConfig
        super.init()
    }

    override func cellClass() -> AnyClass? {
        return MonthlyStatementListCell.classForCoder()
    }

    override func reuseIdentificator() -> String? {
        return NSStringFromClass(MonthlyStatementListCell.classForCoder())
    }

    override func setupCell(_ cell: UITableViewCell) {
        guard let cell = cell as? MonthlyStatementListCell else { return }
        self.cell = cell
        cell.setUIConfig(uiConfig)
        cell.set(month: month)
        cell.cellController = self
    }
}
