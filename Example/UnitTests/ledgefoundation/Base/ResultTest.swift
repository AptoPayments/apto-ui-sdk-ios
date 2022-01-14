//
// ResultTest.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 08/07/2019.
//

@testable import AptoSDK
import XCTest

class ResultTest: XCTestCase {
    private lazy var successValue = "Success"
    private lazy var successSut = Result<String, Error>.success("Success")
    private lazy var failureValue = BackendError(code: .other)
    private lazy var failureSut = Result<String, Error>.failure(BackendError(code: .other))

    func testSuccessValueReturnSuccessAssociatedValue() {
        // When
        let value = successSut.value

        // Then
        XCTAssertEqual(successValue, value)
    }

    func testFailureValueReturnNil() {
        // When
        let value = failureSut.value

        // Then
        XCTAssertNil(value)
    }

    func testSuccessErrorReturnNil() {
        // When
        let error = successSut.error

        // Then
        XCTAssertNil(error)
    }

    func testFailureErrorReturnAssociatedError() {
        // When
        let error = failureSut.error

        // Then
        XCTAssertEqual(failureValue.code, (error as! BackendError).code) // swiftlint:disable:this force_cast
    }

    func testSuccessIsSuccessReturnTrue() {
        // When
        let isSuccess = successSut.isSuccess

        // Then
        XCTAssertTrue(isSuccess)
    }

    func testFailureIsSuccessReturnFalse() {
        // When
        let isSuccess = failureSut.isSuccess

        // Then
        XCTAssertFalse(isSuccess)
    }

    func testSuccessIsFailureReturnFalse() {
        // When
        let isFailure = successSut.isFailure

        // Then
        XCTAssertFalse(isFailure)
    }

    func testFailureIsFailureReturnTrue() {
        // When
        let isFailure = failureSut.isFailure

        // Then
        XCTAssertTrue(isFailure)
    }
}
