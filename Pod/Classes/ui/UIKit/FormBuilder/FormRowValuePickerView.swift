//
//  FormValuePickerRowView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 04/02/16.
//
//

import AptoSDK
import Bond
import UIKit

@objc open class FormValuePickerValue: NSObject {
    let id: String
    let text: String

    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

open class FormRowValuePickerView: FormRowTextInputView {
    open var selectedValue: String? {
        didSet {
            if let value = values.first(where: { $0.id == selectedValue }) {
                textField.text = value.text
            } else {
                textField.text = nil
            }
        }
    }

    private let values: [FormValuePickerValue]

    // MARK: - Initializers

    public init(label: UILabel?,
                labelWidth: CGFloat?,
                textField: UITextField,
                value: String?,
                values: [FormValuePickerValue],
                validator: DataValidator<String>?,
                uiConfig: UIConfig)
    {
        self.values = values
        selectedValue = value
        valuePicker = UIPickerView()
        super.init(label: label, labelWidth: labelWidth, textField: textField, validator: validator, uiConfig: uiConfig)
        valuePicker.dataSource = self
        valuePicker.delegate = self
        textField.inputView = valuePicker
        if let validator = validator {
            _ = bndValue.observeNext { _ in
                let delayTime = DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
                    guard let wself = self else {
                        return
                    }
                    let validationResult = validator.validate(wself.selectedValue)
                    switch validationResult {
                    case .pass:
                        wself.valid.send(true)
                    case let .fail(reason):
                        wself.valid.send(false)
                        wself.validationMessage.send(reason)
                    }
                }
            }
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Binding Extensions

    private var _bndValue: Observable<String?>?
    override public var bndValue: Observable<String?> {
        if let bndValue = _bndValue {
            return bndValue
        } else {
            let bndValue = Observable<String?>(selectedValue)
            _ = bndValue.observeNext { [weak self] (value: String?) in
                self?.selectedValue = value
                if let selectedIndex = self?.values.firstIndex(where: { $0.id == value }) {
                    self?.valuePicker.selectRow(selectedIndex + 1, inComponent: 0, animated: false)
                }
                self?.validateText(self?.textValidator, text: self?.selectedValue)
            }
            _bndValue = bndValue
            return bndValue
        }
    }

    // MARK: - Private methods and attributes

    fileprivate let valuePicker: UIPickerView
}

extension FormRowValuePickerView: UIPickerViewDataSource {
    public func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return values.count + 1
    }
}

extension FormRowValuePickerView: UIPickerViewDelegate {
    public func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        if row == 0 {
            return ""
        } else {
            return values[row - 1].text
        }
    }

    public func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        guard row <= values.count else {
            return
        }
        var value: String?
        if row == 0 {
            bndValue.send(nil)
            textField.text = nil
        } else {
            bndValue.send(values[row - 1].id)
            textField.text = values[row - 1].text
            value = values[row - 1].id
        }
        validateText(textValidator, text: value)
    }
}
