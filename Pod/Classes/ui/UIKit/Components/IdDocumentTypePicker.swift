//
//  IdDocumentTypePicker.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 09/10/2018.
//

import AptoSDK
import Bond
import ReactiveKit

class IdDocumentTypePicker: UIView {
    private let disposeBag = DisposeBag()
    let picker: UIPickerView
    var allowedDocumentTypes: [IdDocumentType] {
        didSet {
            picker.selectRow(0, inComponent: 0, animated: false)
            picker.reloadAllComponents()
            pickerView(picker, didSelectRow: 0, inComponent: 0)
        }
    }

    private var selectedType: IdDocumentType
    private let uiConfig: UIConfig

    init(allowedDocumentTypes: [IdDocumentType],
         selectedType: IdDocumentType? = nil,
         uiConfig: UIConfig)
    {
        guard let firstType = allowedDocumentTypes.first else {
            fatalError("At least one country is required")
        }
        self.uiConfig = uiConfig
        self.allowedDocumentTypes = allowedDocumentTypes
        picker = UIPickerView()
        self.selectedType = selectedType ?? firstType
        super.init(frame: .zero)

        setUpUI()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var _bndValue: Observable<IdDocumentType>?
    var bndValue: Observable<IdDocumentType> {
        if let bndValue = _bndValue {
            return bndValue
        } else {
            let bndValue = Observable<IdDocumentType>(selectedType)
            bndValue.observeNext { [weak self] (selectedType: IdDocumentType) in
                guard let self = self else { return }
                self.selectedType = selectedType
                if let selectedIndex = self.allowedDocumentTypes.firstIndex(where: { $0 == selectedType }) {
                    self.picker.selectRow(selectedIndex, inComponent: 0, animated: false)
                }
            }.dispose(in: disposeBag)
            _bndValue = bndValue
            return bndValue
        }
    }

    override var intrinsicContentSize: CGSize {
        return picker.intrinsicContentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        picker.frame = bounds
    }
}

private extension IdDocumentTypePicker {
    func setUpUI() {
        // This is required for the view to get sized to the iOS keyboard size
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(picker)
        picker.dataSource = self
        picker.delegate = self
    }
}

extension IdDocumentTypePicker: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return allowedDocumentTypes.count
    }
}

extension IdDocumentTypePicker: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView,
                           viewForRow row: Int,
                           forComponent _: Int,
                           reusing view: UIView?) -> UIView
    {
        let label: UILabel
        if let reusing = view as? UILabel {
            label = reusing
        } else {
            let horizontalMargin: CGFloat = 32
            label = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width - 2 * horizontalMargin, height: 36))
        }
        label.textColor = uiConfig.textPrimaryColor
        label.font = uiConfig.fontProvider.formLabelFont
        label.text = allowedDocumentTypes[row].localizedDescription
        return label
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        bndValue.send(allowedDocumentTypes[row])
    }
}
