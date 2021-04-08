//
//  GmailSender.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 22/3/21.
//

import Foundation

struct GmailSender {
    private let recipient: String
    private let subject: String
    private let body: String

    init(recipient: String, subject: String, body: String = "") {
        self.recipient = recipient
        self.subject = subject
        self.body = body
    }
    
    func canSendEmail() -> Bool {
        guard let urlString = urlString() else { return false }
        return UIApplication.shared.canOpenURL(urlString)
    }
    
    func sendMessage(completion: ((Bool) -> Void)? = nil) {
        guard let urlString = urlString(),
              canSendEmail() else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(urlString, options: [:], completionHandler: completion)
        } else {
            UIApplication.shared.open(urlString)
        }
    }
    
    // MARK: Private methods
    private func urlString() -> URL? {
        let googleUrlString = String(format: "googlegmail:///co?to=%@&subject=%@&body=%@",
                                     recipient,
                                     subject,
                                     body)
        return URL(string: googleUrlString)
    }
}
