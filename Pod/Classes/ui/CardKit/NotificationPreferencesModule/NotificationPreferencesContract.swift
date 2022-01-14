//
//  NotificationPreferencesContract.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 08/03/2019.
//

import AptoSDK
import Bond

protocol NotificationPreferencesModuleProtocol: UIModuleProtocol {}

protocol NotificationPreferencesInteractorProtocol {
    func fetchPreferences(completion: @escaping Result<NotificationPreferences, NSError>.Callback)
    func updatePreferences(_ preferences: NotificationPreferences,
                           completion: @escaping Result<NotificationPreferences, NSError>.Callback)
}

class NotificationRow {
    let id: String
    let title: String
    var isChannel1Active: Bool
    var isChannel2Active: Bool
    let isEnabled: Bool

    init(id: String, title: String, isChannel1Active: Bool, isChannel2Active: Bool, isEnabled: Bool) {
        self.id = id
        self.title = title
        self.isChannel1Active = isChannel1Active
        self.isChannel2Active = isChannel2Active
        self.isEnabled = isEnabled
    }
}

class NotificationCategory {
    let title: String
    let description: String
    let rows: [NotificationRow]

    init(title: String, description: String, rows: [NotificationRow]) {
        self.title = title
        self.description = description
        self.rows = rows
    }
}

enum NotificationChannel {
    case push
    case email
    case sms
}

class NotificationPreferencesViewModel {
    let channel1: Observable<NotificationChannel?> = Observable(nil)
    let channel2: Observable<NotificationChannel?> = Observable(nil)
    let categories: Observable<[NotificationCategory]> = Observable([])
}

protocol NotificationPreferencesPresenterProtocol: AnyObject {
    var router: NotificationPreferencesModuleProtocol? { get set }
    var interactor: NotificationPreferencesInteractorProtocol? { get set }
    var viewModel: NotificationPreferencesViewModel { get }
    var analyticsManager: AnalyticsServiceProtocol? { get set }

    func viewLoaded()
    func closeTapped()
    func didUpdateNotificationRow(_ row: NotificationRow)
}
