//
//  GenericResultScreenView.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 4/8/21.
//

import AptoSDK
import SnapKit
import UIKit

public enum ResultType {
    case success
    case failure
}

public struct BottomItemModel {
    let info: String
    let value: String
}

final class GenericResultScreenView: UIView {
    let uiConfiguration: UIConfig

    private let resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private(set) lazy var headerTextView: UILabel = {
        let label = UILabel()
        label.font = uiConfiguration.fontProvider.topBarTitleBigFont
        label.textColor = uiConfiguration.textPrimaryColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private(set) lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(uiConfiguration.textButtonColor, for: .normal)
        button.setTitle("input-field.button.done".podLocalized(), for: .normal)
        button.backgroundColor = uiConfiguration.uiPrimaryColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 24
        return button
    }()

    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.isHidden = true
        return stackView
    }()

    private let bottomViewItemCount: Int

    init(uiconfig: UIConfig, bottomViewItemCount: Int = 0) {
        uiConfiguration = uiconfig
        self.bottomViewItemCount = bottomViewItemCount
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = uiConfiguration.uiSecondaryColor
        for _ in 0 ..< bottomViewItemCount {
            let item = ShowInfoView(uiconfig: uiConfiguration)
            bottomStackView.addArrangedSubview(item)
            item.snp.makeConstraints { make in
                make.height.equalTo(55)
            }
        }
        [resultImageView, headerTextView, doneButton, bottomStackView].forEach(addSubview)
    }

    private func setupConstraints() {
        resultImageView.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(124)
        }

        headerTextView.snp.makeConstraints { make in
            make.top.equalTo(resultImageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }

        bottomStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(doneButton.snp.top).offset(-20)
        }

        doneButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(bottomConstraint).inset(34)
            make.height.equalTo(48)
        }
    }

    // MARK: Public method

    public func configure(for result: ResultType, text: String) {
        switch result {
        case .success:
            resultImageView.image = UIImage.imageFromPodBundle("transaction_ok_icon")
        case .failure:
            resultImageView.image = UIImage.imageFromPodBundle("transaction_ko_icon")
        }
        headerTextView.text = text
    }

    public func configureBottomItems(with infoItems: [BottomItemModel]) {
        bottomStackView.isHidden = infoItems.isEmpty
        for (index, view) in bottomStackView.arrangedSubviews.enumerated() {
            if let infoView = view as? ShowInfoView {
                infoView.configure(with: infoItems[index].info, valueText: infoItems[index].value)
            }
        }
    }
}
