//
//  P2PTransferViewModel.swift
//  AptoUISDK
//
//  Created by Fabio Cuomo on 23/7/21.
//

import Foundation
import AptoSDK
import PhoneNumberKit

public struct RecipientResult {
    let recipient: CardholderData
    let phone: AptoPhoneNumber?
    let email: String?
}

final class P2PTransferViewModel {
    private let loader: AptoPlatformProtocol
    typealias Observer<T> = (T) -> Void

    var onLoadingStateChange: Observer<Bool>?
    var onErrorRequest: Observer<NSError>?
    var onConfigurationLoaded: Observer<DataPointType>?
    var onRecipientLoadingStateChange: Observer<Bool>?
    var onRecipientFound: Observer<RecipientResult>?
    var onFindRecipientError: Observer<Error>?
    private var allowedCountries: [Country]?
    
    init(loader: AptoPlatformProtocol) {
        self.loader = loader
    }

    // MARK: Public methods
    public func loadConfiguration() {
        onLoadingStateChange?(true)
        loader
            .fetchContextConfiguration(false) { [weak self] result in
                switch result {
                case .success(let config):
                    self?.allowedCountries = config.projectConfiguration.allowedCountries
                    self?.onConfigurationLoaded?(config.projectConfiguration.primaryAuthCredential)
                case .failure(let error):
                    self?.onErrorRequest?(error)
                }
                self?.onLoadingStateChange?(false)
            }
    }
    
    public func isValidPhoneNumber(_ number: String) -> Bool {
        let validator = PhoneNumberKit()
        guard validator.isValidPhoneNumber(number) else { return false }
        do {
            let validator = PhoneNumberKit()
            let phone = try validator.parse(number)
            guard let allowedCountries = allowedCountries else { return true }

            for country in allowedCountries {
                let prefix = validator.countryCode(for: country.isoCode)
                if prefix == phone.countryCode {
                    return true
                }
            }
        } catch {}
        return false
    }
    
    public func isValidEmail(_ email: String) -> Bool {
        let validator = EmailValidator(failReasonMessage: "")
        switch validator.validate(email) {
        case .pass: return true
        default: return false
        }
    }
    
    public func findRecipient(phone: String) {
        do {
            let validator = PhoneNumberKit()
            let phone = try validator.parse(phone)
            let formattedNumber = validator.format(phone, toType: .e164, withPrefix: false)
            let phoneNumber = AptoPhoneNumber(countryCode: Int(truncatingIfNeeded: phone.countryCode), phoneNumber: formattedNumber)
            makeFindRecipientRequest(phone: phoneNumber)
        } catch {
            onErrorRequest?(NSError(domain: "com.aptopayment.aptocard", code: 0, userInfo: ["invalid_phone": "Unexpected invalid phone number"]))
        }
    }

    public func findRecipient(email: String) {
        makeFindRecipientRequest(email: email)
    }
    
    // MARK: Private methods
    private func makeFindRecipientRequest(phone: AptoPhoneNumber? = nil, email: String? = nil) {
        onRecipientLoadingStateChange?(true)
        loader.p2pFindRecipient(phone: phone, email: email) { [weak self] result in
            switch result {
            case .success(let cardholder):
                self?.onRecipientFound?(RecipientResult(recipient: cardholder, phone: phone,email: email))
            case .failure(let error):
                self?.onFindRecipientError?(error)
            }
            self?.onRecipientLoadingStateChange?(false)
        }
    }
}
