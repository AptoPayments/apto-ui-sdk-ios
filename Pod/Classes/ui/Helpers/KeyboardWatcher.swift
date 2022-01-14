import Foundation

typealias OnKeyboardShown = (CGRect) -> Void
typealias OnKeyboardHide = () -> Void

final class KeyboardWatcher {
    private var onKeyboardShown: OnKeyboardShown?
    private var onKeyboardHide: OnKeyboardHide?

    private let notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    func startWatching(onKeyboardShown: OnKeyboardShown? = nil, onKeyboardHide: OnKeyboardHide? = nil) {
        self.onKeyboardShown = onKeyboardShown
        self.onKeyboardHide = onKeyboardHide

        notificationCenter.addObserver(self,
                                       selector: #selector(onKeyboardWillShow(_:)),
                                       name: UIResponder.keyboardWillShowNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(onKeyboardWillHide(_:)),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
    }

    @objc private func onKeyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification
            .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        onKeyboardShown?(keyboardSize)
    }

    @objc private func onKeyboardWillHide(_: Notification) {
        onKeyboardHide?()
    }
}
