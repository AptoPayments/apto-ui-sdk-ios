//
//  AddMoneyView.swift
//  Alamofire
//
//  Created by Fabio Cuomo on 26/1/21.
//

import UIKit
import SnapKit
import AptoSDK

public class AddMoneyView: UIView {
    let uiConfiguration: UIConfig
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = uiConfiguration.textMessageColor
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private lazy var headerTextView = HeaderTextView(uiconfig: self.uiConfiguration, text: "load_funds.selector_dialog.title")
    private lazy var item1ActionDetailView = DetailActionView(uiconfig: self.uiConfiguration,
                                                              textTitle: "load_funds.selector_dialog.card.title",
                                                              textSubTitle: "load_funds.selector_dialog.card.description")
    private lazy var item2ActionDetailView = DetailActionView(uiconfig: self.uiConfiguration,
                                                              textTitle: "load_funds.selector_dialog.direct_deposit.title",
                                                              textSubTitle: "load_funds.selector_dialog.direct_deposit.description")

    init(uiconfig: UIConfig) {
        self.uiConfiguration = uiconfig
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        backgroundColor = .clear
        isOpaque = false
        
        [headerTextView, item1ActionDetailView, item2ActionDetailView].forEach(containerView.addSubview)
        addSubview(containerView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomConstraint)
            make.height.equalTo(250)
        }
        headerTextView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(57)
        }
        item1ActionDetailView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerTextView.snp.bottom)
            make.height.equalTo(72)
        }
        item2ActionDetailView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(item1ActionDetailView.snp.bottom)
            make.height.equalTo(72)
        }
    }
}
