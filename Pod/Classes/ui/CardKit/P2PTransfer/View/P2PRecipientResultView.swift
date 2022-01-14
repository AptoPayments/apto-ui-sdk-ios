//
//  P2PRecipientResultView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 28/7/21.
//

import AptoSDK
import Foundation

final class P2PRecipientResultView: UIView {
    let uiConfiguration: UIConfig

    private let containerView = UIView()
    private(set) lazy var recipientLabel: UILabel = {
        let label = UILabel()
        label.font = uiConfiguration.fontProvider.instructionsFont
        label.textColor = uiConfiguration.textTertiaryColor
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var contactLabel: UILabel = {
        let label = UILabel()
        label.font = uiConfiguration.fontProvider.subCurrencyFont
        label.textColor = uiConfiguration.textTopBarSecondaryColor
        label.numberOfLines = 0
        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.imageFromPodBundle("payment_method_selected")
        return imageView
    }()

    private(set) lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.font = uiConfiguration.fontProvider.instructionsFont
        label.textColor = uiConfiguration.textTertiaryColor
        label.text = "p2p_transfer.recipient_result_view.recipient_not_found.description".podLocalized()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    init(uiconfig: UIConfig) {
        uiConfiguration = uiconfig
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
        [recipientLabel, contactLabel, iconImageView].forEach(containerView.addSubview)
        [containerView, emptyLabel].forEach(addSubview)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        recipientLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
        }

        contactLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(recipientLabel.snp.bottom).offset(5)
        }

        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(35)
            make.width.height.equalTo(24)
        }

        emptyLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }

    // MARK: Public methods

    public func configureRecipient(with recipient: CardholderData, contact: String) {
        if let firstName = recipient.firstName,
           let lastName = recipient.lastName
        {
            recipientLabel.text = firstName + " " + lastName
        }
        contactLabel.text = contact
        containerView.alpha = 1
        emptyLabel.alpha = 0
    }

    public func showNoResults(with description: String) {
        emptyLabel.text = description
        containerView.alpha = 0
        emptyLabel.alpha = 1
    }
}
