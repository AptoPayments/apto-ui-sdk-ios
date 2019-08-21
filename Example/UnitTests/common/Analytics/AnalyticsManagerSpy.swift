//
//  AnalyticsManagerSpy.swift
//  UnitTests
//
//  Created by Pau Teruel on 19/03/2019.
//

@testable import AptoSDK

class AnalyticsManagerSpy: AnalyticsServiceProtocol {
  private(set) var initializeCalled = false
  private(set) var accessTokenPassed: String?
  func initialize(accessToken: String) {
    initializeCalled = true
    accessTokenPassed = accessToken
  }

  private(set) var trackCalled = false
  private(set) var lastEvent: Event? = nil
  private(set) var lastProperties: [String : Any]?
  func track(event: Event, properties: [String : Any]?) {
    trackCalled = true
    lastEvent = event
    lastProperties = properties
  }

  private(set) var createUserCalled = false
  private(set) var lastCreateUserUserId: String?
  func createUser(userId: String) {
    createUserCalled = true
    lastCreateUserUserId = userId
  }

  private(set) var loginUserCalled = false
  func loginUser(userId: String) {
    loginUserCalled = true
  }

  private(set) var logoutUserCalled = false
  func logoutUser() {
    logoutUserCalled = true
  }

}
