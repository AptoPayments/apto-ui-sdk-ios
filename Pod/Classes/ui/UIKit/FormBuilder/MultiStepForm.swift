//
//  MultiStepForm.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 30/01/16.
//
//

import AptoSDK
import SnapKit

enum MultiStepFormAnimation {
    case none
    case crossDissolve
    case pop
    case push
}

open class MultiStepForm: UIScrollView, ReturnButtonListenerProtocol, RowFocusListenerProtocol {
    override init(frame: CGRect) {
        contentView = UIView()
        super.init(frame: frame)
        addSubview(contentView)
        registerToKeyboardNotifications()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.unregisterFromKeyboardNotifications()
    }

    @discardableResult override open func resignFirstResponder() -> Bool {
        guard let focusedRow = focusedRow else {
            return true
        }
        return focusedRow.resignFirstResponder()
    }

    // MARK: - Public methods

    open func show(rows: [FormRowView]) {
        show(rows: rows, withAnimation: .none)
    }

    func show(rows: [FormRowView], withAnimation animation: MultiStepFormAnimation) {
        adjustWidthIfNecessary()

        for row in self.rows {
            animateRowExiting(row, animation: animation)
        }
        self.rows = rows

        var prevRow: UIView?
        for row in self.rows {
            row.returnButtonListener = self
            row.rowFocusListener = self
            animateRowEntering(row, prevRow: prevRow, animation: animation)
            prevRow = row
        }

        // Last row bottom constraint
        prevRow?.snp.makeConstraints { make in
            make.bottom.equalTo(self.contentView)
        }
    }

    @discardableResult override open func becomeFirstResponder() -> Bool {
        for row in rows {
            if row.becomeFirstResponder() {
                row.focus()
                return true
            }
        }

        return false
    }

    // MARK: - ReturnButtonListenerProtocol

    func focusNextRowfrom(row: FormRowView) -> Bool {
        if let nextRow = nextRowForRow(row) {
            nextRow.becomeFirstResponder()
        } else if rows.count == 1 {
            return true
        }
        return false
    }

    func focusPreviousRowfrom(row: FormRowView) -> Bool {
        if let nextRow = previousRowForRow(row) {
            nextRow.becomeFirstResponder()
        }
        return false
    }

    // MARK: - RowFocusListenerProtocol

    var focusedRow: FormRowView?

    func rowDidBeginEditing(_ row: FormRowView) {
        focusedRow = row
    }

    func rowDidEndEditing(_: FormRowView) {
        focusedRow = nil
    }

    // MARK: - Private Attributes

    let contentView: UIView
    var rows: [FormRowView] = []
    var adjustedWidth = false

    // MARK: - Private Methods

    private func animateRowEntering(_ row: UIView, prevRow: UIView?, animation: MultiStepFormAnimation) {
        let topConstraint: ConstraintItem
        if let prevRow = prevRow {
            topConstraint = prevRow.snp.bottom
        } else {
            topConstraint = contentView.snp.top
        }
        switch animation {
        case .none:
            contentView.addSubview(row)
            row.snp.makeConstraints { make in
                make.left.right.equalTo(self.contentView)
                make.top.equalTo(topConstraint)
            }
        case .crossDissolve:
            fadeIn(animations: {
                self.contentView.addSubview(row)
                row.snp.makeConstraints { make in
                    make.left.right.equalTo(self.contentView)
                    make.top.equalTo(topConstraint)
                }
            })
        case .pop:
            contentView.translate(x: -bounds.width) {
                self.contentView.addSubview(row)
                row.snp.makeConstraints { make in
                    make.left.right.equalTo(self.contentView)
                    make.top.equalTo(topConstraint)
                }
            }
        case .push:
            contentView.translate(x: bounds.width) {
                self.contentView.addSubview(row)
                row.snp.makeConstraints { make in
                    make.left.right.equalTo(self.contentView)
                    make.top.equalTo(topConstraint)
                }
            }
        }
    }

    private func animateRowExiting(_ row: UIView, animation: MultiStepFormAnimation) {
        switch animation {
        case .none:
            row.removeFromSuperview()
        case .crossDissolve:
            fadeIn(animations: {
                row.removeFromSuperview()
            })
        case .pop:
            contentView.translate(x: bounds.width) {
                row.removeFromSuperview()
            }
        case .push:
            contentView.translate(x: -bounds.width) {
                row.removeFromSuperview()
            }
        }
    }

    func nextRowForRow(_ row: FormRowView) -> FormRowView? {
        let allRows = rows
        guard let index = allRows.firstIndex(of: row) else { return nil }
        guard index < allRows.count - 1 else { return nil }
        return allRows[index + 1]
    }

    private func previousRowForRow(_ row: FormRowView) -> FormRowView? {
        let allRows = rows
        guard let index = allRows.firstIndex(of: row) else { return nil }
        guard index > 0 else { return nil }
        return allRows[index - 1]
    }

    private func adjustWidthIfNecessary() {
        guard adjustedWidth == false,
              let superview = superview
        else {
            return
        }
        contentView.snp.makeConstraints { make in
            make.left.top.right.bottom.equalTo(self)
            make.width.equalTo(superview.snp.width)
        }
        adjustedWidth = true
    }
}

extension MultiStepForm {
    private var notificationHandler: NotificationHandler {
        return ServiceLocator.shared.notificationHandler
    }

    private func registerToKeyboardNotifications() {
        notificationHandler.addObserver(self, selector: #selector(MultiStepForm.keyboardDidShow(_:)),
                                        name: UIResponder.keyboardDidShowNotification)
        notificationHandler.addObserver(self, selector: #selector(MultiStepForm.keyboardWillBeHidden(_:)),
                                        name: UIResponder.keyboardWillHideNotification)
    }

    private func unregisterFromKeyboardNotifications() {
        notificationHandler.removeObserver(self, name: UIResponder.keyboardDidShowNotification)
        notificationHandler.removeObserver(self, name: UIResponder.keyboardWillHideNotification)
    }

    @objc public func keyboardDidShow(_ notification: Notification) {
        if let focusedRow = focusedRow,
           let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        {
            let contentInsets = UIEdgeInsets(top: contentInset.top, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            contentInset = contentInsets
            scrollIndicatorInsets = contentInsets
            var aRect = frame
            aRect.size.height -= keyboardSize.size.height
            if !aRect.contains(focusedRow.frame.origin) {
                scrollRectToVisible(focusedRow.frame, animated: true)
            }
        }
    }

    @objc public func keyboardWillBeHidden(_: Notification) {
        let contentInsets = UIEdgeInsets(top: contentInset.top, left: 0.0, bottom: 0, right: 0.0)
        contentInset = contentInsets
        scrollIndicatorInsets = contentInsets
    }
}
