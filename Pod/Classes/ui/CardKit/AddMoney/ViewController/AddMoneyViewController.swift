//
//  AddMoneyViewController.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 26/1/21.
//

import AptoSDK

class AddMoneyViewController: ShiftViewController {
    private lazy var bottomView = AddMoneyView(uiconfig: self.uiConfiguration)
    
    override init(uiConfiguration: UIConfig) {
        super.init(uiConfiguration: uiConfiguration)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        view.addSubview(bottomView)
    }
    
    private func setupConstraints() {
        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(bottomConstraint).inset(34)
            make.height.equalTo(250)
        }
    }
}

