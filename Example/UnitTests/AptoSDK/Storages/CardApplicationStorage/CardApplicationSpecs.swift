//
//  CardApplicationSpec.swift
//  UnitTests
//
//  Created by Fabio Cuomo on 26/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

protocol CardApplicationSpecs {
    // MARK: createApplication tests
    func test_createApplication_postDataToURL()
    func test_createApplication_postDataToURLTwice()
    func test_createApplication_deliversErrorOnClientErrors()
    func test_createApplication_deliversNewApplicationOnValidJSONResponse()
    
    // MARK: applicationStatus tests
    func test_applicationStatus_getDataFromURL()
    func test_applicationStatusTwice_getDataFromURLTwice()
    func test_applicationStatus_deliversErrorOnClientErrors()
    func test_applicationStatus_deliversApplicationOnValidJSONResponse()

    // MARK: setBalanceStore tests
    func test_setBalanceStore_postDataToURL()
    func test_setBalanceStore_postDataToURLTwice()
    func test_setBalanceStore_deliversErrorOnClientErrors()
    func test_setBalanceStore_deliversNewApplicationOnValidJSONResponse()

    // MARK: acceptDisclaimer tests
    func test_acceptDisclaimer_postDataToURL()
    func test_acceptDisclaimer_postDataToURLTwice()
    func test_acceptDisclaimer_deliversErrorOnClientErrors()
    func test_acceptDisclaimer_deliversSuccessOnValidJSONResponse()

    // MARK: cancelCardApplication tests
    func test_cancelCardApplication_deleteDataFromURL()
    func test_cancelCardApplication_deleteDataFromURLTwice()
    func test_cancelCardApplication_deliversErrorOnClientErrors()
    func test_cancelCardApplication_deliversNewApplicationOnValidJSONResponse()

    // MARK: issueCard tests
    func test_init_doesNotRequestDataFromURL()
    func test_issueCard_postDataToURL()
    func test_issueCardTwice_postDataToURLTwice()
    func test_issueCard_deliversErrorOnClientErrors()
    func test_issueCard_deliversNewCardOnValidJSONResponse()
}
