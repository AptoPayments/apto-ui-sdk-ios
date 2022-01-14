import AptoSDK

public struct CardViewOptions {
    public let uiConfig: UIConfig
    public let cardStyle: CardStyle?

    public init(uiConfig: UIConfig = .default, cardStyle: CardStyle? = nil) {
        self.uiConfig = uiConfig
        self.cardStyle = cardStyle
    }
}
