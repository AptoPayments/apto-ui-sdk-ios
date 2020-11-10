import UIKit
import SnapKit
import ReactiveKit
import Bond

final class AddCardView: UIView {

  private let expirationDateValidator = ExpirationDateValidator()
  private let keyboardWatcher = KeyboardWatcher()
  private var viewModel: AddCardViewModelType?
  private let disposeBag = DisposeBag()
  
  private let cardInputView: CardInputView = {
    let cardInput = CardInputView()
    cardInput.placeholder = "load_funds.add_card.card_number.placeholder".podLocalized()
    return cardInput
  }()
  
  private let expirationDateInputView: TextInputView = {
    let textInput = TextInputView()
    textInput.keyboardType = .asciiCapable
    textInput.placeholder = "load_funds.add_card.date.placeholder".podLocalized()
    return textInput
  }()
  
  private let cvvCodeInputView: TextInputView = {
    let textInput = TextInputView()
    textInput.keyboardType = .numberPad
    textInput.placeholder = "load_funds.add_card.cvv.placeholder".podLocalized()
    return textInput
  }()
  
  private let zipCodeInputView: TextInputView = {
    let textInput = TextInputView()
    textInput.keyboardType = .asciiCapable
    textInput.placeholder = "load_funds.add_card.zip.placeholder".podLocalized()
    return textInput
  }()
  
  private let mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()
  
  private let secondaryStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = .fillEqually
    return stackView
  }()

  private var addCardButton: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
    configureValidators()
    watchKeyboard()
  }
  
  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Setup View
  
  private func setupView() {
    backgroundColor = .white
    self.addCardButton = .roundedButtonWith("load_funds.add_card.primary_cta".podLocalized(), backgroundColor: .blue, cornerRadius: 24) { [weak self] in
      self?.endEditing(true)
      self?.viewModel?.input.didTapOnAddCard()
    }
    
    secondaryStackView.addArrangedSubview(expirationDateInputView)
    secondaryStackView.addArrangedSubview(cvvCodeInputView)
    
    mainStackView.addArrangedSubview(cardInputView)
    mainStackView.addArrangedSubview(secondaryStackView)
    mainStackView.addArrangedSubview(zipCodeInputView)
    
    addSubview(mainStackView)
    addSubview(addCardButton)
    
    cardInputView.becomeFirstResponder()
  }

  func use(viewModel: AddCardViewModelType) {
    self.viewModel = viewModel
    self.bind()
  }
 
  private func bind() {
    cardInputView.didChangeCard = { [weak self] (card, type) in
      self?.viewModel?.input.didChange(card: card, with: type)
    }
    
    expirationDateInputView.didChangeValue = { [weak self] expirationDate in
      guard let expirationDate = expirationDate else { return }
      self?.viewModel?.input.didChange(expiration: expirationDate)
    }
    
    cvvCodeInputView.didChangeValue = { [weak self] cvv in
      guard let cvv = cvv else { return }
      self?.viewModel?.input.didChange(cvv: cvv)
    }
    
    zipCodeInputView.didChangeValue = { [weak self] zipCode in
      guard let zipCode = zipCode else { return }
      self?.viewModel?.input.didChange(zipCode: zipCode)
    }
    
    viewModel?.output.addCardButtonEnabled.observeNext { [weak self] isEnabled in
      self?.addCardButton.isHidden = !isEnabled
    }.dispose(in: disposeBag)
  }
  
  private func watchKeyboard() {
    keyboardWatcher.startWatching(onKeyboardShown: { [weak self] size in
      guard let self = self else { return }
      self.addCardButton.snp.updateConstraints { constraints in
        constraints.bottom.equalToSuperview().inset(size.height + 16)
      }
    })
  }
  
  private func configureValidators() {
    expirationDateInputView.validator = { [expirationDateValidator] input in
      guard let input = input, !input.isEmpty else { return true }
      return expirationDateValidator.validate(input)
    }
  }
 
  private func setupConstraints() {
    mainStackView.snp.makeConstraints { constraints in
      constraints.leading.equalToSuperview().inset(16)
      constraints.trailing.equalToSuperview().inset(16)
      
      if #available(iOS 11.0, *) {
        constraints.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
      } else {
        constraints.top.equalToSuperview().offset(16)
      }
    }
    
    addCardButton.snp.makeConstraints { constraints in
      constraints.leading.equalToSuperview().inset(16)
      constraints.trailing.equalToSuperview().inset(16)
      constraints.height.equalTo(52)
      constraints.bottom.equalToSuperview().inset(16)
    }
  }
}
