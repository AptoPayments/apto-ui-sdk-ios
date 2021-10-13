@testable import AptoSDK

final class PaymentSourcesStorageFake: PaymentSourcesStorageProtocol {
  func deletePaymentSource(_ apiKey: String, userToken: String, paymentSourceId: String, callback: @escaping Result<Void, NSError>.Callback) {}
  
  func pushFunds(_ apiKey: String, userToken: String, request: PushFundsRequest, callback: @escaping Result<PaymentResult, NSError>.Callback) { }
  
  func addPaymentSource(_ apiKey: String,
                        userToken: String,
                        _ paymentSource: PaymentSourceRequest,
                        callback: @escaping Result<PaymentSource, NSError>.Callback) { }
  
  func getPaymentSources(_ apiKey: String,
                         userToken: String,
                         request: PaginationQuery?,
                         callback: @escaping Result<[PaymentSource], NSError>.Callback) { }
}
