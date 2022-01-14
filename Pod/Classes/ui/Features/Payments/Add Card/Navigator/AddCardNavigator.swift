import Foundation

final class AddCardNavigator: AddCardNavigatorType {
    private weak var from: UIViewController?

    init(from: UIViewController) {
        self.from = from
    }

    func close() {
        from?.dismiss(animated: true, completion: nil)
    }
}
