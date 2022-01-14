//
//  NotificationHandlerFake.swift
//  AptoSDK
//
//  Created by Takeichi Kanzaki on 30/10/2019.
//

import AptoSDK
import Foundation

private class NotificationReceiver {
    let target: AnyObject
    private let selector: Selector
    private let object: AnyObject?

    init(target: AnyObject, selector: Selector, object: AnyObject?) {
        self.target = target
        self.selector = selector
        self.object = object
    }

    func run() {
        if let object = object {
            _ = target.perform(selector, with: object)
        } else {
            _ = target.perform(selector)
        }
    }
}

class NotificationHandlerSpy: NotificationHandler {
    private(set) var postNotificationCalled = false
    private(set) var lastPostNotificationName: Notification.Name?
    private(set) var lastPostNotificationObject: AnyObject?
    private(set) var lastPostNotificationUserInfo: [String: AnyObject]?
    func postNotification(_ name: Notification.Name, object: AnyObject?, userInfo: [String: AnyObject]?) {
        postNotificationCalled = true
        lastPostNotificationName = name
        lastPostNotificationObject = object
        lastPostNotificationUserInfo = userInfo
    }

    private(set) var addObserverCalled = false
    private(set) var lastAddObserverObserver: AnyObject?
    private(set) var lastAddObserverSelector: Selector?
    private(set) var lastAddObserverName: Notification.Name?
    private(set) var lastAddObserverObject: AnyObject?
    func addObserver(_ observer: AnyObject, selector: Selector, name: Notification.Name, object: AnyObject?) {
        addObserverCalled = true
        lastAddObserverObserver = observer
        lastAddObserverSelector = selector
        lastAddObserverName = name
        lastAddObserverObject = object
    }

    private(set) var removeObserverCalled = false
    private(set) var lastRemoveObserverObserver: AnyObject?
    func removeObserver(_ observer: AnyObject) {
        removeObserverCalled = true
        lastRemoveObserverObserver = observer
    }

    private(set) var removeSingleObserverCalled = false
    private(set) var lastRemoveSingleObserverObserver: AnyObject?
    private(set) var lastRemoveSingleObserverName: Notification.Name?
    private(set) var lastRemoveSingleObserverObject: AnyObject?
    func removeObserver(_ observer: AnyObject, name: Notification.Name, object: AnyObject?) {
        removeSingleObserverCalled = true
        lastRemoveSingleObserverObserver = observer
        lastRemoveSingleObserverName = name
        lastRemoveSingleObserverObject = object
    }
}

class NotificationHandlerFake: NotificationHandlerSpy {
    // Right now only support an observer per notification type, which is our current testing scenario.
    private var receivers: [Notification.Name: NotificationReceiver] = [:]

    override func postNotification(_ name: Notification.Name, object: AnyObject?, userInfo: [String: AnyObject]?) {
        super.postNotification(name, object: object, userInfo: userInfo)
        receivers[name]?.run()
    }

    override func addObserver(_ observer: AnyObject, selector: Selector, name: Notification.Name, object: AnyObject?) {
        super.addObserver(observer, selector: selector, name: name, object: object)
        receivers[name] = NotificationReceiver(target: observer, selector: selector, object: object)
    }

    override func removeObserver(_ observer: AnyObject) {
        super.removeObserver(observer)
        for (name, receiver) in receivers {
            if receiver.target === observer {
                receivers.removeValue(forKey: name)
            }
        }
    }

    override func removeObserver(_ observer: AnyObject, name: Notification.Name, object: AnyObject?) {
        super.removeObserver(observer, name: name, object: object)
        if observer === receivers[name]?.target {
            receivers.removeValue(forKey: name)
        }
    }
}
