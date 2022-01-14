import Foundation
import UIKit

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

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodCell.identifier,
                                                       for: indexPath)
            as? PaymentMethodCell else { return UITableViewCell() }
        guard let item = item(at: indexPath) else { return UITableViewCell() }
        cell.configure(with: item)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        80
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = item(at: indexPath) else { return }
        item.action?(item)
    }

    func tableView(_: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let item = item(at: indexPath) else { return false }
        return (item.type == .card || item.type == .bankAccount) &&
            !item.isSelected
    }

    func tableView(_: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            guard let item = item(at: indexPath) else { return }
            item.deleteAction?(item)
        }
    }

    private func item(at indexPath: IndexPath) -> PaymentMethodItem? {
        guard indexPath.row <= items.count else { return nil }
        return items[indexPath.row]
    }
}
