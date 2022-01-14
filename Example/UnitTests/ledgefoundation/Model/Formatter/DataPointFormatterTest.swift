@testable import AptoSDK
import XCTest

final class DataPointFormatterTest: XCTestCase {
    func test_phone_data_point_formatter() {
        let phoneFormatter = PhoneFormatter(dataPoint: PhoneNumber(countryCode: 34, phoneNumber: "603018451", verified: true))
        XCTAssertEqual("+34 603 01 84 51", phoneFormatter.titleValues.first?.value)
    }

    func test_name_data_point_formatter() {
        let personNameFormatter = PersonalNameFormatter(dataPoint: PersonalName(firstName: "Sponge", lastName: "Bob"))
        XCTAssertEqual("Sponge", personNameFormatter.titleValues.first?.value)
    }

    func test_address_data_point_formatter() {
        let addressFormatter = AddressFormatter(dataPoint: Address(address: "Hollywood Avenue", apUnit: "10", country: Country(isoCode: "US"), city: "Los Angeles", region: "California", zip: "00154"))

        XCTAssertEqual("Hollywood Avenue, 10, Los Angeles, California, 00154, United States", addressFormatter.titleValues.first?.value)
    }

    func test_birth_date_formatter() {
        let dateComponents = DateComponents(calendar: .current, year: 1992, month: 11, day: 20)
        let birthDateFormatter = BirthDateFormatter(dataPoint: BirthDate(date: dateComponents.date))
        XCTAssertEqual("November 20, 1992", birthDateFormatter.titleValues.first?.value)
    }

    func test_id_document_formatter() {
        let idDocument = IdDocumentFormatter(dataPoint: IdDocument(documentType: .identityCard, value: "X8569854N", country: Country(isoCode: "ES")))
        XCTAssertEqual("X8569854N", idDocument.titleValues.first?.value)
    }

    func test_ssn_document_formatter() {
        let idDocument = IdDocumentFormatter(dataPoint: IdDocument(documentType: .ssn, value: "001-00-34NH", country: Country(isoCode: "US")))
        XCTAssertEqual("001-00-34NH", idDocument.titleValues.first?.value)
    }
}
