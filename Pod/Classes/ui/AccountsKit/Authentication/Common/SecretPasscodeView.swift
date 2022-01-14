//
//  SecretPasscodeView.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 21/11/2019.
//

import AptoSDK
import SnapKit
import UIKit

protocol SecretPasscodeViewDelegate: AnyObject {
    func secretPasscodeView(_ secretPasscodeView: SecretPasscodeView, didEnterPIN pin: String)
}

class SecretPasscodeView: UIView {
    private let codeLength: Int
    private let uiConfig: UIConfig
    private let bottomLeftContainerView = UIView()
    private var code: String = "" {
        didSet {
            updateDots()
        }
    }

    private var dots = [UIView]()

    weak var delegate: SecretPasscodeViewDelegate?
    private var _bottomLeftView: UIView?
    var bottomLeftView: UIView? {
        get {
            return _bottomLeftView
        }
        set {
            _bottomLeftView?.removeFromSuperview()
            _bottomLeftView = newValue
            setUpBottomLeftView()
        }
    }

    init(codeLength: Int = 4, uiConfig: UIConfig) {
        self.codeLength = codeLength
        self.uiConfig = uiConfig
        super.init(frame: .zero)
        setUpUI()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resetCode() {
        code = ""
    }

    private func digitButtonTapped(_ sender: UIButton) {
        guard code.count < codeLength else { return }
        if let title = sender.title(for: .normal) {
            code.append(title)
            if code.count == codeLength {
                delegate?.secretPasscodeView(self, didEnterPIN: code)
            }
        }
    }

    private func backspaceTapped() {
        code = String(code.dropLast())
    }

    private func updateDots() {
        for (index, dot) in dots.enumerated() {
            let color = index >= code.count ? uiConfig.iconPrimaryColor : uiConfig.uiPrimaryColor
            if dot.backgroundColor != color {
                // swiftlint:disable trailing_closure
                UIView.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                    dot.backgroundColor = color
                })
                // swiftlint:enable trailing_closure
            }
        }
    }
}

// MARK: - Set up UI

private extension SecretPasscodeView {
    func setUpUI() {
        backgroundColor = uiConfig.uiBackgroundPrimaryColor
        let keyboardView = createKeyBoard()
        createDots(keyboardView)
    }

    func createKeyBoard() -> UIView {
        return createRow(digits: ["1", "2", "3"],
                         createRow(digits: ["4", "5", "6"],
                                   createRow(digits: ["7", "8", "9"],
                                             createBottomRow())))
    }

    func createRow(digits: [String], _ bottomView: UIView) -> UIView {
        let container = UIView()
        addSubview(container)
        container.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(bottomView.snp.top).offset(-24)
        }
        let leftButton = createButton(digit: Character(digits[0]))
        container.addSubview(leftButton)
        leftButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
        }
        let middleButton = createButton(digit: Character(digits[1]))
        container.addSubview(middleButton)
        middleButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        let rightButton = createButton(digit: Character(digits[2]))
        container.addSubview(rightButton)
        rightButton.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
        }
        return container
    }

    func createBottomRow() -> UIView {
        let container = UIView()
        addSubview(container)
        container.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(48)
        }
        let button = createButton(digit: "0")
        container.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        let backspaceButton = createBackspaceButton()
        container.addSubview(backspaceButton)
        backspaceButton.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
        }
        container.addSubview(bottomLeftContainerView)
        bottomLeftContainerView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
        }
        return container
    }

    func createButton(digit: Character) -> UIButton {
        let button = UIButton()
        button.setTitle(String(digit), for: .normal)
        button.setTitleColor(uiConfig.textSecondaryColor, for: .normal)
        button.setTitleColor(uiConfig.textSecondaryColor.withAlphaComponent(0.2), for: .highlighted)
        button.titleLabel?.font = uiConfig.fontProvider.keyboardFont
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTapGestureRecognizer { [unowned self] in
            self.digitButtonTapped(button)
        }
        return button
    }

    func createBackspaceButton() -> UIButton {
        let image = UIImage.imageFromPodBundle("top_back_default")?.asTemplate()
        let button = UIButton()
        button.tintColor = uiConfig.textSecondaryColor
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.adjustsImageWhenHighlighted = true
        button.addTapGestureRecognizer { [unowned self] in
            self.backspaceTapped()
        }
        return button
    }

    func createDots(_ bottomView: UIView) {
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll(keepingCapacity: true)
        let dotHeight = 32
        let container = UIView()
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(dotHeight * codeLength)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top).offset(-24)
        }
        for index in 0 ..< codeLength {
            let dotContainer = UIView()
            container.addSubview(dotContainer)
            dotContainer.snp.makeConstraints { make in
                make.width.height.equalTo(dotHeight)
                make.centerY.equalToSuperview()
                make.left.equalTo(index * dotHeight + 1)
            }
            let dot = createDot()
            dotContainer.addSubview(dot)
            dot.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            dots.append(dot)
        }
        updateDots()
    }

    func createDot() -> UIView {
        let size: CGFloat = 8
        let dot = UIView()
        dot.backgroundColor = uiConfig.iconPrimaryColor
        dot.layer.cornerRadius = size / 2
        dot.snp.makeConstraints { make in
            make.height.width.equalTo(size)
        }
        return dot
    }

    func setUpBottomLeftView() {
        guard let view = _bottomLeftView else { return }
        bottomLeftContainerView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
