import Foundation

final class PaymentMethodsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
  
  private var tableView: UITableView?
  
  var items: [PaymentMethodItem] = [] {
    didSet { tableView?.reloadData() }
  }
  
  func configure(tableView: UITableView) {
    self.tableView = tableView
    tableView.backgroundColor = .white
    tableView.register(PaymentMethodCell.self, forCellReuseIdentifier: PaymentMethodCell.identifier)
    tableView.estimatedRowHeight = 80
    tableView.contentInset = UIEdgeInsets(top: -25, left: 0, bottom: 0, right: 0)
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodCell.identifier, for: indexPath) as? PaymentMethodCell else { fatalError() }
    guard let item = self.item(at: indexPath) else { fatalError() }
    cell.configure(with: item)
    return cell
  }
 
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    80
  }
 
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let item = self.item(at: indexPath) else { return }
    item.action?(item)
  }
  
  private func item(at indexPath: IndexPath) -> PaymentMethodItem? {
    guard indexPath.row <= items.count else { return nil }
    return items[indexPath.row]
  }
}
