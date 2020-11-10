import UIKit
import SnapKit
import ReactiveKit
import Bond
import AptoSDK

final class AddFundsView: UIView {
  
  private lazy var textField: UITextField = {
    let textField = UITextField()
    textField.font = .boldSystemFont(ofSize: 44)
    textField.keyboardType = .decimalPad
    textField.textAlignment = .center
    textField.placeholder = "$0"
    return textField
  }()
  
  private lazy var currentCardView = CurrentCardView()
  private let keyboardWatcher = KeyboardWatcher()
  private let paymentSourceMapper = PaymentSourceMapper()
  private var nextButton: UIButton!
  private let disposeBag = DisposeBag()
  private var uiConfig: UIConfig?
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 10
    return stackView
  }()
  
  var didChangeAmountValue: ((String?) -> Void)?
  var didTapOnChangeCurrentCard: (() -> Void)?
  
  private var viewModel: AddFundsViewModelType?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
    watchKeyboard()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Setup View
  
  private func setupView() {
    backgroundColor = .white
    addSubview(textField)

    self.nextButton = .roundedButtonWith("load_funds.add_money.primary_cta".podLocalized(), backgroundColor: .blue, cornerRadius: 24) { [weak self] in
      self?.viewModel?.input.didTapOnPullFunds()
    }
    self.nextButton.isHidden = true
    
    stackView.addArrangedSubview(currentCardView)
    stackView.addArrangedSubview(nextButton)
    
    addSubview(stackView)
    
    textField.becomeFirstResponder()
    textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
  }
  
  private func updateUIConfig() {
    self.nextButton.backgroundColor = uiConfig?.uiPrimaryColor
  }
  
  func set(uiConfig: UIConfig?) {
    self.uiConfig = uiConfig
    self.updateUIConfig()
  }
  
  func set(current paymentSource: PaymentSource?) {
    guard let paymentSource = paymentSource else {
      self.configureDefaultState()
      return
    }
    
    switch paymentSource {
    case .card(let card):
      self.configureCardPaymentSource(card: card)
    default:
      break
    }
  }
  
  func use(viewModel: AddFundsViewModelType) {
    self.viewModel = viewModel
    self.bind()
  }
  
  private func bind() {
    viewModel?.output.nextButtonEnabled.observeNext(with: { [weak self] nextButtonIsEnabled in
      self?.nextButton.isHidden = !nextButtonIsEnabled
    }).dispose(in: disposeBag)
  }
  
  private func configureCardPaymentSource(card: CardPaymentSource) {
    let config = CurrentCardConfig(
      title: "•••• \(card.lastFour)",
      subtitle: card.title,
      icon: self.paymentSourceMapper.icon(from: card.network),
      action: CurrentCardConfig.Action(
        title: "load_funds.add_money.change_card".podLocalized(),
        action: { [weak self] in
          self?.didTapOnChangeCurrentCard?()
    }))
    currentCardView.configure(with: config)
  }

  private func configureDefaultState() {
    let config = CurrentCardConfig(
      title: "load_funds.add_money.no_payment_method".podLocalized(),
      icon: .imageFromPodBundle("credit_debit_card"),
      action: CurrentCardConfig.Action(
        title: "load_funds.add_money.add_card".podLocalized(),
        action: { [weak self] in
          self?.didTapOnChangeCurrentCard?()
    }))
    currentCardView.configure(with: config)
  }
  
  private func watchKeyboard() {
    keyboardWatcher.startWatching(onKeyboardShown: { [weak self] size in
      guard let self = self else { return }
      self.textField.snp.updateConstraints { constraints in
        constraints.bottom.equalToSuperview().inset(size.height + 80)
      }
      self.stackView.snp.updateConstraints { constraints in
        constraints.bottom.equalToSuperview().inset(size.height + 16)
      }
    })
  }
  
  private func setupConstraints() {
    textField.snp.makeConstraints { constraints in
      constraints.leading.equalToSuperview().inset(16)
      constraints.trailing.equalToSuperview().inset(16)
      constraints.top.equalToSuperview()
      constraints.bottom.equalToSuperview()
    }
    
    stackView.snp.makeConstraints { constraints in
      constraints.leading.equalToSuperview().offset(16)
      constraints.trailing.equalToSuperview().inset(16)
      constraints.bottom.equalToSuperview().inset(16)
    }
    
    nextButton.snp.makeConstraints { constraints in
      constraints.height.equalTo(52)
    }
  }
}

// MARK: - UITextField

extension AddFundsView {
  @objc private func textFieldDidChange(_ textField: UITextField) {
    self.didChangeAmountValue?(textField.text)
  }
}
