//
//  FormNumericSliderView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 31/01/16.
//
//

import AptoSDK
import Bond
import SnapKit
import UIKit

open class FormRowNumericSliderView: FormRowView, RangeSliderDelegate {
    // MARK: - Public attributes

    var numberValidator: DataValidator<Int>? {
        didSet {
            if !swipping {
                validateInt(numberValidator, number: value)
            } else {
                valid.send(false)
            }
        }
    }

    var value: Int? {
        didSet {
            if value == nil {
                value = 0
            }
            updateTextWith(value: value)
            if !swipping {
                validateInt(numberValidator, number: value)
            } else {
                valid.send(false)
            }
        }
    }

    var minStep: Int {
        didSet {
            slider.minStep = minStep
        }
    }

    var maximumValue: Int {
        get {
            return slider.maximumValue
        }
        set {
            slider.maximumValue = newValue - (newValue % minStep)
            value = min(value!, newValue - (newValue % minStep)) // swiftlint:disable:this force_unwrapping
        }
    }

    var setupComplete: Bool = false {
        didSet {
            slider.initialValueSetup = setupComplete
        }
    }

    var trackHighlightTintColor: UIColor {
        didSet {
            slider.trackHighlightTintColor = trackHighlightTintColor
        }
    }

    var trackTintColor: UIColor {
        didSet {
            slider.trackTintColor = trackTintColor
        }
    }

    init(valueLabel: UILabel,
         minimumValue: Int,
         maximumValue: Int,
         textPattern: String? = nil,
         validator: DataValidator<Int>? = nil,
         accessibilityLabel: String? = nil,
         uiConfig: UIConfig)
    {
        let slider = RangeSlider(frame: CGRect(x: 0, y: 0, width: 280, height: 30))
        slider.maximumValue = maximumValue
        slider.minimumValue = minimumValue
        self.slider = slider
        self.valueLabel = valueLabel
        self.textPattern = textPattern
        minStep = 0
        trackHighlightTintColor = uiConfig.uiPrimaryColor
        trackTintColor = uiConfig.formSliderTrackColor
        super.init(showSplitter: false)
        if let accessibilityLabel = accessibilityLabel {
            self.accessibilityLabel = accessibilityLabel
            isAccessibilityElement = true
        }
        setUpValueLabel(valueLabel: valueLabel)
        setUpSlider(slider: slider)
        value = 0

        numberValidator = validator
        validateInt(numberValidator, number: value)
    }

    private func setUpValueLabel(valueLabel: UILabel) {
        contentView.addSubview(valueLabel)
        self.valueLabel.snp.makeConstraints { make in
            make.left.right.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
        }
    }

    private func setUpSlider(slider: RangeSlider) {
        self.slider.trackHighlightTintColor = trackHighlightTintColor
        self.slider.trackTintColor = trackTintColor
        slider.delegate = self
        contentView.addSubview(self.slider)
        self.slider.snp.makeConstraints { make in
            make.left.right.equalTo(self.contentView)
            make.top.equalTo(self.valueLabel.snp.bottom).offset(16)
            make.height.equalTo(30)
            make.bottom.equalTo(self.contentView).offset(-15)
        }
        self.slider.updateLayerFrames()
        self.slider.addTarget(self, action: #selector(FormRowNumericSliderView.sliderChange), for: .valueChanged)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Binding Extensions

    private var _bndNumber: Observable<Int?>?
    public var bndNumber: Observable<Int?> {
        if let bndNumber = _bndNumber {
            return bndNumber
        } else {
            let bndNumber = Observable<Int?>(value)
            _ = bndNumber.observeNext { [weak self] (value: Int?) in
                self?.value = value
                guard let value = value else {
                    self?.slider.currentValue = 0
                    return
                }
                self?.slider.currentValue = value
            }
            _bndNumber = bndNumber
            return bndNumber
        }
    }

    @objc func sliderChange() {
        bndNumber.value = slider.currentValue
    }

    override open func updateConstraints() {
        super.updateConstraints()
        slider.updateLayerFrames()
    }

    // MARK: - Private methods and attributes

    fileprivate let slider: RangeSlider
    fileprivate let valueLabel: UILabel
    fileprivate let textPattern: String?

    fileprivate func updateTextWith(value: Int?) {
        guard let value = value else {
            valueLabel.text = ""
            return
        }
        guard let textPattern = textPattern else {
            valueLabel.text = String(Int(value))
            return
        }
        valueLabel.text = String(format: textPattern, arguments: [Int(value)])
    }

    // MARK: - RangeSliderDelegate

    private var swipping = false

    func didStartSwippingIn(rangeSlider _: RangeSlider) {
        valid.send(false)
        swipping = true
    }

    func didFinishSwippingIn(rangeSlider _: RangeSlider) {
        swipping = false
        validateInt(numberValidator, number: value)
    }
}

class MinValueDoubleValidator: DataValidator<Double> {
    init(minValue: Double, failReasonMessage: String) {
        super.init(failReasonMessage: failReasonMessage) { value -> ValidationResult in
            guard let value = value else {
                return .fail(reason: failReasonMessage)
            }
            if value > minValue {
                return .pass
            } else {
                return .fail(reason: failReasonMessage)
            }
        }
    }
}
