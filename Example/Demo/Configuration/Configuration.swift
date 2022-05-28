import AptoSDK

struct Configuration {
    let apiKey: String
    let environment: AptoPlatformEnvironment
    let tokenKey: String
    let tokenBaseUrl: String
}

extension Configuration {
    // ⚠️ Update this values with your own key & environment

    static let `default` = Configuration(
        apiKey: "<< API KEY >>",
        environment: .sandbox,
        tokenKey: "<< TOKEN KEY >>",
        tokenBaseUrl: "<< BASE URL >>"
    )
}
