import UIKit

final class TransferStatusNavigator: TransferStatusNavigationType {
    
    var onFinish: (() -> Void)?
    
    private weak var from: UIViewController?
    
    init(from: UIViewController?) {
        self.from = from
    }
    
    func close() {
        from?.dismiss(animated: true) { [weak self] in
            self?.onFinish?()
        }
    }
}
