import UIKit
import SnapKit

final class CardInputView: UIView {
  
  private let cardDetector = CardDetector()
  private let cardFormatter = CardFormatter()
  
  var didChangeFocus: (() -> Void)?
  var didChangeCard: ((_ card: String, _ type: CardType) -> Void)?
  
  private lazy var cardIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage.imageFromPodBundle("credit_debit_card")
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private lazy var lockIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage.imageFromPodBundle("card_lock")
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var borderedView: BorderedView = {
    let borderedView = BorderedView()
    borderedView.set(borderWidth: 1)
    borderedView.set(borderColor: .colorFromHexString("E9EBEE")!)
    borderedView.set(cornerRadius: 8)
    return borderedView
  }()
  
  private lazy var textField: UITextField = {
    let textField = UITextField()
    textField.font = .systemFont(ofSize: 16)
    textField.keyboardType = .numberPad
    textField.textContentType = .creditCardNumber
    return textField
  }()
   
  var value: String? {
    get { textField.text }
    set {
      textField.text = newValue
      didChangeTextField(nil)
    }
  }
  
  var placeholder: String? {
    set { textField.placeholder = newValue }
    get { textField.placeholder }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    setupConstraints()
  }

  required init?(coder: NSCoder) { fatalError() }
  
  // MARK: - Setup View
  
  private func setupView() {
    backgroundColor = .white
    addSubview(borderedView)
    addSubview(cardIcon)
    addSubview(lockIcon)
    addSubview(textField)
    
    textField.delegate = self
    textField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)
  }
 
  private func setupConstraints() {
    snp.makeConstraints { constraints in
      constraints.height.equalTo(48)
    }
    cardIcon.snp.makeConstraints { constraints in
      constraints.size.equalTo(CGSize(width: 30, height: 22))
      constraints.leading.equalToSuperview().inset(16)
      constraints.centerY.equalToSuperview()
    }
    borderedView.snp.makeConstraints { constraints in
      constraints.edges.equalToSuperview().inset(2)
    }
    textField.snp.makeConstraints { constraints in
      constraints.leading.equalTo(cardIcon.snp.trailing).offset(16)
      constraints.trailing.equalTo(lockIcon.snp.leading).offset(-16)
      constraints.centerY.equalToSuperview()
    }
    lockIcon.snp.makeConstraints { constraints in
      constraints.size.equalTo(CGSize(width: 16, height: 16))
      constraints.trailing.equalToSuperview().inset(16)
      constraints.centerY.equalToSuperview()
    }
  }
  
  @discardableResult
  override func becomeFirstResponder() -> Bool {
    textField.becomeFirstResponder()
  }
}

// MARK: - UITextField

extension CardInputView: UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let input = textField.text, !input.isEmpty else { return }
    
    let (cardType, isCardValid) = cardDetector.detect(input)
    
    if !isCardValid {
      borderedView.showError()
    } else {
      borderedView.hideError()
    }

    self.didChangeCard?(input, cardType)
  }
  
  @objc private func didChangeTextField(_ notification: NSNotification?) {
    guard let input = textField.text else { return }
    self.updateCardIcon(for: input)
    self.textField.text = cardFormatter.format(input)
  }
 
  private func updateCardIcon(for input: String) {
    switch cardDetector.detect(input) {
    case (.amex, _):
      cardIcon.image = .imageFromPodBundle("american_express")
    case (.visa, _):
      cardIcon.image = .imageFromPodBundle("visa")
    case (.discover, _):
      cardIcon.image = .imageFromPodBundle("discover")
    case (.mastercard, _):
      cardIcon.image = .imageFromPodBundle("mastercard")
    default:
      cardIcon.image = .imageFromPodBundle("credit_debit_card")
    }
  }
}
