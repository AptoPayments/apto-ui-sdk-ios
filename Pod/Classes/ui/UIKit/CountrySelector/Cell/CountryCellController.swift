//
// CountryCellController.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/05/2019.
//

import Foundation
import AptoSDK

class CountryCellController: CellController {
  let country: Country
  private let uiConfig: UIConfig
  private var cell: CountryCell?

  var isSelected: Bool = false {
    didSet {
      cell?.selected(isSelected)
    }
  }

  init(country: Country, uiConfig: UIConfig) {
    self.country = country
    self.uiConfig = uiConfig
    super.init()
  }

  override func cellClass() -> AnyClass? {
    return CountryCell.classForCoder()
  }

  override func reuseIdentificator() -> String? {
    return NSStringFromClass(CountryCell.classForCoder())
  }

  override func setupCell(_ cell: UITableViewCell) {
    guard let cell = cell as? CountryCell else { return }
    self.cell = cell
    cell.setUIConfig(uiConfig)
    cell.set(country: country)
  }
}
