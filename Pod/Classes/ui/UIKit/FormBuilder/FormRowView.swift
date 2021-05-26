//
//  FormRowView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 31/01/16.
//
//

import UIKit
import AptoSDK
import SnapKit
import Bond

protocol ReturnButtonListenerProtocol {
  func focusNextRowfrom(row: FormRowView) -> Bool
  func focusPreviousRowfrom(row: FormRowView) -> Bool
}

protocol ValidationResultPresenterProtocol {
  func presentNonPassedValidationResult(_ reason: String)
  func presentPassedValidationResult()
}

protocol FormFocusPresenterProtocol {
  func presentFocusedState()
  func presentNonFocusedState()
}

protocol RowFocusListenerProtocol {
  func rowDidBeginEditing(_ row: FormRowView)
  func rowDidEndEditing(_ row: FormRowView)
}

open class FormRowView: UIControl, FormFocusPresenterProtocol, ValidationResultPresenterProtocol {

  // Observable flag indicating that this row has passed validation
  let valid = Observable(true)
  let validationMessage = Observable("")

  var showSplitter: Bool {
    didSet {
      if self.showSplitter {
        let splitter = UIView()
        self.splitter = splitter
        self.addSubview(splitter)
        splitter.backgroundColor = colorize(0xefefef, alpha: 1.0)
        splitter.snp.makeConstraints { make in
          make.left.right.equalTo(self.contentView)
          make.bottom.equalTo(self)
          make.height.equalTo(1)
        }
      }
      else {
        self.splitter?.removeFromSuperview()
      }
    }
  }
  var returnButtonListener: ReturnButtonListenerProtocol?
  var rowFocusListener: RowFocusListenerProtocol?
  let contentView: UIView
  var padding: UIEdgeInsets {
    didSet {
      self.setNeedsUpdateConstraints()
    }
  }
  var focusedColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
  var unfocusedColor = UIColor.black
  var splitter: UIView?

  init(showSplitter: Bool,
       padding: UIEdgeInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16),
       height: CGFloat = 40,
       maxHeight: CGFloat = 20000) {
    self.padding = padding
    self.contentView = UIView()
    self.showSplitter = showSplitter
    super.init(frame: CGRect(x: 0, y: 0, width: 320, height: height))
    self.snp.makeConstraints { make in
      make.height.greaterThanOrEqualTo(height)
      make.height.lessThanOrEqualTo(maxHeight)
    }
    self.addSubview(self.contentView)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    if showSplitter {
      let splitter = UIView()
      self.addSubview(splitter)
      splitter.backgroundColor = colorize(0xefefef, alpha: 1.0)
      splitter.snp.makeConstraints { make in
        make.left.right.equalTo(self.contentView)
        make.bottom.equalTo(self)
        make.height.equalTo(1)
      }
      self.splitter = splitter
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func updateConstraints() {
    super.updateConstraints()
    self.contentView.snp.remakeConstraints { make in
      make.edges.equalTo(self).inset(self.padding)
    }
  }

  func focus() {
    self.rowFocusListener?.rowDidBeginEditing(self)
    self.presentFocusedState()
  }

  func looseFocus() {
    self.rowFocusListener?.rowDidEndEditing(self)
    self.presentNonFocusedState()
    if self.valid.value {
      self.presentPassedValidationResult()
    }
    else {
      self.presentNonPassedValidationResult(self.validationMessage.value)
    }
  }

  func validate(_ result: Result<Bool, NSError>.Callback) {}

  // MARK: - ValidationResultPresenterProtocol
  func presentNonPassedValidationResult(_ reason: String) {}

  func presentPassedValidationResult() {}

  // MARK: - FormFocusPresenterProtocol

  func presentFocusedState() {}
  func presentNonFocusedState() {}
}

extension FormRowView {
  func validateText(_ validator: DataValidator<String>?, text: String?) {
    guard let validator = validator else {
      return
    }
    if !self.isEnabled {
      self.valid.send(true)
      self.validationMessage.send("")
      self.presentPassedValidationResult()
    }
    else {
      let result = validator.validate(text)
      switch result {
      case .pass:
        self.valid.send(true)
        self.validationMessage.send("")
        self.presentPassedValidationResult()
      case .fail(let reason):
        self.valid.send(false)
        self.validationMessage.send(reason)
      }
    }
  }

  func validateInt(_ validator: DataValidator<Int>?, number: Int?) {
    guard let validator = validator else {
      return
    }
    let result = validator.validate(number)
    switch result {
    case .pass:
      self.valid.send(true)
      self.validationMessage.send("")
      self.presentPassedValidationResult()
    case .fail(let reason):
      self.valid.send(false)
      self.validationMessage.send(reason)
    }
  }

  func validateDouble(_ validator: DataValidator<Double>?, number: Double?) {
    guard let validator = validator else {
      return
    }
    let result = validator.validate(number)
    switch result {
    case .pass:
      self.valid.send(true)
      self.validationMessage.send("")
      self.presentPassedValidationResult()
    case .fail(let reason):
      self.valid.send(false)
      self.validationMessage.send(reason)
    }
  }

  func validateDate(_ validator: DataValidator<Date>?, date: Date?) {
    guard let validator = validator else {
      return
    }
    let result = validator.validate(date)
    switch result {
    case .pass:
      self.valid.send(true)
      self.validationMessage.send("")
      self.presentPassedValidationResult()
    case .fail(let reason):
      self.valid.send(false)
      self.validationMessage.send(reason)
    }
  }
    
    func validateAddress(_ validator: DataValidator<Address>?, address: Address?) {
        guard let validator = validator else {
            return
        }
        let result = validator.validate(address)
        switch result {
        case .pass:
            self.valid.send(true)
            self.validationMessage.send("")
            self.presentPassedValidationResult()
        case .fail(let reason):
            self.valid.send(false)
            self.validationMessage.send(reason)
        }
    }
}
