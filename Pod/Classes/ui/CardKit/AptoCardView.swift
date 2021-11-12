//
//  AptoCardView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 30/3/21.
//

import AptoSDK

public final class AptoCardView: UIView {
    private(set) var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private(set) var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private(set) var networkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .bottomRight
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: Private methods
    private func setupSubviews() {
        [backgroundImageView, logoImageView, networkImageView].forEach(addSubview)
        backgroundColor = .clear
        layer.cornerRadius = 10
        clipsToBounds = true
    }

    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        networkImageView.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(40)
            make.right.equalTo(backgroundImageView).inset(20)
            make.bottom.equalTo(backgroundImageView).inset(16)
        }

        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(51)
            make.height.equalTo(40)
            make.right.equalTo(backgroundImageView).inset(24.5)
            make.top.equalTo(backgroundImageView).inset(16)
        }
    }
    
    private func setCardBackground(_ cardStyle: CardStyle?, _ cardNetwork: CardNetwork?) {
        guard let cardStyle = cardStyle else { return }
        switch cardStyle.background {
        case .color(let color):
            backgroundImageView.image = nil
            backgroundImageView.backgroundColor = color
            setNetworkImage(cardStyle, cardNetwork)
        case .image(let url):
            backgroundImageView.setImageUrl(url)
        }
    }
    
    private func setNetworkImage(_ cardStyle: CardStyle?, _ cardNetwork: CardNetwork?) {
        guard let cardStyle = cardStyle else { return }
        if let logo = getLogoForNetwork(cardNetwork) {
            networkImageView.image = logo
            if let rawColor = cardStyle.textColor,
               let color = UIColor.colorFromHexString(rawColor) {
                networkImageView.tintColor = color
            }
        }
    }

    private func setCompanyLogo(_ cardStyle: CardStyle?) {
        guard let cardStyle = cardStyle,
              let logo = cardStyle.cardLogo else { return }
        logoImageView.setImageUrl(logo)
    }

    private func getLogoForNetwork(_ cardNetwork: CardNetwork?) -> UIImage? {
        guard let network = cardNetwork else { return nil }
        switch network {
        case .visa:
            return UIImage.imageFromPodBundle("card_network_visa")?.asTemplate()
        case .mastercard:
            return UIImage.imageFromPodBundle("card_network_mastercard")?.asTemplate()
        case .amex:
            return UIImage.imageFromPodBundle("card_logo_amex")
        case .discover,
             .other:
            return nil
        }
    }

    // MARK: Public methods
    public func configure(with cardStyle: CardStyle?, cardNetwork: CardNetwork?) {
        setCardBackground(cardStyle, cardNetwork)
        setCompanyLogo(cardStyle)
    }
}
