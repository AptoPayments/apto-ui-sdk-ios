import UIKit
import SnapKit
import AptoSDK
import ReactiveKit

final class TransferStatusView: UIView {
  
  private let scrollView = UIScrollView()
  private let uiConfig: UIConfig
    
  
  private let statusIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .imageFromPodBundle("transaction_ok_icon")
    return imageView
  }()
  
  private lazy var transferStateLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 24, weight: .semibold)
    label.textColor = uiConfig.textPrimaryColor
    return label
  }()
  
  private(set) lazy var disclaimerLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    label.numberOfLines = 0
    label.isUserInteractionEnabled = true
    label.lineBreakMode = .byWordWrapping
    return label
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.isScrollEnabled = false
    tableView.separatorStyle = .none
    return tableView
  }()
  
  private var closeButton: UIButton!
  private lazy var dataSource: TransferStatusDataSource = {
      let dataSource = TransferStatusDataSource(uiConfig: uiConfig)
      return dataSource
  }()
  private var viewModel: TransferStatusViewModelType?
  private let disposeBag = DisposeBag()
  
    init(uiConfig: UIConfig) {
    self.uiConfig = uiConfig
    super.init(frame: .zero)
    setupView()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Setup View
  
  private func setupView() {
    backgroundColor = .white
    statusIcon.tintColor = uiConfig.uiPrimaryColor
    
    self.closeButton = .roundedButtonWith("load_funds.transaction.primary_cta".podLocalized(), backgroundColor: uiConfig.uiPrimaryColor ?? .blue, cornerRadius: 24) { [weak self] in
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
      case .loaded(let items, let amount, let softDescriptor):
        self?.dataSource.items = items
        self?.configureTransferState(with: amount, softDescriptor: softDescriptor)
      }
    }).dispose(in: self.disposeBag)
  }
  
    private func configureTransferState(with amount: Amount, softDescriptor: String) {
    let title = "load_funds.transaction.successfull.description".podLocalized().replacingOccurrences(of: "<<VALUE>>", with: amount.absText)
    let bankDescriptionText = "load_funds.transaction.bank_description".podLocalized().replacingOccurrences(of: "<<VALUE>>", with: softDescriptor)
    let learnMoreLinkText = "\n" + "load_funds.transaction.learn_more".podLocalized()
    let bankDescription = NSMutableAttributedString(string: bankDescriptionText, attributes: [.foregroundColor: uiConfig.textPrimaryColor])
    let learnMoreLink = NSMutableAttributedString(string: learnMoreLinkText, attributes: [.foregroundColor: uiConfig.textLinkColor])
    let disclaimerText = NSMutableAttributedString()
    disclaimerText.append(bankDescription)
    disclaimerText.append(learnMoreLink)
        self.disclaimerLabel.attributedText = disclaimerText
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
            constraints.top.equalToSuperview().inset(self.statusIconTopConstraint())
        }
        
        transferStateLabel.snp.makeConstraints { constraints in
            constraints.centerX.equalToSuperview()
            constraints.leading.greaterThanOrEqualToSuperview().offset(16)
            constraints.trailing.lessThanOrEqualToSuperview().offset(16)
            constraints.top.equalTo(statusIcon.snp.bottom).offset(16)
        }
        
        disclaimerLabel.snp.makeConstraints { constraints in
            constraints.leading.equalTo(self).offset(16)
            constraints.trailing.equalTo(self).inset(16)
            constraints.top.equalTo(tableView.snp.bottom).offset(16)
            constraints.bottom.lessThanOrEqualToSuperview().inset(32)
        }
        
        tableView.snp.makeConstraints { constraints in
            constraints.leading.equalTo(self)
            constraints.trailing.equalTo(self)
            constraints.height.equalTo(250)
            constraints.top.equalTo(transferStateLabel.snp.bottom).offset(self.tableViewTopConstraint())
        }
        
        closeButton.snp.makeConstraints { constraints in
            constraints.leading.equalToSuperview().inset(16)
            constraints.trailing.equalToSuperview().inset(16)
            constraints.bottom.equalToSuperview().inset(32)
            constraints.height.equalTo(52)
        }
    }
    
    private func statusIconTopConstraint() -> CGFloat {
        UIScreen.main.bounds.height > 667 ? 100 : 30
    }

    private func tableViewTopConstraint() -> CGFloat {
        UIScreen.main.bounds.height > 667 ? 100 : 60
    }
}
