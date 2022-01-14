//
// Toast.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/07/2019.
//
// Taken from SwiftToast pod and moved to the SDK as the pod is no longer maintained.
//

import UIKit

protocol ToastDelegate: AnyObject {
    func toastDidTouchUpInside(_ toast: ToastProtocol)
    func toast(_ toast: ToastProtocol, presentedWith height: CGFloat)
    func toastDismissed(_ toast: ToastProtocol)
}

// Make ToastDelegate as optional functions
extension ToastDelegate {
    func toastDidTouchUpInside(_: ToastProtocol) {}

    func toast(_: ToastProtocol, presentedWith _: CGFloat) {}

    func toastDismissed(_: ToastProtocol) {}
}

enum ToastStyle {
    case bottomToTop
}

protocol ToastProtocol {
    var duration: Double? { get set }
    var minimumHeight: CGFloat? { get set }
    var isUserInteractionEnabled: Bool { get set }
    var target: ToastDelegate? { get set }
    var style: ToastStyle { get set }
}

class Toast: ToastProtocol {
    var text: String
    var textAlignment: NSTextAlignment
    var backgroundColor: UIColor
    var textColor: UIColor
    var font: UIFont
    var duration: Double?
    var minimumHeight: CGFloat?
    var isUserInteractionEnabled: Bool
    var target: ToastDelegate?
    var style: ToastStyle

    static var defaultValue = Toast()

    init() {
        text = ""
        textAlignment = .center
        backgroundColor = .red
        textColor = .white
        font = .boldSystemFont(ofSize: 14.0)
        duration = 2.0
        minimumHeight = nil
        isUserInteractionEnabled = true
        target = nil
        style = .bottomToTop
    }

    init(text: String? = nil, textAlignment: NSTextAlignment? = nil, backgroundColor: UIColor? = nil,
         textColor: UIColor? = nil, font: UIFont? = nil, duration: Double? = 0.0, minimumHeight: CGFloat? = nil,
         isUserInteractionEnabled: Bool? = nil, target: ToastDelegate? = nil, style: ToastStyle? = nil)
    {
        self.text = text ?? Toast.defaultValue.text
        self.textAlignment = textAlignment ?? Toast.defaultValue.textAlignment
        self.backgroundColor = backgroundColor ?? Toast.defaultValue.backgroundColor
        self.textColor = textColor ?? Toast.defaultValue.textColor
        self.font = font ?? Toast.defaultValue.font
        self.duration = duration == 0 ? Toast.defaultValue.duration : duration
        self.minimumHeight = minimumHeight
        self.isUserInteractionEnabled = isUserInteractionEnabled ?? Toast.defaultValue.isUserInteractionEnabled
        self.target = target ?? Toast.defaultValue.target
        self.style = style ?? Toast.defaultValue.style
    }
}

class ToastController {
    // MARK: - Properties

    static var shared = ToastController()

    private var toastView: ToastViewProtocol?
    private var toastViewHeightConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var hideTimer = Timer()
    private var currentToast: ToastProtocol = Toast()
    private weak var delegate: ToastDelegate?

    private init() {
        setupToastView(ToastView())
    }

    // MARK: - Setup

    private func setupToastView(_ newToastView: ToastViewProtocol) {
        if let oldToastView = toastView as? UIView {
            oldToastView.removeFromSuperview()
        }
        toastView = newToastView.nib()

        guard let keyWindow = UIApplication.shared.keyWindow, let toastView = toastView as? UIView else { return }
        keyWindow.addSubview(toastView)

        // Set constraints
        toastView.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: toastView, attribute: .leading, relatedBy: .equal,
                                                   toItem: keyWindow, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: toastView, attribute: .trailing, relatedBy: .equal,
                                                    toItem: keyWindow, attribute: .trailing, multiplier: 1, constant: 0)

        switch currentToast.style {
        case .bottomToTop:
            toastViewHeightConstraint = NSLayoutConstraint(item: toastView, attribute: .height,
                                                           relatedBy: .greaterThanOrEqual, toItem: nil,
                                                           attribute: .notAnAttribute, multiplier: 1, constant: 64.0)
            topConstraint = NSLayoutConstraint(item: toastView, attribute: .bottom, relatedBy: .equal, toItem: keyWindow,
                                               attribute: .bottom, multiplier: 1, constant: toastView.frame.size.height)
        }
        // swiftlint:disable:next force_unwrapping
        keyWindow.addConstraints([topConstraint!, leadingConstraint, trailingConstraint, toastViewHeightConstraint!])
        UIApplication.shared.keyWindow?.layoutIfNeeded()

        // Add gesture
        if currentToast.isUserInteractionEnabled {
            toastView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(toastViewButtonTouchUpInside(_:))))
        }
    }

    // MARK: - Actions

    @objc private func toastViewButtonTouchUpInside(_: UIGestureRecognizer) {
        dismiss(true, completion: nil)
        delegate?.toastDidTouchUpInside(currentToast)
    }

    // MARK: - Customizations

    func configureConstraint(for presentingToast: Bool) {
        guard let toastView = toastView as? UIView else { return }
        topConstraint?.constant = presentingToast ? 0 : toastView.frame.size.height
        UIApplication.shared.keyWindow?.layoutIfNeeded()
    }

    // MARK: - Public functions

    func present(_ toast: ToastProtocol, toastView: ToastViewProtocol, animated: Bool) {
        dismiss(animated) {
            // after dismiss if needed, setup toast
            self.currentToast = toast
            self.setupToastView(toastView)
            self.delegate = toast.target
            self.toastView?.configure(with: toast)
            UIApplication.shared.keyWindow?.layoutIfNeeded()
            // present
            UIView.animate(withDuration: animated ? 0.3 : 0.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.configureConstraint(for: true)
                if let toastView = self.toastView as? UIView {
                    self.delegate?.toast(self.currentToast, presentedWith: toastView.frame.size.height)
                }
            }, completion: { (_ finished) in
                if finished, let duration = toast.duration {
                    self.hideTimer = Timer.scheduledTimer(timeInterval: duration, target: self,
                                                          selector: #selector(self.hideTimerSelector(_:)), userInfo: animated,
                                                          repeats: false)
                }
            })
        }
    }

    // MARK: - Animations

    @objc func hideTimerSelector(_ timer: Timer) {
        let animated = (timer.userInfo as? Bool) ?? false
        dismiss(animated, completion: nil)
    }

    func dismiss(_ animated: Bool, completion: (() -> Void)? = nil) {
        guard toastView is UIView else {
            completion?()
            return
        }

        hideTimer.invalidate()

        UIView.animate(withDuration: animated ? 0.3 : 0.0, delay: 0, options: .curveEaseOut, animations: {
            self.configureConstraint(for: false)
            self.delegate?.toastDismissed(self.currentToast)
        }, completion: { (_ finished) in
            if finished {
                completion?()
            }
        })
    }
}
