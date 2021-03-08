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
    struct Constants {
        static let containerViewHeight = 230
        static let headerViewHeight = 57
        static let itemActionViewHeight = 72
    }
    let uiConfiguration: UIConfig
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = uiConfiguration.textMessageColor
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private lazy var headerTextView = HeaderTextView(uiconfig: self.uiConfiguration, text: "load_funds.selector_dialog.title".podLocalized())
    private(set) lazy var item1ActionDetailView = DetailActionView(uiconfig: self.uiConfiguration,
                                                                   textTitle: "load_funds.selector_dialog.card.title".podLocalized(),
                                                                   textSubTitle: "load_funds.selector_dialog.card.description".podLocalized())
    private(set) lazy var item2ActionDetailView = DetailActionView(uiconfig: self.uiConfiguration,
                                                                   textTitle: "load_funds.selector_dialog.direct_deposit.title".podLocalized(),
                                                                   textSubTitle: "load_funds.selector_dialog.direct_deposit.description".podLocalized())
    private(set) lazy var dimView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        view.isHidden = true
        view.alpha = 0
        return view
    }()
    private var topConstraint: Constraint?
    
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
            make.height.equalTo(Constants.containerViewHeight)
        }
        headerTextView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(Constants.headerViewHeight)
        }
        item1ActionDetailView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerTextView.snp.bottom)
            make.height.equalTo(Constants.itemActionViewHeight)
        }
        item2ActionDetailView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(item1ActionDetailView.snp.bottom)
            make.height.equalTo(Constants.itemActionViewHeight)
        }
    }
    
    // MARK: Public methods
    public func present(in superview: UIView, completion: ((Bool) -> Void)? = nil) {
        guard self.superview != superview else { return }

        superview.addSubview(dimView)
        superview.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false
        dimView.frame = superview.bounds

        snp.remakeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            self.topConstraint = make.top.equalTo(superview.frame.height).constraint
            make.height.equalTo(Constants.containerViewHeight)
        }
        containerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }

        UIView.animate(withDuration: 0.3, animations: { [dimView] in
            dimView.isHidden = false
            dimView.alpha = 1
        }) { complete in
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.67,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: { [weak self] in
                            self?.topConstraint?.update(offset: superview.frame.height - CGFloat(Constants.containerViewHeight) - 30)
                            superview.layoutIfNeeded()
            }) { _ in
                completion?(true)
            }
        }
    }
}

