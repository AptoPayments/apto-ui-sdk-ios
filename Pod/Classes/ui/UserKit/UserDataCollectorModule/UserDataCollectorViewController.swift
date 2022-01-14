//
//  UserDataCollectorViewController.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 25/01/16.
//  Copyright © 2018 Apto. All rights reserved.
//

import AptoSDK
import Bond
import SnapKit

protocol UserDataCollectorEventHandler: AnyObject {
    func viewLoaded()
    func nextStepTapped()
    func previousStepTapped()
}

class UserDataCollectorViewController: AptoViewController, UserDataCollectorViewProtocol {
    private unowned let eventHandler: UserDataCollectorEventHandler
    fileprivate let formView: MultiStepForm
    fileprivate let progressView: ProgressView

    init(uiConfiguration: UIConfig, eventHandler: UserDataCollectorEventHandler) {
        formView = MultiStepForm()
        progressView = ProgressView(maxValue: 100, uiConfig: uiConfiguration)
        self.eventHandler = eventHandler
        super.init(uiConfiguration: uiConfiguration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        eventHandler.viewLoaded()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    func show(fields: [FormRowView]) {
        formView.show(rows: fields)
    }

    func push(fields: [FormRowView]) {
        formView.show(rows: fields, withAnimation: .push)
    }

    func pop(fields: [FormRowView]) {
        formView.show(rows: fields, withAnimation: .pop)
    }

    func showNavProfileButton() {
        installNavRightButton(UIImage.imageFromPodBundle("top_profile.png"),
                              target: self,
                              action: #selector(UserDataCollectorViewController.nextTapped))
    }

    func update(progress: Float) {
        progressView.update(progress: progress)
    }

    // MARK: - Private methods

    override func closeTapped() {
        eventHandler.previousStepTapped()
    }

    override func nextTapped() {
        _ = formView.resignFirstResponder()
        eventHandler.nextStepTapped()
    }
}

private extension UserDataCollectorViewController {
    func setUpUI() {
        view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
        navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
        edgesForExtendedLayout = .top
        extendedLayoutIncludesOpaqueBars = true
        view.addSubview(progressView)
        view.addSubview(formView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.right.equalTo(view)
            make.height.equalTo(4)
        }
        formView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
        formView.backgroundColor = UIColor.clear
    }
}
