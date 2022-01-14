//
//  PinEntryView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 29/09/2016.
//
//

import UIKit

@IBDesignable
class PinEntryView: UIView, UIKeyInput {
    let labelIdx = 1000
    let centerView = UIView()
    var completedBlock: ((_ value: String) -> Void)?

    var text: String {
        return (numberArray as NSArray).componentsJoined(by: "")
    }

    fileprivate var numberArray = [String]() {
        didSet {
            setNeedsDisplay()
            if let completion = completedBlock, numberArray.count == numberDigits, !numberArray.isEmpty {
                completion((self.numberArray as NSArray).componentsJoined(by: ""))
            }
        }
    }

    override public required init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.centerX.equalTo(self)
        }
        becomeFirstResponder()
        backgroundColor = UIColor.clear
        let show = UITapGestureRecognizer(target: self, action: #selector(PinEntryView.showKeyboard))
        addGestureRecognizer(show)
        setNeedsDisplay()
    }

    @objc func showKeyboard() {
        becomeFirstResponder()
    }

    @IBInspectable open var numberDigits: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var margin: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var borderWidth: Int = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var labelBorderColor = UIColor.darkGray {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var labelBackgroundColor = UIColor.clear {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var normalColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var setValueColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable open var errorColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override open func draw(_ rect: CGRect) {
        let width = rect.width
        let perLabWidth = (width - CGFloat((numberDigits + 1) * margin)) / CGFloat(numberDigits)
        for index in 0 ..< numberDigits {
            let currentIdx = labelIdx + index
            if let lab = viewWithTag(currentIdx) as? PinEntryLabel {
                setSecretLabel(lab, idx: index)
            } else {
                let label = PinEntryLabel()
                label.frame = CGRect(x: CGFloat(margin), y: CGFloat(margin), width: perLabWidth, height: perLabWidth)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.tag = labelIdx + index
                label.backgroundColor = labelBackgroundColor
                centerView.addSubview(label)
                setSecretLabel(label, idx: index)

                if index == 0 {
                    label.snp.makeConstraints { make in
                        make.left.equalTo(centerView).offset(margin)
                    }
                } else {
                    let previousview = viewWithTag(currentIdx - 1)! // swiftlint:disable:this force_unwrapping
                    label.snp.makeConstraints { make in
                        make.left.equalTo(previousview.snp.right).offset(margin)
                    }
                }

                label.snp.makeConstraints { make in
                    make.top.bottom.equalTo(self)
                    make.width.equalTo(label.snp.height)
                }

                if index == (numberDigits - 1) {
                    label.snp.makeConstraints { make in
                        make.right.equalTo(centerView).inset(margin)
                    }
                }
            }
        }
    }

    open func setSecretLabelError(_ completed: @escaping (() -> Void)) {
        let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.shakeWith(self.center)
            for index in 0 ..< self.numberDigits {
                let currentIdx = self.labelIdx + index
                if let lab = self.viewWithTag(currentIdx) as? PinEntryLabel {
                    self.setSecretLabel(lab, idx: -1)
                }
            }
            let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.numberArray.removeAll()
                completed()
            }
        }
    }

    func shakeWith(_ originPoint: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: originPoint.x - 5, y: originPoint.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: originPoint.x + 5, y: originPoint.y))
        layer.add(animation, forKey: "Position")
    }

    func setSecretLabel(_ label: PinEntryLabel, idx: Int) {
        let border = CGFloat(borderWidth)
        if numberArray.count <= idx || numberArray.isEmpty {
            label.setStatus(.none, color: normalColor, border: border, borderColor: labelBorderColor)
        } else if idx == -1 {
            label.setStatus(.error, color: errorColor, border: border, borderColor: labelBorderColor)
        } else {
            label.setStatus(.value, color: setValueColor, border: border, borderColor: labelBorderColor)
        }
    }

    override open var canBecomeFirstResponder: Bool {
        return true
    }

    public var hasText: Bool {
        return true
    }

    open func insertText(_ text: String) {
        if numberDigits > numberArray.count {
            numberArray.append(text)
            setNeedsDisplay()
        }
    }

    open func clearAllText() {
        numberArray.removeAll()
    }

    open func deleteBackward() {
        if !numberArray.isEmpty {
            numberArray.removeLast()
        }
        setNeedsDisplay()
    }

    open var keyboardType: UIKeyboardType {
        get { return .decimalPad }
        set { /* do nothing */ } // swiftlint:disable:this unused_setter_value
    }
}

enum PinEntryLabelStatus {
    case none
    case value
    case error
}

@IBDesignable
class PinEntryLabel: UIView {
    lazy var centerLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        self.layer.addSublayer(layer)
        return layer
    }()

    override func layoutSubviews() {
        centerLayer.frame = bounds
        var bound = bounds
        let minR = min(bound.width, bound.height) / 2
        bound.origin.x = (bound.width - minR * 2) / 2
        bound.origin.y = (bound.height - minR * 2) / 2
        bound.size.width = minR * 2
        bound.size.height = minR * 2
        let bezier = UIBezierPath(ovalIn: bound.insetBy(dx: minR * 0.7, dy: minR * 0.7))
        bezier.lineWidth = 1.0
        centerLayer.frame = bounds
        centerLayer.path = bezier.cgPath
    }

    func setStatus(_ status: PinEntryLabelStatus, color: UIColor, border: CGFloat, borderColor: UIColor) {
        layoutIfNeeded()
        centerLayer.transform = status == .none ? CATransform3DMakeScale(0.001, 0.001, 0) : CATransform3DMakeScale(1, 1, 0)
        setBorder(border, radius: 0.0, color: borderColor)
        centerLayer.fillColor = color.cgColor
    }

    func setBorder(_ width: CGFloat, radius: CGFloat, color: UIColor?) {
        layer.cornerRadius = radius
        layer.borderWidth = width
        if let borderColor = color {
            layer.borderColor = borderColor.cgColor
        }
    }
}
