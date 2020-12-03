import Foundation
import AptoSDK

final class TransferStatusDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
  
  private var tableView: UITableView?
    private var uiConfig: UIConfig?
  var items: [TransferStatusItem] = [] {
    didSet { tableView?.reloadData() }
  }
    
  init(uiConfig: UIConfig){
      self.uiConfig = uiConfig
  }
  
  func configure(tableView: UITableView) {
    tableView.backgroundColor = uiConfig?.uiBackgroundPrimaryColor
    tableView.register(TransferStatusCell.self, forCellReuseIdentifier: TransferStatusCell.identifier)
    tableView.estimatedRowHeight = 56
    tableView.dataSource = self
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: TransferStatusCell.identifier, for: indexPath) as? TransferStatusCell else { fatalError() }
    guard indexPath.row <= items.count else { fatalError() }
    let item = items[indexPath.row]
    cell.configure(with: item, uiConfig: uiConfig)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    56
  }
}
