import UIKit
import SnapKit
import ReactiveKit

final class PaymentMethodsView: UIView {
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    return tableView
  }()
  
  private lazy var activityIndicatorView: UIActivityIndicatorView = {
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    return activityIndicatorView
  }()
  
  var items: [PaymentMethodItem] = [] {
    didSet { dataSource.items = items }
  }
  
  private let dataSource = PaymentMethodsDataSource()
  private var viewModel: PaymentMethodsViewModelType?
  private let disposeBag = DisposeBag()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Setup View
  
  private func setupView() {
    backgroundColor = .white
    addSubview(tableView)
    addSubview(activityIndicatorView)
    dataSource.configure(tableView: tableView)
  }
  
  private func setupConstraints() {
    tableView.snp.makeConstraints { constraints in
      constraints.edges.equalToSuperview()
    }
    
    activityIndicatorView.snp.makeConstraints { constraints in
      constraints.center.equalTo(tableView)
    }
  }
}
