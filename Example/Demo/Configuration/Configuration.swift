import AptoSDK

struct Configuration {
  let apiKey: String
  let environment: AptoPlatformEnvironment
}

extension Configuration {
  // ⚠️ Update this values with your own key & environment
  
  static let `default` = Configuration(
    apiKey: "<< API KEY >>",
    environment: .sandbox
  )
}
