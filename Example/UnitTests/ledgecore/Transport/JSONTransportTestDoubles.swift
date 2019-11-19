//
// JSONTransportTestDoubles.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 20/08/2019.
//

import Foundation
import Alamofire
import SwiftyJSON
@testable import AptoSDK

class JSONTransportSpy: JSONTransport {
  let environment: JSONTransportEnvironment = .staging
  lazy var baseUrlProvider: BaseURLProvider = environment

  private(set) var getCalled = false
  private(set) var lastGetURL: URLConvertible?
  private(set) var lastGetAuthorization: JSONTransportAuthorization?
  private(set) var lastGetParameters: [String: AnyObject]?
  private(set) var lastGetHeaders: [String: String]?
  private(set) var lastGetAcceptRedirectTo: ((String) -> Bool)?
  private(set) var lastGetFilterInvalidTokenResult: Bool?
  func get(_ url: URLConvertible, authorization: JSONTransportAuthorization, parameters: [String: AnyObject]?,
           headers: [String: String]?, acceptRedirectTo: ((String) -> Bool)?, filterInvalidTokenResult: Bool,
           callback: @escaping Swift.Result<JSON, NSError>.Callback) {
    getCalled = true
    lastGetURL = url
    lastGetAuthorization = authorization
    lastGetParameters = parameters
    lastGetHeaders = headers
    lastGetAcceptRedirectTo = acceptRedirectTo
    lastGetFilterInvalidTokenResult = filterInvalidTokenResult
  }

  private(set) var postCalled = false
  private(set) var lastPostURL: URLConvertible?
  private(set) var lastPostAuthorization: JSONTransportAuthorization?
  private(set) var lastPostParameters: [String: AnyObject]?
  private(set) var lastPostFilterInvalidTokenResult: Bool?
  func post(_ url: URLConvertible, authorization: JSONTransportAuthorization, parameters: [String: AnyObject]?,
            filterInvalidTokenResult: Bool, callback: @escaping Swift.Result<JSON, NSError>.Callback) {
    postCalled = true
    lastPostURL = url
    lastPostAuthorization = authorization
    lastPostParameters = parameters
    lastPostFilterInvalidTokenResult = filterInvalidTokenResult
  }

  private(set) var putCalled = false
  private(set) var lastPutURL: URLConvertible?
  private(set) var lastPutAuthorization: JSONTransportAuthorization?
  private(set) var lastPutParameters: [String: AnyObject]?
  private(set) var lastPutFilterInvalidTokenResult: Bool?
  func put(_ url: URLConvertible, authorization: JSONTransportAuthorization, parameters: [String: AnyObject]?,
           filterInvalidTokenResult: Bool, callback: @escaping Swift.Result<JSON, NSError>.Callback) {
    putCalled = true
    lastPutURL = url
    lastPutAuthorization = authorization
    lastPutParameters = parameters
    lastPutFilterInvalidTokenResult = filterInvalidTokenResult
  }

  private(set) var deleteCalled = false
  private(set) var lastDeleteURL: URLConvertible?
  private(set) var lastDeleteAuthorization: JSONTransportAuthorization?
  private(set) var lastDeleteParameters: [String: AnyObject]?
  private(set) var lastDeleteFilterInvalidTokenResult: Bool?
  func delete(_ url: URLConvertible, authorization: JSONTransportAuthorization, parameters: [String: AnyObject]?,
              filterInvalidTokenResult: Bool, callback: @escaping Swift.Result<Void, NSError>.Callback) {
    deleteCalled = true
    lastDeleteURL = url
    lastDeleteAuthorization = authorization
    lastDeleteParameters = parameters
    lastDeleteFilterInvalidTokenResult = filterInvalidTokenResult
  }
}

class JSONTransportFake: JSONTransportSpy {
  var nextGetResult: Swift.Result<JSON, NSError>?
  override func get(_ url: URLConvertible, authorization: JSONTransportAuthorization, parameters: [String: AnyObject]?,
                    headers: [String: String]?, acceptRedirectTo: ((String) -> Bool)?, filterInvalidTokenResult: Bool,
                    callback: @escaping Swift.Result<JSON, NSError>.Callback) {
    super.get(url, authorization: authorization, parameters: parameters, headers: headers,
              acceptRedirectTo: acceptRedirectTo, filterInvalidTokenResult: filterInvalidTokenResult,
              callback: callback)
    if let result = nextGetResult {
      callback(result)
    }
  }

  var nextPostResult: Swift.Result<JSON, NSError>?
  override func post(_ url: URLConvertible, authorization: JSONTransportAuthorization, parameters: [String: AnyObject]?,
                     filterInvalidTokenResult: Bool, callback: @escaping Swift.Result<JSON, NSError>.Callback) {
    super.post(url, authorization: authorization, parameters: parameters,
               filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)
    if let result = nextPostResult {
      callback(result)
    }
  }

  var nextPutResult: Swift.Result<JSON, NSError>?
  override func put(_ url: URLConvertible, authorization: JSONTransportAuthorization, parameters: [String: AnyObject]?,
                    filterInvalidTokenResult: Bool, callback: @escaping Swift.Result<JSON, NSError>.Callback) {
    super.put(url, authorization: authorization, parameters: parameters,
              filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)
    if let result = nextPutResult {
      callback(result)
    }
  }

  var nextDeleteResult: Swift.Result<Void, NSError>?
  override func delete(_ url: URLConvertible, authorization: JSONTransportAuthorization,
                       parameters: [String: AnyObject]?, filterInvalidTokenResult: Bool,
                       callback: @escaping Swift.Result<Void, NSError>.Callback) {
    super.delete(url, authorization: authorization, parameters: parameters,
                 filterInvalidTokenResult: filterInvalidTokenResult, callback: callback)
    if let result = nextDeleteResult {
      callback(result)
    }
  }
}
