import Foundation
 
struct TransferStatusItem {
  let title: String?
  let subtitle: String?
  let icon: UIImage?

  init(title: String?, subtitle: String?, icon: UIImage? = nil) {
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
  }
}
