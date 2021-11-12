//
//  P2PTransferFundsView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 30/8/21.
//

import UIKit
import SnapKit
import AptoSDK

final class P2PTransferFundsView: UIView {
    let uiConfiguration: UIConfig
    private(set) lazy var amountTextField: UITextField = {
        let textField = ComponentCatalog.textFieldWith(placeholder: "$0",
                                                       placeholderColor: uiConfiguration.textSecondaryColor,
                                                       font: .boldSystemFont(ofSize: 44),
                                                       textColor: uiConfiguration.textPrimaryColor)
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        return textField
    }()
    private(set) var errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textAlignment = .center
        label.textColor = .red
        label.alpha = 0
        return label
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    private(set) lazy var currentCardView: CurrentCardView = {
        let view = CurrentCardView()
        view.alpha = 0
        return view
    }()

    private(set) lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(uiConfiguration.textButtonColor, for: .normal)
        button.setTitle("p2p_transfer.transfer_funds_view.action_button.title".podLocalized(), for: .normal)
        button.backgroundColor = uiConfiguration.uiPrimaryColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 24
        button.isHidden = true
        return button
    }()
    private var bottomStackViewConstraint: Constraint? = nil
    private var bottomAmountConstraint: Constraint? = nil
    
    init(uiconfig: UIConfig) {
        self.uiConfiguration = uiconfig
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK : Private methods
    func setupSubviews() {
        stackView.addArrangedSubview(currentCardView)
        stackView.addArrangedSubview(actionButton)

        [amountTextField, errorLabel, stackView].forEach(addSubview)
    }
    
    func setupConstraints() {
        amountTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(snpTopConstraint)
            self.bottomAmountConstraint = make.bottom.equalTo(bottomConstraint).constraint
        }
        errorLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.centerY.equalTo(amountTextField.snp.centerY).offset(40)
        }
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            self.bottomStackViewConstraint = make.bottom.equalTo(bottomConstraint).constraint
        }
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
    }

    // MARK: Public methods
    public func showActionButton(_ show: Bool) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.actionButton.isHidden = !show
        }
    }
    
    public func showError(message: String) {
        errorLabel.text = message
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.errorLabel.alpha = 1
        } completion: { [weak self] success in
            UIView.animate(withDuration: 0.1, delay: 2.0, options: .curveEaseInOut) {
                self?.errorLabel.alpha = 0
            } completion: { _ in }
        }
    }
    
    public func configure(with currentSelection: CurrentCardConfig) {
        currentCardView.configure(with: currentSelection)
        currentCardView.alpha = 1
    }
    
    public func updateViewContraints(to position: CGFloat) {
        bottomStackViewConstraint?.update(inset: position)
        bottomAmountConstraint?.update(inset: position)
    }
    
    public func showLimitError(_ limit: String, show: Bool) {
        if show {
            errorLabel.text = "p2p_transfer.transfer_funds.amount_exceeded.error.message".podLocalized().replace(["<<MAX>>" : limit])
            UIView.animate(withDuration: 0.3) { [errorLabel] in
                errorLabel.alpha = 1
            }
        } else {
            errorLabel.alpha = 0
        }
    }
}
