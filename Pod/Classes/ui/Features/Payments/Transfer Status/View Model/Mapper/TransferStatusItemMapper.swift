import Foundation
import AptoSDK

struct TransferStatusItemMapper {
    
  private let paymentSourceMapper: PaymentSourceMapper
  
  init(paymentSourceMapper: PaymentSourceMapper = .init()) {
    self.paymentSourceMapper = paymentSourceMapper
  }
  
  func map(paymentResult: PaymentResult, paymentSource: PaymentSource) -> [TransferStatusItem] {
    let paymentSourceItem = paymentSourceMapper.map(paymentSource, action: nil)
    
    return [
      TransferStatusItem(title: "load_funds.transaction.status.title".podLocalized(), subtitle: paymentResult.status.rawValue.capitalized),
      TransferStatusItem(title: "load_funds.transaction.time".podLocalized(), subtitle: self.format(paymentResult.createdAt)),
      TransferStatusItem(title: "load_funds.transaction.from".podLocalized(), subtitle: paymentSourceItem.title, icon: paymentSourceItem.icon),
      TransferStatusItem(title: "load_funds.transaction.authorization".podLocalized(), subtitle: paymentResult.id)
    ]
  }

  private func format(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
    return dateFormatter.string(from: date)
  }
}
