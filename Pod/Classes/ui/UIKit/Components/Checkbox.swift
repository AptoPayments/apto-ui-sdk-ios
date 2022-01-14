//
// Checkbox.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 23/05/2019.
//

import AptoSDK
import Bond
import ReactiveKit
import SnapKit
import UIKit

class Checkbox: UIView {
    private let disposeBag = DisposeBag()
    private let uiConfig: UIConfig
    private lazy var checkedImage = UIImage.imageFromPodBundle("checkbox_ON")?.asTemplate()
    private lazy var uncheckedImage = UIImage.imageFromPodBundle("checkbox_OFF")?.asTemplate()
    private let imageView = UIImageView()

    let isChecked: Observable<Bool>
    override var isUserInteractionEnabled: Bool {
        didSet {
            imageView.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }

    var isEnabled: Bool = true {
        didSet {
            isUserInteractionEnabled = isEnabled
            imageView.alpha = isEnabled ? 1 : 0.3
        }
    }

    init(isChecked: Bool = false, uiConfig: UIConfig) {
        self.isChecked = Observable(isChecked)
        self.uiConfig = uiConfig
        super.init(frame: .zero)

        setUpUI()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Set up UI

private extension Checkbox {
    func setUpUI() {
        setUpImageView()
        setUpListener()
    }

    func setUpImageView() {
        imageView.contentMode = .center
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        isChecked.observeNext { [unowned self] _ in
            self.updateImageViewForCurrentState()
        }.dispose(in: disposeBag)
    }

    func updateImageViewForCurrentState() {
        if isChecked.value {
            imageView.image = checkedImage
            imageView.tintColor = uiConfig.uiPrimaryColor
        } else {
            imageView.image = uncheckedImage
            imageView.tintColor = uiConfig.iconSecondaryColor
        }
    }

    func setUpListener() {
        isUserInteractionEnabled = true
        addTapGestureRecognizer { [unowned self] in
            self.toggleChecked()
        }
        imageView.addTapGestureRecognizer { [unowned self] in
            self.toggleChecked()
        }
    }

    func toggleChecked() {
        isChecked.send(!isChecked.value)
    }
}
