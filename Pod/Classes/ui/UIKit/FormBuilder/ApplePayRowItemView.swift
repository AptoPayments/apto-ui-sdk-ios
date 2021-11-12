//
//  ApplePayRowItemView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 13/4/21.
//

import UIKit
import SnapKit
import AptoSDK

final class ApplePayRowItemView: FormRowView {
    private(set) lazy var titleLabel = ComponentCatalog.mainItemLightLabelWith(text: title, uiConfig: uiconfig)
    private let appleMarkImageView = UIImageView(image: UIImage.imageFromPodBundle("apple_pay_mark"))
    private let cardAddedImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.imageFromPodBundle("payment_method_selected"))
        imageView.alpha = 0
        return imageView
    }()

    private let title: String
    private let uiconfig: UIConfig
    
    typealias ClickHandlerAction = (() -> Void)
    
    init(with title: String,
         uiconfig: UIConfig,
         clickHandler: ClickHandlerAction? = nil) {
        self.title = title
        self.uiconfig = uiconfig
        super.init(showSplitter: true, height: 72)
        setupViews()
        setupConstraints()
        setupBinding(handler: clickHandler)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        backgroundColor = uiconfig.uiSecondaryColor
        [titleLabel, appleMarkImageView, cardAddedImageView].forEach(addSubview)
    }
    
    private func setupConstraints() {
        appleMarkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(32)
            make.width.equalTo(50)
            make.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(appleMarkImageView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        
        cardAddedImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
    }
    
    private func setupBinding(handler: ClickHandlerAction?) {
        if let handler = handler {
            addTapGestureRecognizer(action: handler)
        }
    }
    
    public func showAddedCardIcon(show: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.cardAddedImageView.alpha = show ? 1 : 0
        }
    }
}
