import Foundation

struct CurrentCardConfig {
    let title: String
    let subtitle: String?
    let icon: UIImage?

    struct Action {
        let title: String
        let action: () -> Void
    }

    let action: Action

    init(title: String, subtitle: String? = nil, icon: UIImage?, action: CurrentCardConfig.Action) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }
}
