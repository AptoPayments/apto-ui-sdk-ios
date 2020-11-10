import Foundation

final class TransferStatusDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
  
  private var tableView: UITableView?
  
  var items: [TransferStatusItem] = [] {
    didSet { tableView?.reloadData() }
  }
  
  func configure(tableView: UITableView) {
    tableView.backgroundColor = .white
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
    cell.configure(with: item)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    56
  }
}
