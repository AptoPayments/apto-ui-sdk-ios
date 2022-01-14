import AptoSDK
import Foundation
import UIKit

final class TransferStatusDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView?
    private var uiConfig: UIConfig?
    var items: [TransferStatusItem] = [] {
        didSet { tableView?.reloadData() }
    }

    init(uiConfig: UIConfig) {
        self.uiConfig = uiConfig
    }

    func configure(tableView: UITableView) {
        tableView.backgroundColor = uiConfig?.uiBackgroundPrimaryColor
        tableView.register(TransferStatusCell.self, forCellReuseIdentifier: TransferStatusCell.identifier)
        tableView.estimatedRowHeight = 56
        tableView.dataSource = self
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: TransferStatusCell.identifier,
                                 for: indexPath) as? TransferStatusCell
        else {
            return UITableViewCell()
        }
        guard indexPath.row <= items.count else { return UITableViewCell() }
        let item = items[indexPath.row]
        cell.configure(with: item, uiConfig: uiConfig)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        56
    }
}
