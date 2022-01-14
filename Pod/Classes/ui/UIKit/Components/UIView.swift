//
//  UIView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/02/16.
//
//

import AptoSDK
import Foundation

extension UIView {
    func fadeIn(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: animations,
                          completion: completion)
    }

    func animate(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .beginFromCurrentState,
                       animations: animations,
                       completion: completion)
    }

    func shake(translation: CGFloat = 20, completion: ((Bool) -> Void)? = nil) {
        let halfTranslation = translation / 2
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [
            0, translation, -translation, translation,
            -halfTranslation, halfTranslation, -halfTranslation, 0,
        ]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
        animation.duration = 0.35
        animation.isAdditive = true

        layer.add(animation, forKey: "shake")
        completion?(true)
    }

    func translate(x: CGFloat, completion: (() -> Void)? = nil) { // swiftlint:disable:this identifier_name
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [x, 0]
        animation.duration = 0.35
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.isAdditive = true

        layer.add(animation, forKey: "move")
        completion?()
    }

    func show(message: String,
              title: String,
              animated: Bool = true,
              isError: Bool,
              uiConfig: UIConfig,
              tapHandler: (() -> Void)?)
    {
        let topViewController = UIApplication.topViewController()
        guard parentViewController === topViewController else { return }
        topViewController?.show(message: message, title: title, animated: animated, isError: isError, uiConfig: uiConfig,
                                tapHandler: tapHandler)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            topViewController?.view.endEditing(true)
        }
    }

    func hideMessage(animated: Bool = true) {
        UIApplication.topViewController()?.dismissToast(animated)
    }

    private var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// Gesture Recognizers

extension UIView {
    func clearGestureRecognizers() {
        gestureRecognizers?.forEach { gestureRecognizer in
            removeGestureRecognizer(gestureRecognizer)
        }
    }
}

// UITapGestureRecognizers as blocks (not selectors)

extension UIView {
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate enum AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }

    fileprivate typealias Action = (() -> Void)?

    // Set our computed property type to a closure
    private var tapGestureRecognizerAction: Action? {
        get {
            let tapGestureRecognizerActionInstance
                = objc_getAssociatedObject(self,
                                           &AssociatedObjectKeys.tapGestureRecognizer)
            return tapGestureRecognizerActionInstance as? Action
        }
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self,
                                         &AssociatedObjectKeys.tapGestureRecognizer,
                                         newValue,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
    }

    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(_ numberOfTapsRequired: Int = 1, action: (() -> Void)? = nil) {
        isUserInteractionEnabled = true
        tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGestureRecognizer.numberOfTapsRequired = numberOfTapsRequired
        addGestureRecognizer(tapGestureRecognizer)
    }

    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc private func handleTapGesture(sender _: UITapGestureRecognizer) {
        if let action = tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
}

extension UIView {
    func addParallax(amount: Int) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        addMotionEffect(group)
    }
}

extension UIView {
    func applyHoleSquaredMask(holeRect: CGRect, cornerRadius: CGFloat, backgroundColor: UIColor, alpha: Float) {
        if let sublayers = layer.sublayers {
            for item in (sublayers.filter { $0.name == "shiftHoleMask" }) {
                item.removeFromSuperlayer()
                item.removeAllAnimations()
            }
        }
        let path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                    y: 0,
                                                    width: bounds.size.width,
                                                    height: bounds.size.height),
                                cornerRadius: 0)
        let hole = UIBezierPath(roundedRect: holeRect, cornerRadius: cornerRadius)
        path.append(hole)
        path.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = backgroundColor.cgColor
        fillLayer.opacity = alpha
        layer.insertSublayer(fillLayer, at: 1)
        fillLayer.name = "shiftHoleMask"
    }

    func applyHoleOvalMask(holeRect: CGRect, backgroundColor: UIColor, alpha: Float) {
        if let sublayers = layer.sublayers {
            for item in (sublayers.filter { $0.name == "shiftHoleMask" }) {
                item.removeFromSuperlayer()
                item.removeAllAnimations()
            }
        }
        let path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                    y: 0,
                                                    width: bounds.size.width,
                                                    height: bounds.size.height),
                                cornerRadius: 0)
        let hole = UIBezierPath(ovalIn: holeRect)
        path.append(hole)
        path.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = backgroundColor.cgColor
        fillLayer.opacity = alpha
        layer.insertSublayer(fillLayer, at: 1)
        fillLayer.name = "shiftHoleMask"
    }
}
