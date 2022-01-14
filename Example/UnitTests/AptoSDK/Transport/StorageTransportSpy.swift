//
//  StorageTransportSpy.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 21/1/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Alamofire
@testable import AptoSDK
import Foundation
import SwiftyJSON

class StorageTransportSpy: JSONTransportSpy {
    typealias TransportResult = Swift.Result<JSON, NSError>.Callback
    typealias TransportVoidResult = Swift.Result<Void, NSError>.Callback
    var requestesURLs: [URL] {
        return messages.map { $0.url }
    }

    var voidRequestesURLs: [URL] {
        return voidMessages.map { $0.url }
    }

    var messages = [(url: URL, completion: TransportResult)]()
    var voidMessages = [(url: URL, completion: TransportVoidResult)]()

    override func get(_ url: URLConvertible,
                      authorization: JSONTransportAuthorization,
                      parameters: [String: AnyObject]?,
                      headers: [String: String]?,
                      acceptRedirectTo: ((String) -> Bool)?,
                      filterInvalidTokenResult: Bool,
                      callback: @escaping Swift.Result<JSON, NSError>.Callback)
    {
        super.get(url, authorization: authorization, parameters: parameters, headers: headers, acceptRedirectTo: acceptRedirectTo, filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)

        if let requestedURL = try? lastGetURL?.asURL() {
            messages.append((requestedURL, callback))
        }
    }

    override func post(_ url: URLConvertible,
                       authorization: JSONTransportAuthorization,
                       parameters: [String: AnyObject]?,
                       filterInvalidTokenResult: Bool,
                       callback: @escaping Swift.Result<JSON, NSError>.Callback)
    {
        super.post(url, authorization: authorization, parameters: parameters, filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)

        if let requestedURL = try? lastPostURL?.asURL() {
            messages.append((requestedURL, callback))
        }
    }

    override func delete(_ url: URLConvertible, authorization: JSONTransportAuthorization, parameters: [String: AnyObject]?, filterInvalidTokenResult: Bool, callback: @escaping Result<Void, NSError>.Callback) {
        super.delete(url, authorization: authorization, parameters: parameters, filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)

        if let requestedURL = try? lastDeleteURL?.asURL() {
            voidMessages.append((requestedURL, callback))
        }
    }

    func complete(with error: NSError, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(withResult result: JSON, at index: Int = 0) {
        messages[index].completion(.success(result))
    }

    func completeVoid(with error: NSError, at index: Int = 0) {
        voidMessages[index].completion(.failure(error))
    }

    func completeVoid(at index: Int = 0) {
        voidMessages[index].completion(.success(()))
    }
}
