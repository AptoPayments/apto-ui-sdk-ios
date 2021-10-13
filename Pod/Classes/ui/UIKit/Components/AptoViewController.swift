//
//  AptoViewController.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 14/09/2018.
//
//

import UIKit
import AptoSDK
import SnapKit

class AptoViewController: UIViewController {
  let uiConfiguration: UIConfig

  init(uiConfiguration: UIConfig) {
    self.uiConfiguration = uiConfiguration
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  open override var preferredStatusBarStyle: UIStatusBarStyle {
    switch uiConfiguration.uiStatusBarStyle {
    case .light:
      return .lightContent
    case .dark:
      return .default
    case .auto:
      if let navigationBarColor = navigationController?.navigationBar.barTintColor,
         navigationController?.isNavigationBarHidden == false {
        return navigationBarColor.isLight ? .default : .lightContent
      }
      if let backgroundColor = view.backgroundColor {
        return backgroundColor.isLight ? .default : .lightContent
      }
      return .default
    }
  }

  var topConstraint: ConstraintItem {
    if #available(iOS 11, *) {
      return view.safeAreaLayoutGuide.snp.top
    }
    return view.snp.top
  }

  var bottomConstraint: ConstraintItem {
    if #available(iOS 11, *) {
      return view.safeAreaLayoutGuide.snp.bottom
    }
    return view.snp.bottom
  }

  func showLoadingSpinner() {
    showLoadingSpinner(tintColor: uiConfiguration.uiPrimaryColor, position: .center)
  }

  func showOrHide(_ action: UIBarButtonItem, index: Int, items: inout [UIBarButtonItem], isVisible: Bool) {
    if isVisible {
      if !items.contains(action) {
        if items.isEmpty {
          items.append(action)
        }
        else {
          items.insert(action, at: index)
        }
      }
    }
    else {
      items.removeAll { $0 == action }
    }
  }

  func buildTopBarButton(iconName: String, target: Any, action: Selector) -> UIBarButtonItem {
    let barButtonItem = UIBarButtonItem(image: UIImage.imageFromPodBundle(iconName)?.asTemplate(),
                                        style: .plain,
                                        target: target,
                                        action: action)
    barButtonItem.tintColor = uiConfiguration.iconTertiaryColor
    return barButtonItem
  }
}
