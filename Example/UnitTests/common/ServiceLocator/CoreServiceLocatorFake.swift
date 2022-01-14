//
// CoreServiceLocatorFake.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/08/2019.
//

@testable import AptoSDK
import Foundation

class CoreServiceLocatorFake: ServiceLocatorProtocol {
    lazy var networkLocatorFake = NetworkLocatorFake()
    lazy var networkLocator: NetworkLocatorProtocol = networkLocatorFake
    lazy var storageLocatorFake = StorageLocatorFake()
    lazy var storageLocator: StorageLocatorProtocol = storageLocatorFake

    lazy var platform: AptoPlatformProtocol = AptoPlatform(serviceLocator: self)
    lazy var analyticsManagerSpy = AnalyticsManagerSpy()
    lazy var analyticsManager: AnalyticsServiceProtocol = analyticsManagerSpy
    lazy var notificationHandlerFake = NotificationHandlerFake()
    lazy var notificationHandler: NotificationHandler = notificationHandlerFake
}
