@testable import AptoSDK

final class PaymentSourcesStorageFake: PaymentSourcesStorageProtocol {
    func deletePaymentSource(_: String, userToken _: String, paymentSourceId _: String, callback _: @escaping Result<Void, NSError>.Callback) {}

    func pushFunds(_: String, userToken _: String, request _: PushFundsRequest, callback _: @escaping Result<PaymentResult, NSError>.Callback) {}

    func addPaymentSource(_: String,
                          userToken _: String,
                          _: PaymentSourceRequest,
                          callback _: @escaping Result<PaymentSource, NSError>.Callback) {}

    func getPaymentSources(_: String,
                           userToken _: String,
                           request _: PaginationQuery?,
                           callback _: @escaping Result<[PaymentSource], NSError>.Callback) {}
}
