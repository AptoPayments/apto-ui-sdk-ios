//
//  CategorySpendingCellController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/01/2019.
//

import AptoSDK
import Foundation

class CategorySpendingCellController: CellController {
    private let categorySpending: CategorySpending
    private let uiConfig: UIConfig
    private var cell: CategorySpendingCell?

    var isHighlighted: Bool = false {
        didSet {
            cell?.highlight(isHighlighted)
        }
    }

    init(categorySpending: CategorySpending, uiConfig: UIConfig) {
        self.categorySpending = categorySpending
        self.uiConfig = uiConfig
        super.init()
    }

    override func cellClass() -> AnyClass? {
        return CategorySpendingCell.classForCoder()
    }

    override func reuseIdentificator() -> String? {
        return NSStringFromClass(CategorySpendingCell.classForCoder())
    }

    override func setupCell(_ cell: UITableViewCell) {
        guard let cell = cell as? CategorySpendingCell else { return }
        self.cell = cell
        cell.setUIConfig(uiConfig)
        cell.set(image: categorySpending.categoryId.image(),
                 categoryName: categorySpending.categoryId.name,
                 amount: categorySpending.spending)
    }
}
