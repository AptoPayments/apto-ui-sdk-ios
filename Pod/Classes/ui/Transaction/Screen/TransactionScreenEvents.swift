import CoreLocation.CLLocation

public typealias OnBackButtonPressed = (() -> Void)
public typealias OnTapOnMapsWithCoorindates = ((CLLocationCoordinate2D) -> Void)

public struct TransactionScreenEvents {
    public let onBackButtonPressed: OnBackButtonPressed?
    public let onTapOnMapsWithCoordinates: OnTapOnMapsWithCoorindates?

    public init(onBackButtonPressed: OnBackButtonPressed? = nil,
                onTapOnMapsWithCoordinates: OnTapOnMapsWithCoorindates? = nil)
    {
        self.onBackButtonPressed = onBackButtonPressed
        self.onTapOnMapsWithCoordinates = onTapOnMapsWithCoordinates
    }
}
