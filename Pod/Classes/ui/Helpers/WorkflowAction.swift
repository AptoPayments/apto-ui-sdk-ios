//
//  WorkflowAction.swift
//  AptoUISDK
//
//  Created by Takeichi Kanzaki on 18/07/2019.
//

import AptoSDK
import Foundation

extension WorkflowActionConfiguration {
    var presentationMode: UIViewControllerPresentationMode {
        return .push
    }
}

extension Content {
    var presentationMode: UIViewControllerPresentationMode {
        return .modal
    }
}

extension WaitListActionConfiguration {
    var presentationMode: UIViewControllerPresentationMode {
        return .modal
    }
}
