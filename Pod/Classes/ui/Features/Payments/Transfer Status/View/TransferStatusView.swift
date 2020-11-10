import UIKit
import SnapKit
import AptoSDK
import ReactiveKit

final class TransferStatusView: UIView {
  
  private let scrollView = UIScrollView()
  private let uiConfig = AptoPlatform.defaultManager().fetchUIConfig()
  
  private let statusIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .imageFromPodBundle("transaction_ok_icon")
    return imageView
  }()
  
  private let transferStateLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 24, weight: .semibold)
    return label
  }()
  
  private let disclaimerLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    label.numberOfLines = 0
    label.text = "This transaction will appear in your bank account statement as: Acme Card Program – Cardholder Account Learn more in the Cardholder Agreement"
    return label
  }()
  
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.backgroundColor = .lightGray
    tableView.isScrollEnabled = false
    return tableView
  }()
  
  private var closeButton: UIButton!
  private let dataSource = TransferStatusDataSource()
  private var viewModel: TransferStatusViewModelType?
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
    statusIcon.tintColor = uiConfig?.uiPrimaryColor
    
    self.closeButton = .roundedButtonWith("load_funds.transaction.primary_cta".podLocalized(), backgroundColor: uiConfig?.uiPrimaryColor ?? .blue, cornerRadius: 24) { [weak self] in
      self?.viewModel?.input.didTapOnClose()
    }

    addSubview(scrollView)
    scrollView.addSubview(statusIcon)
    scrollView.addSubview(transferStateLabel)
    scrollView.addSubview(tableView)
    scrollView.addSubview(disclaimerLabel)
    addSubview(closeButton)
    
    dataSource.configure(tableView: tableView)
  }
  
  func use(viewModel: TransferStatusViewModelType) {
    self.viewModel = viewModel
    self.bind()
  }
  
  private func bind() {
    self.viewModel?.output.state.observeNext(with: { [weak self] state in
      switch state {
      case .idle:
        break
      case .loaded(let items, let amount):
        self?.dataSource.items = items
        self?.configureTransferState(with: amount)
      }
    }).dispose(in: self.disposeBag)
  }
  
  private func configureTransferState(with amount: Amount) {
    let title = "load_funds.transaction.successfull.description".podLocalized().replacingOccurrences(of: "<<VALUE>>", with: amount.absText)
    self.transferStateLabel.text = title
  }
  
  private func setupConstraints() {
    scrollView.snp.makeConstraints { constraints in
      constraints.leading.equalToSuperview()
      constraints.trailing.equalToSuperview()
      constraints.top.equalToSuperview()
      constraints.bottom.equalTo(closeButton.snp.top).inset(16)
    }
    
    statusIcon.snp.makeConstraints { constraints in
      constraints.size.equalTo(CGSize(width: 64, height: 64))
      constraints.centerX.equalToSuperview()
      constraints.top.equalToSuperview().inset(100)
    }
    
    transferStateLabel.snp.makeConstraints { constraints in
      constraints.centerX.equalToSuperview()
      constraints.leading.greaterThanOrEqualToSuperview().offset(16)
      constraints.trailing.lessThanOrEqualToSuperview().offset(16)
      constraints.top.equalTo(statusIcon.snp.bottom).offset(16)
    }
    
    disclaimerLabel.snp.makeConstraints { constraints in
      constraints.leading.greaterThanOrEqualToSuperview().offset(16)
      constraints.trailing.equalTo(self).inset(16)
      constraints.top.equalTo(tableView.snp.bottom).offset(16)
      constraints.bottom.lessThanOrEqualToSuperview().inset(32)
    }
    
    tableView.snp.makeConstraints { constraints in
      constraints.leading.equalTo(self)
      constraints.trailing.equalTo(self)
      constraints.height.equalTo(250)
      constraints.top.equalTo(transferStateLabel.snp.bottom).offset(100)
    }
    
    closeButton.snp.makeConstraints { constraints in
      constraints.leading.equalToSuperview().inset(16)
      constraints.trailing.equalToSuperview().inset(16)
      constraints.bottom.equalToSuperview().inset(32)
      constraints.height.equalTo(52)
    }
  }
}
