import AptoSDK
import CoreLocation.CLLocation

internal struct TransactionDetailRouter: ShiftCardTransactionDetailsRouterProtocol {
  
  private let screenEvents: TransactionScreenEvents?

  init(screenEvents: TransactionScreenEvents? = nil) {
    self.screenEvents = screenEvents
  }
  
  func backFromTransactionDetails() {
    screenEvents?.onBackButtonPressed?()
  }
  
  func openMapsCenteredIn(latitude: Double, longitude: Double) {
    screenEvents?.onTapOnMapsWithCoordinates?(
      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    )
  }
}
