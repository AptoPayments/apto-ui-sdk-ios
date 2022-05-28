//
// ToastView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/07/2019.
//
// Taken from SwiftToast pod and moved to the SDK as the pod is no longer maintained.
//

import SnapKit
import UIKit

protocol ToastViewProtocol: AnyObject {
    func nib() -> ToastViewProtocol?
    func configure(with toast: ToastProtocol)
}

class ToastView: UIView, ToastViewProtocol {
    // MARK: - Outlets

    private var messageLabel = UILabel()

    // MARK: - Initializers

    func nib() -> ToastViewProtocol? {
        setUpUI()
        return self
    }

    // MARK: - Configure

    func configure(with toast: ToastProtocol) {
        guard let toast = toast as? Toast else { return }
        messageLabel.text = toast.text
        messageLabel.textAlignment = toast.textAlignment
        messageLabel.textColor = toast.textColor
        messageLabel.font = toast.font
        messageLabel.numberOfLines = 0
        backgroundColor = toast.backgroundColor
        isUserInteractionEnabled = toast.isUserInteractionEnabled
    }

    // MARK: - Set Up UI

    private func setUpUI() {
        setUpMessageLabel()
    }

    private func setUpMessageLabel() {
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(52)
        }
    }
}

extension UIViewController {
    func present(_ toast: ToastProtocol, animated: Bool) {
        DispatchQueue.main.async {
            ToastController.shared.present(toast, toastView: ToastView(), animated: animated)
        }
    }

    func present(_ toast: ToastProtocol, withCustomToastView customToastView: ToastViewProtocol, animated: Bool) {
        DispatchQueue.main.async {
            ToastController.shared.present(toast, toastView: customToastView, animated: animated)
        }
    }

    func dismissToast(_ animated: Bool) {
        DispatchQueue.main.async {
            ToastController.shared.dismiss(animated)
        }
    }
}
