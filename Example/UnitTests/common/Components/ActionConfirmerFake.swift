//
//  ActionConfirmerFake.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 16/10/2018.
//
//

import AptoSDK
@testable import AptoUISDK

enum ActionConfirmerAction {
    case ok
    case cancel
}

class ActionConfirmerFake: ActionConfirmer {
    static var nextActionToExecute: ActionConfirmerAction?
    private(set) static var confirmCalled = false
    private(set) static var lastTitle: String?
    private(set) static var lastMessage: String?
    private(set) static var lastOkTitle: String?
    private(set) static var lastCancelTitle: String?
    static func confirm(title: String?,
                        message: String?,
                        okTitle: String,
                        cancelTitle: String?,
                        handler: @escaping (UIAlertAction) -> Void)
    {
        confirmCalled = true
        lastTitle = title
        lastMessage = message
        lastOkTitle = okTitle
        lastCancelTitle = cancelTitle

        if let action = nextActionToExecute {
            switch action {
            case .ok:
                handler(UIAlertAction(title: okTitle, style: .default))
            case .cancel:
                handler(UIAlertAction(title: cancelTitle, style: .cancel))
            }
        }
    }
}
