import AptoSDK
import Branch
import UIKit

public enum AptoBranchKeys {
    static let apiKey = "APTO_API_KEY"
    static let environment = "APTO_ENVIRONMENT"
    static let referringLink = "~referring_link"
    static let clickedLink = "+clicked_branch_link"
}

struct ConfigurationResolver {
    private let branch: Branch
    private let userDefaults: UserDefaults

    init(branch: Branch = .getInstance(),
         userDefaults: UserDefaults = .standard)
    {
        self.branch = branch
        self.userDefaults = userDefaults
    }

    func resolve(
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
        _ completion: @escaping (Configuration) -> Void
    ) {
        if TestEnvironment.isRunningTests() {
            completion(.default)
            return
        }

        branch.initSession(launchOptions: launchOptions) { parameters, _ in
            guard let clickedLink = parameters?[AptoBranchKeys.clickedLink] as? Bool, clickedLink else {
                completion(self.storedConfiguration ?? .default)
                return
            }
            completion(self.extractConfiguration(from: parameters))
        }
    }

    private func extractConfiguration(from parameters: [AnyHashable: Any]?) -> Configuration {
        SentryLoggerHelper.logBranch(parameters, storedConfiguration: storedConfiguration)
        guard let parameters = parameters,
              let apiKey = parameters[AptoBranchKeys.apiKey] as? String,
              let environment = parameters[AptoBranchKeys.environment] as? String
        else {
            return storedConfiguration ?? .default
        }
        let configuration = Configuration(apiKey: apiKey, environment: extract(from: environment))
        store(configuration)
        return configuration
    }

    private func extract(from environment: String) -> AptoPlatformEnvironment {
        switch environment.uppercased() {
        case "PRD":
            return .production
        case "STG":
            return .staging
        default:
            return .sandbox
        }
    }

    // MARK: - Store configuration

    func store(_ configuration: Configuration) {
        userDefaults.set(configuration.apiKey, forKey: AptoBranchKeys.apiKey)
        userDefaults.set(configuration.environment.rawValue, forKey: AptoBranchKeys.environment)
    }

    private var storedConfiguration: Configuration? {
        guard let apiKey = userDefaults.string(forKey: AptoBranchKeys.apiKey) else { return nil }
        let storedEnvironment = userDefaults.integer(forKey: AptoBranchKeys.environment)
        let environment = AptoPlatformEnvironment(rawValue: storedEnvironment) ?? AptoPlatformEnvironment.sandbox
        return Configuration(apiKey: apiKey, environment: environment)
    }
}
