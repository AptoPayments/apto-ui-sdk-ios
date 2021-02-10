//
//  DirectDepositView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 27/1/21.
//

import UIKit
import SnapKit
import AptoSDK

public class DirectDepositView: UIView {
    let uiConfiguration: UIConfig
    private let containerView = UIView()
    private lazy var descriptionLabel: UILabel = {
        let label = ComponentCatalog.formListLabelWith(text: "",
                                                       textAlignment: .left,
                                                       uiConfig: uiConfiguration)
        label.textColor = uiConfiguration.iconPrimaryColor
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var bankAccountInfoView = ShowInfoView(uiconfig: uiConfiguration)
    private(set) lazy var accountNumberInfoView = ShowInfoView(uiconfig: uiConfiguration)
    private(set) lazy var routingNumberInfoView = ShowInfoView(uiconfig: uiConfiguration)

    private lazy var footerLabel: UILabel = {
        let label = ComponentCatalog.footerDescriptionLabelWith(text: "",
                                                                textAlignment: .left,
                                                                uiConfig: uiConfiguration)
        label.numberOfLines = 0
        return label
    }()
    let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    init(uiconfig: UIConfig) {
        self.uiConfiguration = uiconfig
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Private Methods
    private func setupViews() {
        backgroundColor = uiConfiguration.textMessageColor
        isOpaque = false
        
        [descriptionLabel, bankAccountInfoView, accountNumberInfoView, routingNumberInfoView, footerLabel, activityIndicator].forEach(containerView.addSubview)
        [containerView, activityIndicator].forEach(addSubview)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(24)
        }
        bankAccountInfoView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.height.equalTo(55)
        }
        accountNumberInfoView.snp.makeConstraints { make in
            make.top.equalTo(bankAccountInfoView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(55)
        }
        routingNumberInfoView.snp.makeConstraints { make in
            make.top.equalTo(accountNumberInfoView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(55)
        }
        footerLabel.snp.makeConstraints { make in
            make.top.equalTo(routingNumberInfoView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: Public Methods
    public func configure(with viewData: DirectDepositViewData) {
        bankAccountInfoView.configure(with: "load_funds.direct_deposit.bank_name.title".podLocalized(), valueText: "load_funds.direct_deposit.bank_name.description".podLocalized())
        accountNumberInfoView.configure(with: "load_funds.direct_deposit.ach_number.title".podLocalized(), valueText: viewData.accountDetails.accountNumber ?? "")
        routingNumberInfoView.configure(with: "load_funds.direct_deposit.routing_number.title".podLocalized(), valueText: viewData.accountDetails.routingNumber ?? "")
        descriptionLabel.text = viewData.description
        footerLabel.text = viewData.footer
    }

}

