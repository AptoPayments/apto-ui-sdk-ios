//
//  SentryLoggerHelper.swift
//  Demo
//
//  Created by Fabio Cuomo on 1/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import Sentry

struct SentryLoggerHelper {
    struct Constants {
        static let StoredAptoEnvironment = "STORED_APTO_ENVIRONMENT"
        static let StoredAptoApiKey = "STORED_APTO_API_KEY"
        static let BranchIOTagName = "branch.io"
        static let BranchParametersErrorValue = "parameters_error"
        static let BranchParametersKey = "branch_parameters"
        static let BranchParametersSuccessValue = "parameters_success"
        static let ErrorDomain = "com.aptopayments.aptocard"
        static let EmptyValue = "EMPTY_VALUE"
    }
    
    public static func logBranch(_ parameters: [AnyHashable: Any]?, storedConfiguration: Configuration?) {
        guard let parameters = parameters,
              let clickedLink = parameters[AptoBranchKeys.clickedLink] as? Bool,
              clickedLink else { return }
              
        logToSentry(parameters, storedConfiguration: storedConfiguration)
    }
    
    private static func logToSentry(_ parameters: [AnyHashable: Any]?, storedConfiguration: Configuration?) {
        setupSentryScope(parameters, storedConfiguration: storedConfiguration)
        
        guard let parameters = parameters else {
            let userInfo = [NSLocalizedDescriptionKey : "Branch parameters do not exist"]
            let error = NSError(domain: Constants.ErrorDomain, code: 0, userInfo: userInfo)
            SentrySDK.capture(error: error) { (scope) in
                scope.setTag(value: Constants.BranchParametersErrorValue, key: Constants.BranchIOTagName)
            }
            return
        }
        if parameters[AptoBranchKeys.apiKey] == nil {
            let userInfo = [NSLocalizedDescriptionKey : "Branch parameter API-KEY not found"]
            captureSentryError(userInfo: userInfo,
                               tag: Constants.BranchIOTagName,
                               value: Constants.BranchParametersErrorValue)
            return
        }
        if parameters[AptoBranchKeys.environment] == nil {
            let userInfo = [NSLocalizedDescriptionKey : "Branch parameter ENVIRONMENT not found"]
            captureSentryError(userInfo: userInfo,
                               tag: Constants.BranchIOTagName,
                               value: Constants.BranchParametersErrorValue)
            return
        }
    }
    
    private static func setupSentryScope(_ parameters: [AnyHashable: Any]?, storedConfiguration: Configuration?) {
        SentrySDK.configureScope { [storedConfiguration] scope in
            var context: [String: Any] = [:]
            context[Constants.StoredAptoEnvironment] = storedConfiguration?.environment.description ?? Constants.EmptyValue
            context[Constants.StoredAptoApiKey] = storedConfiguration?.apiKey ?? Constants.EmptyValue
            if let parameters = parameters {
                context[AptoBranchKeys.environment] = extract(key: AptoBranchKeys.environment, from: parameters)
                context[AptoBranchKeys.apiKey] = extract(key: AptoBranchKeys.apiKey, from: parameters)
                context[AptoBranchKeys.referringLink] = extract(key: AptoBranchKeys.referringLink, from: parameters)
            }
            scope.setContext(value: context, key: Constants.BranchParametersKey)
        }
    }
    
    private static func extract(key: String, from parameters: [AnyHashable: Any]?) -> String {
        return parameters?[key] as? String ?? Constants.EmptyValue
    }
    
    private static func captureSentryError(userInfo: [String: Any], tag: String, value: String) {
        let error = NSError(domain: Constants.ErrorDomain, code: 0, userInfo: userInfo)
        SentrySDK.capture(error: error) { scope in
            scope.setTag(value: value, key: tag)
        }
    }
}
