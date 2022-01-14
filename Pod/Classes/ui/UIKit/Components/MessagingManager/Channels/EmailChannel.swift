//
//  EmailChannel.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 22/06/16.
//
//

import Foundation
import MessageUI

class EmailChannel: NSObject, MessagingManagerChannel {
    weak var delegate: MessagingManagerChannelDelegate?

    func channelAvailable() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }

    func sendMessageWith(subject: String, message: String, url _: URL?, recipients: [String]?) {
        guard channelAvailable() else {
            delegate?.didCancelFor(channel: self)
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setSubject(subject)
        composer.setMessageBody(message, isHTML: false)
        composer.setToRecipients(recipients)
        UIApplication.topViewController()?.present(composer, animated: true, completion: nil)
    }
}

extension EmailChannel: MFMailComposeViewControllerDelegate {
    func mailComposeController(_: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,
                               error _: Error?)
    {
        switch result {
        case MFMailComposeResult.sent:
            delegate?.didSucceededFor(channel: self)
            UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.saved:
            delegate?.didSaveFor(channel: self)
            UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.cancelled:
            delegate?.didCancelFor(channel: self)
            UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
        case MFMailComposeResult.failed:
            delegate?.didReceiveErrorFor(channel: self)
        @unknown default:
            delegate?.didCancelFor(channel: self)
        }
    }
}
