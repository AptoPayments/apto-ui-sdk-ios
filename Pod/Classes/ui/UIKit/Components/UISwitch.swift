//
//  UISwitch.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 10/03/2018.
//

import UIKit

private var uiSwitchOnChangeListenerAssociationKey: UInt8 = 126

// onChange listener as blocks (not selectors)

extension UISwitch {
    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate enum AssociatedObjectKeys {
        static var onChangeListener = "UISwitch_onChangeListener"
    }

    // Set our computed property type to a closure
    var onChange: ((UISwitch) -> Void)? {
        get {
            return objc_getAssociatedObject(self,
                                            &AssociatedObjectKeys.onChangeListener)
                as? ((UISwitch) -> Void)
        }
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.onChangeListener, newValue,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
    }

    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func setOnChnageListener(action: ((UISwitch) -> Void)?) {
        onChange = action
        addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
    }

    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc private func switchChanged(mySwitch: UISwitch) {
        if let action = onChange {
            action(mySwitch)
        }
    }
}
