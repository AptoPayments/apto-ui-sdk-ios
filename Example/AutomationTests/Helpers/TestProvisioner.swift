//
//  TestProvisioner.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 18/08/2017.
//

import Alamofire
import Alamofire_Synchronous
import AptoSDK
import Foundation
import SwiftyJSON

class TestProvisioner {
    static let apiBaseURL = "https://dev.ledge.me"
    static let apiKey = "iNn5MxxgDnKyFZ4tFNYKGBtAOKHxlTkI0Ob7wca+s2EXaqhBGzQRyT/T/S0nELdx"
    static let adminUserKey = "F0b6IfLrSpJq2/G3sWzZ5/jlGRQnfcKXK+Ll1S11AyFmDaDB9cBqfqvoU2TJeYP9jd/ytwTFwl0/IqhMUJi/2d5hPgorg0aSrnqaHF3aWG4="

    // MARK: - Provisioning

    func provisionTeam(name: String) -> JSON? {
        let payload: [String: Any] = [
            "name": name,
            "isolated_team": true,
            "isolated_project": false,
        ]
        let result = post("/v1/dashboard/teams",
                          parameters: payload,
                          headers: buildRequestHeaders())

        switch result {
        case let .failure(error):
            print(error)
            return nil
        case let .success(json):
            return json
        }
    }

    func provisionProject(teamId: String,
                          name: String) -> JSON?
    {
        let payload: [String: Any] = [
            "name": name,
            "isolated_project": false,
        ]
        let result = post("/v1/dashboard/teams/" + teamId + "/projects",
                          parameters: payload,
                          headers: buildRequestHeaders())

        switch result {
        case let .failure(error):
            print(error)
            return nil
        case let .success(json):
            return json
        }
    }

    func provisionRandomTestUser(teamKey: String? = nil,
                                 projectKey: String? = nil,
                                 countryCode: Int = 1,
                                 phoneNumber: String = "9366669999",
                                 email: String = "test@aptopayments.com",
                                 verifiedPhone: Bool = false) -> JSON?
    {
        return provisionUserWith(teamKey: teamKey,
                                 projectKey: projectKey,
                                 firstName: "Test",
                                 lastName: "User",
                                 email: email,
                                 countryCode: countryCode,
                                 phoneNumber: phoneNumber,
                                 verifiedPhone: verifiedPhone)
    }

    func provisionUserWith(teamKey: String? = nil,
                           projectKey: String? = nil,
                           firstName: String,
                           lastName: String,
                           email: String,
                           countryCode: Int,
                           phoneNumber: String,
                           verifiedPhone: Bool = false,
                           verifiedEmail: Bool = false) -> JSON?
    {
        var phoneDatapoint: [String: Any] = [
            "data_type": "phone",
            "country_code": countryCode,
            "phone_number": phoneNumber,
        ]
        if verifiedPhone {
            let phoneVerification = provisionPhoneVerificationWith(countryCode: countryCode, phoneNumber: phoneNumber)
            phoneDatapoint["verification"] = [
                "verification_id": phoneVerification?["verification_id"].string,
                "secret": phoneVerification?["secret"].string,
            ]
        }

        var emailDatapoint: [String: Any] = [
            "data_type": "email",
            "email": email,
        ]
        if verifiedEmail {
            let emailVerification = provisionEmailVerificationWith(email: email)
            emailDatapoint["verification"] = [
                "verification_id": emailVerification?["verification_id"].string,
                "secret": emailVerification?["secret"].string,
            ]
        }

        let payload: [String: Any] = [
            "data_points": [
                "data": [
                    ["data_type": "name", "first_name": firstName, "last_name": lastName],
                    phoneDatapoint,
                    emailDatapoint,
                ],
                "type": "list",
            ],
        ]

        let result = post("/v1/user",
                          parameters: payload,
                          headers: buildRequestHeaders(teamApiKey: teamKey, projectKey: projectKey))

        switch result {
        case let .failure(error):
            print(error)
            return nil
        case let .success(json):
            return json
        }
    }

    // MARK: - Verifications

    func provisionPhoneVerificationWith(countryCode: Int,
                                        phoneNumber: String,
                                        verified: Bool = true) -> JSON?
    {
        let payload: [String: Any] = [
            "country_code": countryCode,
            "phone_number": phoneNumber,
            "show_verification_secret": true,
        ]

        let result = post("/v1/verifications/phone",
                          parameters: payload,
                          headers: buildRequestHeaders())

        switch result {
        case let .failure(error):
            print(error)
            return nil
        case var .success(json):
            if verified {
                var verification = finishVerificationWith(verificationId: json["verification_id"].string!,
                                                          secret: json["secret"].string!)
                verification?["secret"] = json["secret"]
                return verification
            } else {
                return json
            }
        }
    }

    func provisionEmailVerificationWith(email: String,
                                        verified: Bool = true) -> JSON?
    {
        let payload: [String: Any] = [
            "email": email,
            "show_verification_secret": true,
        ]

        let result = post("/v1/verifications/email",
                          parameters: payload,
                          headers: buildRequestHeaders())

        switch result {
        case let .failure(error):
            print(error)
            return nil
        case var .success(json):
            if verified {
                var verification = finishVerificationWith(verificationId: json["verification_id"].string!,
                                                          secret: json["secret"].string!)
                verification?["secret"] = json["secret"]
                return verification
            } else {
                return json
            }
        }
    }

    func finishVerificationWith(verificationId: String,
                                secret: String) -> JSON?
    {
        let payload: [String: Any] = [
            "verification_id": verificationId,
            "secret": secret,
        ]
        let result = post("/v1/verifications/finish",
                          parameters: payload,
                          headers: buildRequestHeaders())
        switch result {
        case let .failure(error):
            print(error)
            return nil
        case let .success(json):
            return json
        }
    }

    // MARK: - Get Info

    func getKeys(teamId: String, projectId: String) -> JSON? {
        let result = get("/v1/dashboard/teams/" + teamId + "/projects/" + projectId + "/keys",
                         headers: buildRequestHeaders())

        switch result {
        case let .failure(error):
            print(error)
            return nil
        case let .success(json):
            return json
        }
    } // end getKeys

    // MARK: - Deleting

    func deleteTeam(teamId: String) {
        _ = delete("/v1/dashboard/teams/" + teamId,
                   parameters: nil,
                   headers: buildRequestHeaders())
    }

    func deleteProject(teamId: String,
                       projectId: String)
    {
        _ = delete("/v1/dashboard/teams/" + teamId + "/projects/" + projectId,
                   parameters: nil,
                   headers: buildRequestHeaders())
    }

    @discardableResult func deleteUserWith(countryCode: Int,
                                           phoneNumber: String) -> JSON?
    {
        let payload: [String: Any] = [
            "phone_number": phoneNumber,
            "country_code": countryCode,
        ]
        let result = post("/v1/dashboard/users/deletebyphone",
                          parameters: payload,
                          headers: buildRequestHeaders())
        switch result {
        case let .failure(error):
            print(error)
            return nil
        case let .success(json):
            return json
        }
    }
}

extension TestProvisioner {
    func countryCodeOf(_ user: JSON) -> Int? {
        if let dataPoint = userDataPoint(user: user, datapointType: "phone") {
            return dataPoint["country_code"].int
        }
        return nil
    }

    func phoneNumberOf(_ user: JSON) -> String? {
        if let dataPoint = userDataPoint(user: user, datapointType: "phone") {
            return dataPoint["phone_number"].string
        }
        return nil
    }

    func emailOf(_ user: JSON) -> String? {
        if let dataPoint = userDataPoint(user: user, datapointType: "email") {
            return dataPoint["email"].string
        }
        return nil
    }

    func firstNameOf(_ user: JSON) -> String? {
        if let dataPoint = userDataPoint(user: user, datapointType: "name") {
            return dataPoint["first_name"].string
        }
        return nil
    }

    func lastNameOf(_ user: JSON) -> String? {
        if let dataPoint = userDataPoint(user: user, datapointType: "name") {
            return dataPoint["last_name"].string
        }
        return nil
    }

    private func userDataPoint(user: JSON, datapointType: String) -> JSON? {
        for dataPoint in user["user_data"]["data"].array! {
            if dataPoint["type"].string == datapointType {
                return dataPoint
            }
        }
        return nil
    }
}

extension TestProvisioner {
    private func get(
        _ url: String,
        baseURL: String = TestProvisioner.apiBaseURL,
        headers: [String: String]
    )
        -> AptoSDK.Result<JSON, NSError>
    {
        var headers = headers
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        let response = Alamofire
            .request(baseURL + url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .responseJSON()
        if let error = response.error {
            return .failure(error as NSError)
        } else {
            return .success(JSON(response.result.value ?? ""))
        }
    }

    private func post(
        _ url: String,
        baseURL: String = TestProvisioner.apiBaseURL,
        parameters: [String: Any]?,
        headers: [String: String]
    )
        -> AptoSDK.Result<JSON, NSError>
    {
        var headers = headers
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        let response = Alamofire
            .request(baseURL + url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON()
        if let error = response.error {
            return .failure(error as NSError)
        } else {
            return .success(JSON(response.result.value ?? ""))
        }
    }

    private func put(
        _ url: String,
        baseURL: String = TestProvisioner.apiBaseURL,
        parameters: [String: Any]?,
        headers: [String: String]
    )
        -> AptoSDK.Result<JSON, NSError>
    {
        var headers = headers
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        let response = Alamofire
            .request(baseURL + url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON()
        if let error = response.error {
            return .failure(error as NSError)
        } else {
            return .success(JSON(response.result.value ?? ""))
        }
    }

    private func delete(
        _ url: String,
        baseURL: String = TestProvisioner.apiBaseURL,
        parameters: [String: Any]?,
        headers: [String: String]
    )
        -> AptoSDK.Result<JSON, NSError>
    {
        var headers = headers
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        let response = Alamofire
            .request(baseURL + url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON()
        if let error = response.error {
            return .failure(error as NSError)
        } else {
            return .success(JSON(response.result.value ?? ""))
        }
    }

    func buildRequestHeaders(apiKey: String? = nil, userKey: String = TestProvisioner.adminUserKey) -> [String: String] {
        return [
            "X-Api-Version": "1.0",
            "X-Device": "Chome/BogusUA/0.0.1",
            "X-Device-Version": "blah",
            "Api-Key": "Bearer " + (apiKey ?? TestProvisioner.apiKey),
            "Authorization": "Bearer " + userKey,
        ]
    }
}
