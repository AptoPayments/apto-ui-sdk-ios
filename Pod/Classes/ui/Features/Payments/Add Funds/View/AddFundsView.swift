import UIKit
import SnapKit
import ReactiveKit
import Bond
import AptoSDK

final class AddFundsView: UIView {
  
    static let maxAllowedDigit = 4

  private lazy var textField: UITextField = {
    let textField = ComponentCatalog.textFieldWith(placeholder: "$0",placeholderColor: uiConfig.textSecondaryColor, font: .boldSystemFont(ofSize: 44), textColor: uiConfig.textPrimaryColor)
    textField.keyboardType = .decimalPad
    textField.textAlignment = .center
    return textField
  }()
  private lazy var currentCardView = CurrentCardView()
  private let keyboardWatcher = KeyboardWatcher()
  private let paymentSourceMapper = PaymentSourceMapper()
  private var nextButton: UIButton!
  private let disposeBag = DisposeBag()
  private var uiConfig: UIConfig
  
    private(set) lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = uiConfig.fontProvider.formTextLink
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 10
    return stackView
  }()
  
  var didChangeAmountValue: ((String?) -> Void)?
  var didTapOnChangeCurrentCard: (() -> Void)?
  
  private var viewModel: AddFundsViewModelType?
  
  init(uiConfig: UIConfig) {
    self.uiConfig = uiConfig
        super.init(frame: .zero)
    setupView()
    setupConstraints()
    watchKeyboard()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Setup View
  
  private func setupView() {
    backgroundColor = .white
    textField.addSubview(errorLabel)
    addSubview(textField)

    self.nextButton = .roundedButtonWith("load_funds.add_money.primary_cta".podLocalized(), backgroundColor: uiConfig.uiPrimaryColor, cornerRadius: 24) { [weak self] in
      self?.viewModel?.input.didTapOnPullFunds()
    }
    self.nextButton.isHidden = true
    
    stackView.addArrangedSubview(currentCardView)
    stackView.addArrangedSubview(nextButton)
    
    addSubview(stackView)
    
    textField.becomeFirstResponder()
    textField.delegate = self
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
    errorLabel.snp.makeConstraints { make in
        make.left.right.equalToSuperview().inset(16)
        make.centerY.equalToSuperview().offset(38)
    }
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
    
    // MARK: Public method
    func dailyLimitError(_ limit: String, show: Bool) {
        if show {
            errorLabel.text = "load_funds.add_money.monthly_max.reached".podLocalized().replace(["<<MAX>>" : limit])
            UIView.animate(withDuration: 0.3) { [errorLabel] in
                errorLabel.alpha = 1
            }
        } else {
            errorLabel.alpha = 0
        }
    }
}


// MARK: - UITextField
extension AddFundsView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        dailyLimitError("", show: false)
        if (!string.isEmpty && !Character(string).isNumber) {
            return false
        }

        guard let text = textField.text else { return false }
        
        if text.count == 1 && string.isEmpty {
            didChangeAmountValue?(nil)
        } else {
            if text.count + 1 <= AddFundsView.maxAllowedDigit {
                didChangeAmountValue?(updateAmountIfNeeded(lastChar: string, text: text + string))
            } else {
                didChangeAmountValue?(updateAmountIfNeeded(lastChar: string, text: text))
            }
        }
        
        if string.isEmpty && text.count <= AddFundsView.maxAllowedDigit {
            return true
        }
        return text.count < AddFundsView.maxAllowedDigit
    }
    
    private func updateAmountIfNeeded(lastChar: String, text: String) -> String {
        let amount = lastChar.isEmpty ? String(text.dropLast()) : text
        return Double(amount) != nil ? amount : ""
    }
}
