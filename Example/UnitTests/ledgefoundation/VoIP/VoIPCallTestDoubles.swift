//
// VoIPCallTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 18/06/2019.
//

import Foundation
@testable import AptoSDK

class VoIPCallSpy: VoIPCallProtocol {
  var isMuted = false
  var isOnHold = false
  var timeElapsed: TimeInterval = 0

  private(set) var callCalled = false
  private(set) var lastVoIPToken: VoIPToken?
  func call(_ destination: VoIPToken, callback: @escaping Result<Void, NSError>.Callback) {
    callCalled = true
    lastVoIPToken = destination
  }

  private(set) var sendDigitsCalled = false
  private(set) var lastDigitsSent: VoIPDigits?
  func sendDigits(_ digits: VoIPDigits) {
    sendDigitsCalled = true
    lastDigitsSent = digits
  }

  private(set) var disconnectCalled = false
  func disconnect() {
    disconnectCalled = true
  }
}

class VoIPCallFake: VoIPCallSpy {
  var nextCallResult: Result<Void, NSError>?
  override func call(_ destination: VoIPToken, callback: @escaping Result<Void, NSError>.Callback) {
    super.call(destination, callback: callback)

    if let result = nextCallResult {
      callback(result)
    }
  }
}
