import UIKit

class BorderedView: UIView {
  
  private var borderWidth: CGFloat?
  
  func set(cornerRadius: CGFloat) {
    layer.cornerRadius = cornerRadius
  }
  
  func set(borderColor: UIColor) {
    layer.borderColor = borderColor.cgColor
  }
  
  func set(borderWidth: CGFloat) {
    self.borderWidth = borderWidth
    layer.borderWidth = borderWidth
  }
  
  func showBorder() {
    layer.borderWidth = borderWidth ?? 1
  }
  
  func hideBorder() {
    layer.borderWidth = 0
  }
}

// MARK: - Error

extension BorderedView {
  func showError() {
    set(borderColor: .red)
    set(borderWidth: 0.5)
    showBorder()
  }
  
  func hideError() {
    set(borderWidth: 1)
    set(borderColor: .colorFromHexString("E9EBEE")!)
  }
}
