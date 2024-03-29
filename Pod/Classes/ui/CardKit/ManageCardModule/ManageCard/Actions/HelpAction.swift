//
//  HelpAction.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 12/12/2018.
//

import UIKit

class HelpAction {
    private let emailRecipients: [String?]
    private let mailSender: MailSender

    init(emailRecipients: [String?]) {
        self.emailRecipients = emailRecipients
        mailSender = MailSender()
    }

    func run() {
        mailSender.sendMessageWith(subject: "help.email.subject".podLocalized(),
                                   message: "help.email.body".podLocalized(),
                                   recipients: emailRecipients)
    }
}
