import UIKit
import SnapKit

final class TextInputView: UIView {
  
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
    textField.autocorrectionType = .no
    return textField
  }()
  
  var validator: ((String?) -> Bool)?
  var didChangeValue: ((String?) -> Void)?
  
  var value: String? {
    textField.text
  }
  
  var placeholder: String? {
    set { textField.placeholder = newValue }
    get { textField.placeholder }
  }
  
  var keyboardType: UIKeyboardType {
    set { textField.keyboardType = newValue }
    get { textField.keyboardType }
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
    addSubview(textField)
    
    textField.delegate = self
    textField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)
  }
  
  private func setupConstraints() {
    snp.makeConstraints { constraints in
      constraints.height.equalTo(48)
    }
    borderedView.snp.makeConstraints { constraints in
      constraints.edges.equalToSuperview().inset(2)
    }
    textField.snp.makeConstraints { constraints in
      constraints.leading.equalToSuperview().offset(16)
      constraints.trailing.equalToSuperview().offset(-16)
      constraints.centerY.equalToSuperview()
    }
  }
}

// MARK: - UITextFieldDelegate

extension TextInputView: UITextFieldDelegate {
  @objc private func didChangeTextField(_ notification: NSNotification?) {
    self.didChangeValue?(textField.text)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let inputIsValidated = validator?(textField.text) ?? true

    if !inputIsValidated {
      borderedView.showError()
    } else {
      borderedView.hideError()
    }
  }
}
