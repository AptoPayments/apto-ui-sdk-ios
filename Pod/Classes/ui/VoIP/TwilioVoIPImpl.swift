//
// TwilioVoIPImpl.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 17/06/2019.
//

import AptoSDK
import TwilioVoice

public class TwilioVoIPClient: NSObject, VoIPCallProtocol {
    private var twilioCall: Call?
    private var startedAt: Date?
    private var callback: Result<Void, NSError>.Callback?

    public var isMuted: Bool {
        get {
            guard let call = twilioCall else { return false }
            return call.isMuted
        }
        set(newValue) {
            twilioCall?.isMuted = newValue
        }
    }

    public var isOnHold: Bool {
        get {
            guard let call = twilioCall else { return false }
            return call.isOnHold
        }
        set(newValue) {
            twilioCall?.isOnHold = newValue
        }
    }

    public var timeElapsed: TimeInterval {
        guard let date = startedAt else { return 0 }
        return Date().timeIntervalSince(date)
    }

    public func call(_ destination: VoIPToken, callback: @escaping Result<Void, NSError>.Callback) {
        self.callback = callback
        let connectOptions = ConnectOptions(accessToken: destination.accessToken) { builder in
            builder.params = ["request_token": destination.requestToken]
        }
        twilioCall = TwilioVoiceSDK.connect( options: connectOptions, delegate: self)
    }

    public func sendDigits(_ digits: VoIPDigits) {
        twilioCall?.sendDigits(digits.digits)
    }

    public func disconnect() {
        twilioCall?.disconnect()
        twilioCall = nil
    }
}

extension TwilioVoIPClient: CallDelegate {
    public func callDidConnect(call: Call) {
        self.twilioCall = call
        startedAt = Date()
        callback?(.success(()))
        callback = nil
    }

    public func callDidFailToConnect(call _: Call, error: Error) {
        twilioCall = nil
        callback?(.failure(error as NSError))
        callback = nil
    }

    public func callDidDisconnect(call _: Call, error: Error?) {
        twilioCall = nil
        if let error = error as NSError? {
            callback?(.failure(error))
            callback = nil
        }
    }
}
