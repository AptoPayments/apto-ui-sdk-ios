//
//  HostViewController.swift
//  SnapshotTests
//
//  Created by Fabio Cuomo on 15/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class HostViewController: UIViewController {
    private let rootView: UIView
    
    init(with view: UIView) {
        self.rootView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(rootView)
        rootView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
