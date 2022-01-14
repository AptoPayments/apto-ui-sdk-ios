//
// TransactionListCellTheme2.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 2018-12-14.
//

import AptoSDK
import SnapKit
import UIKit

class TransactionListCellTheme2: UITableViewCell {
    private let iconBackgroundView = UIView()
    private let mccIcon = UIImageView()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    private let nativeAmountLabel = UILabel()
    private let bottomDividerView = UIView()
    private var styleInitialized = false
    private var uiConfig: UIConfig! // swiftlint:disable:this implicitly_unwrapped_optional
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMMddhhmm")
        return formatter
    }

    private lazy var declinedImage = UIImage.imageFromPodBundle("declined-icon")?.asTemplate()

    var isLastCellInSection: Bool = false {
        didSet {
            bottomDividerView.isHidden = isLastCellInSection
        }
    }

    weak var cellController: TransactionListCellControllerTheme2?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setUpUI()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUIConfiguration(_ uiConfiguration: UIConfig) {
        guard !styleInitialized else {
            return
        }
        uiConfig = uiConfiguration
        contentView.backgroundColor = uiConfiguration.uiBackgroundSecondaryColor
        iconBackgroundView.backgroundColor = uiConfiguration.uiTertiaryColor
        mccIcon.tintColor = uiConfiguration.iconSecondaryColor
        descriptionLabel.font = uiConfiguration.fontProvider.mainItemRegularFont
        descriptionLabel.textColor = uiConfiguration.textPrimaryColor
        dateLabel.font = uiConfiguration.fontProvider.timestampFont
        dateLabel.textColor = uiConfiguration.textTertiaryColor
        amountLabel.font = uiConfiguration.fontProvider.amountSmallFont
        amountLabel.textColor = uiConfiguration.textPrimaryColor
        nativeAmountLabel.font = uiConfiguration.fontProvider.timestampFont
        nativeAmountLabel.textColor = uiConfiguration.textTertiaryColor
        bottomDividerView.backgroundColor = uiConfiguration.uiTertiaryColor
        styleInitialized = true
    }

    // swiftlint:disable:next function_parameter_count
    func set(mcc: MCC?, amount: String, nativeAmount: String?, transactionDescription: String?, date: Date,
             state: TransactionState)
    {
        let isDeclinedTransaction = state == .declined
        iconBackgroundView.isHidden = false
        iconBackgroundView.backgroundColor = isDeclinedTransaction ? .clear : uiConfig.uiTertiaryColor
        amountLabel.isHidden = false
        descriptionLabel.isHidden = false
        dateLabel.isHidden = false

        mccIcon.image = isDeclinedTransaction ? declinedImage : mcc?.iconTemplate()
        mccIcon.tintColor = isDeclinedTransaction ? uiConfig.uiErrorColor : uiConfig.iconSecondaryColor
        amountLabel.text = amount
        amountLabel.textColor = isDeclinedTransaction ? uiConfig.uiErrorColor : uiConfig.textPrimaryColor
        descriptionLabel.text = transactionDescription?.capitalized
        let formattedDate = TransactionListCellTheme2.dateFormatter.string(from: date)
        dateLabel.text = isDeclinedTransaction ? state.description() + " " + formattedDate : formattedDate

        let nativeAmountIsHidden = (amount == nativeAmount)
        nativeAmountLabel.isHidden = nativeAmountIsHidden
        nativeAmountLabel.text = nativeAmount

        amountLabel.snp.remakeConstraints { make in
            if nativeAmountIsHidden {
                make.right.centerY.equalToSuperview()
            } else {
                make.top.right.equalToSuperview()
            }
        }
    }
}

private extension TransactionListCellTheme2 {
    func setUpUI() {
        setUpIcon()
        let view = createContentView()
        setUpAmountLabel(superview: view)
        setUpDescriptionLabel(superview: view)
        setUpDateLabel(superview: view)
        setUpNativeAmountLabel(superview: view)
        setUpBottomDivider()
    }

    func setUpIcon() {
        contentView.addSubview(iconBackgroundView)
        iconBackgroundView.layer.cornerRadius = 20
        iconBackgroundView.isHidden = true
        iconBackgroundView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(19)
            make.bottom.equalToSuperview().inset(13)
        }
        mccIcon.contentMode = .center
        iconBackgroundView.addSubview(mccIcon)
        mccIcon.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.center.equalToSuperview()
        }
    }

    private func createContentView() -> UIView {
        let view = UIView()
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.equalTo(iconBackgroundView.snp.right).offset(16)
            make.right.equalTo(self).inset(20)
            make.top.equalTo(self).inset(17)
            make.bottom.equalTo(self).inset(15)
        }
        return view
    }

    func setUpAmountLabel(superview: UIView) {
        amountLabel.isHidden = true
        amountLabel.textAlignment = .right
        superview.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
        }
    }

    func setUpDescriptionLabel(superview: UIView) {
        descriptionLabel.isHidden = true
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        superview.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview().offset(-8)
            make.right.equalTo(amountLabel.snp.left).offset(-24)
        }
    }

    func setUpDateLabel(superview: UIView) {
        dateLabel.isHidden = true
        superview.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom)
            make.left.equalToSuperview()
        }
    }

    func setUpNativeAmountLabel(superview: UIView) {
        nativeAmountLabel.isHidden = true
        nativeAmountLabel.textAlignment = .right
        superview.addSubview(nativeAmountLabel)
        nativeAmountLabel.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
        }
    }

    func setUpBottomDivider() {
        contentView.addSubview(bottomDividerView)
        bottomDividerView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(iconBackgroundView.snp.right).offset(16)
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}

private var mccIconsCacheAssociationKey: UInt8 = 63

extension MCC {
    var iconsCache: [String: UIImage] {
        get {
            guard let retVal = objc_getAssociatedObject(self, &mccIconsCacheAssociationKey) as? [String: UIImage] else {
                let iconsCacheData: [String: UIImage] = [:]
                objc_setAssociatedObject(self,
                                         &mccIconsCacheAssociationKey,
                                         iconsCacheData,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
                return iconsCacheData
            }
            return retVal
        }
        set(newValue) {
            objc_setAssociatedObject(self,
                                     &mccIconsCacheAssociationKey,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    public func iconTemplate() -> UIImage? {
        var iconsCache = self.iconsCache
        if let iconTemplate = self.iconsCache[self.icon.rawValue] {
            return iconTemplate
        } else {
            let iconTemplate = image()?.asTemplate()
            iconsCache[icon.rawValue] = iconTemplate
            return iconTemplate
        }
    }
}
