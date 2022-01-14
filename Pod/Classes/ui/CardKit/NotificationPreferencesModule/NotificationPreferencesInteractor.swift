//
//  NotificationPreferencesInteractor.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/03/2019.
//

import AptoSDK

class NotificationPreferencesInteractor: NotificationPreferencesInteractorProtocol {
    private let platform: AptoPlatformProtocol

    init(platform: AptoPlatformProtocol) {
        self.platform = platform
    }

    func fetchPreferences(completion: @escaping Result<NotificationPreferences, NSError>.Callback) {
        platform.fetchNotificationPreferences(callback: completion)
    }

    func updatePreferences(_ preferences: NotificationPreferences,
                           completion: @escaping Result<NotificationPreferences, NSError>.Callback)
    {
        platform.updateNotificationPreferences(preferences, callback: completion)
    }
}
