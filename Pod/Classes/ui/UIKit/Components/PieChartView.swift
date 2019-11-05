//
// PieChartView.swift
// AptoSDK
//
// Created by Takeichi Kanzaki on 07/01/2019.
//
// This is a custom implementation based on:
// https://github.com/maxday/MDRotatingPieChart
//

import UIKit
import QuartzCore
import CoreGraphics

protocol PieChartViewDataSource {
  /**
   Gets slices separator color
   */
  func separatorColor() -> UIColor
  /**
   Gets slice color
   :param: index slice index in your data array
   :returns: the color of the slice at the given index
  */
  func colorForSlice(at index: Int) -> UIColor
  /**
   Gets selected slice color
   :param: index slice index in your data array
   :returns: the color of the slice at the given index
  */
  func selectedColorForSlice(at index: Int) -> UIColor
  /**
   Gets slice value
   :param: index slice index in your data array
   :returns: the value of the slice at the given index
  */
  func valueForSlice(at index: Int) -> CGFloat
  /**
   Get slice image
   :param: index slice index in your data array
   :returns: UIImage for the slice if any
   */
  func imageForSlice(at index: Int) -> UIImage?
  /**
   Get slice image tint color
   :param: index slice index in your data array
   :returns: tint color for the image in the slice
   */
  func imageTintColorForSlice(at index: Int) -> UIColor
  /**
   Gets number of slices
   :param: index slice index in your data array
   :returns: the number of slices
  */
  func numberOfSlices() -> Int
}

@objc protocol PieChartViewDelegate: class {
  /**
   Triggered when a slice is selected
   :param: index slice index in your data array
  */
  @objc optional func didSelectSlice(at index: Int)
  /**
   Triggered when a slice is deselected
   :param: index slice index in your data array
  */
  @objc optional func didDeselectSlice(at index: Int)
}

class PieChartView: UIControl {
  //donut width
  var donutWidth: CGFloat = 51

  //biggest of both radius
  var bigRadius: CGFloat {
    return frame.height / 2
  }

  //smallest of both radius
  var smallRadius: CGFloat {
    return bigRadius - donutWidth
  }

  //tells whether or not the pie should be animated
  var enableAnimation = true
  //if so, this describes the duration of the animation
  var animationDuration: CFTimeInterval = 0.4

  //stores the slices
  private var slicesArray: [Slice] = []
  private var separatorsArray: [CAShapeLayer] = []

  //data source and delegate
  var dataSource: PieChartViewDataSource! // swiftlint:disable:this implicitly_unwrapped_optional
  weak var delegate: PieChartViewDelegate?

  //saves the selected slice index
  private var selectedIndex: Int = -1
  private var showingEmptyCase: Bool = false

  //center of the pie chart
  private var pieChartCenter: CGPoint {
    return CGPoint(x: bounds.width / 2, y: bounds.height / 2)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setUp()
  }

  /**
   Constructs the pie chart
  */
  func build() {
    guard dataSource != nil else {
      print("Did you forget to set your datasource ?")
      return
    }
    reset()
    let numberOfSlices = dataSource.numberOfSlices()
    guard numberOfSlices > 0 else {
      drawEmptyCase()
      return
    }
    showingEmptyCase = false
    let total = computeTotal()
    var currentStartAngle: CGFloat = 0
    var angleSum: CGFloat = 0
    // Do not show the initial separator if there is only one slice
    if numberOfSlices > 1 {
      let separator = createSeparator(angle: 0, color: dataSource.separatorColor())
      separatorsArray.append(separator)
      layer.insertSublayer(separator, at: 0)
    }
    for index in 0..<numberOfSlices {
      prepareSlice(&angleSum, currentStartAngle: &currentStartAngle, total: total, index: index)
    }
  }

  //UIControl events implementation
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let currentPoint = touch.location(in: self)
    if shouldIgnoreTap(at: currentPoint) {
      return false
    }
    return true
  }

  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    guard let touch = touch else { return }
    let currentPoint = touch.location(in: self)
    var cpt = 0
    for currentPath in slicesArray {
      //click on a slice
      if currentPath.paths.bezierPath.contains(currentPoint) {
        selectDeselectSlice(at: cpt)
        return
      }
      cpt += 1
    }
  }
}

private extension PieChartView {
  func setUp() {
  }

  func reset() {
    selectedIndex = -1
    slicesArray.forEach { $0.shapeLayer.removeFromSuperlayer() }
    separatorsArray.forEach { $0.removeFromSuperlayer() }
    slicesArray.removeAll(keepingCapacity: false)
    separatorsArray.removeAll(keepingCapacity: false)
  }

  func drawEmptyCase() {
    showingEmptyCase = true
    let currentColor = dataSource.colorForSlice(at: 0)
    guard let slice = createSlice(start: 0, end: -2 * CGFloat.pi, color: currentColor, value: 100, percent: 100) else {
      return
    }
    slicesArray.append(slice)
    layer.insertSublayer(slice.shapeLayer, at: 0)
  }

  /**
   Prepares the slice and adds it to the pie chart
   :param: angleSum          sum of already prepared slices
   :param: currentStartAngle start angle
   :param: total             total value of the pie chart
   :param: index             slice index
  */
  func prepareSlice(_ angleSum: inout CGFloat, currentStartAngle: inout CGFloat, total: CGFloat, index: Int) {
    let currentValue = dataSource.valueForSlice(at: index)
    let currentAngle = currentValue * 2 * CGFloat.pi / total
    let currentColor = dataSource.colorForSlice(at: index)
    //create slice
    guard let slice = createSlice(start: currentStartAngle,
                                  end: CGFloat(currentStartAngle - currentAngle),
                                  color: currentColor,
                                  value: currentValue,
                                  percent: 100 * currentValue / total) else {
      return
    }
    slicesArray.append(slice)
    let imageView = createImageView(angleSum: angleSum + slice.angle / 2, slice: slice, index: index)
    //populate slicesArray
    slicesArray[index].imageView = imageView
    if let imageView = imageView {
      slicesArray[index].shapeLayer.addSublayer(imageView.layer)
    }
    angleSum += slice.angle
    layer.insertSublayer(slice.shapeLayer, at: 0)
    let separator = createSeparator(angle: currentStartAngle + slice.angle, color: dataSource.separatorColor())
    separatorsArray.append(separator)
    layer.insertSublayer(separator, at: 0)
    currentStartAngle -= currentAngle
    if enableAnimation {
      addAnimation(slice: slice)
    }
  }

  /**
   Creates a slice
   :param: start   start angle
   :param: end     end angle
   :param: color   color
   :param: value   value
   :param: percent percent value
   :returns: a new slice
  */
  func createSlice(start: CGFloat, end: CGFloat, color: UIColor, value: CGFloat, percent: CGFloat) -> Slice? {
    guard let path = computeDualPath(start: start, end: end) else { return nil }
    let mask = CAShapeLayer()
    mask.frame = bounds
    mask.path = path.animationBezierPath.cgPath
    mask.lineWidth = bigRadius - smallRadius
    let cgColor = color.cgColor
    mask.strokeColor = cgColor
    mask.fillColor = cgColor
    return Slice(paths: path, shapeLayer: mask, angle: end - start, value: value, percent: percent)
  }

  /**
   Computes and returns a pair of UIBezierPaths
   :param: start start angle
   :param: end   end angle
   :returns: the pair
  */
  func computeDualPath(start: CGFloat, end: CGFloat) -> DualPath? {
    let pathRef = computeAnimationPath(start: start, end: end)
    guard let copy = pathRef.cgPath.mutableCopy() else { return nil }
    let other = copy.copy(strokingWithWidth: bigRadius - smallRadius,
                          lineCap: CGLineCap.butt,
                          lineJoin: CGLineJoin.miter,
                          miterLimit: 1)
    return DualPath(bezierPath: UIBezierPath(cgPath: other), animationBezierPath: pathRef)
  }

  func createSeparator(angle: CGFloat, color: UIColor) -> CAShapeLayer {
    let path = UIBezierPath()
    path.move(to: CGPoint(x: cos(angle) * smallRadius + pieChartCenter.x,
                          y: sin(angle) * smallRadius + pieChartCenter.y))
    path.addLine(to: CGPoint(x: cos(angle) * bigRadius + pieChartCenter.x,
                             y: sin(angle) * bigRadius + pieChartCenter.y))
    path.close()
    let separator = CAShapeLayer()
    separator.frame = bounds
    separator.path = path.cgPath
    separator.lineWidth = 1
    let cgColor = color.cgColor
    separator.strokeColor = cgColor
    separator.fillColor = cgColor
    return separator
  }

  /**
   Retrieves the middle point of a slice
   :param: angleSum sum of already prepared slices
   :returns: the middle point
  */
  func getMiddlePoint(_ angleSum: CGFloat) -> CGPoint {
    let middleRadiusX = smallRadius + (bigRadius - smallRadius) / 2
    let middleRadiusY = smallRadius + (bigRadius - smallRadius) / 2
    return CGPoint(x: cos(angleSum) * middleRadiusX + pieChartCenter.x,
                   y: sin(angleSum) * middleRadiusY + pieChartCenter.y)
  }

  /**
  Creates the image view for the slice
  :param: angleSum sum of already prepared slices
  :param: slice    the slice
  :index: index    slice index
  :returns: a new label
  */
  func createImageView(angleSum: CGFloat, slice: Slice, index: Int) -> UIImageView? {
    guard let image = dataSource.imageForSlice(at: index) else { return nil }
    let imageView = UIImageView(image: image.asTemplate())
    imageView.tintColor = dataSource.imageTintColorForSlice(at: index)
    imageView.center = getMiddlePoint(angleSum)
    imageView.isHidden = !frameFitInPath(frame: imageView.frame, path: slice.paths.bezierPath, inside: true)
    return imageView
  }

  func addAnimation(slice: Slice) {
    let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
    animateStrokeEnd.duration = animationDuration
    animateStrokeEnd.fromValue = 0.0
    animateStrokeEnd.toValue = 1.0
    slice.shapeLayer.add(animateStrokeEnd, forKey: "animate stroke end animation")
    CATransaction.commit()
  }

  /**
   Computes the total value of slices
   :returns: the total value
  */
  func computeTotal() -> CGFloat {
    var total: CGFloat = 0
    for index in 0..<dataSource.numberOfSlices() {
      total += dataSource.valueForSlice(at: index)
    }
    return total
  }

  func selectDeselectSlice(at index: Int) {
    // no slice selected
    if selectedIndex == -1 {
      selectSlice(at: index)
    }
    else {
      deselectCurrentSlice()
      // if the tapped slice is the previously selected do nothing, otherwise select the new slice
      if selectedIndex == index {
        selectedIndex = -1
      }
      else {
        selectSlice(at: index)
      }
    }
  }

  func deselectCurrentSlice() {
    guard selectedIndex >= 0 else { return }
    updateLayer(at: selectedIndex,
                color: dataSource.colorForSlice(at: selectedIndex),
                tintColor: dataSource.imageTintColorForSlice(at: selectedIndex))
    delegate?.didDeselectSlice?(at: selectedIndex)
  }

  func selectSlice(at index: Int) {
    guard !showingEmptyCase else { return }
    let color = dataSource.selectedColorForSlice(at: index)
    updateLayer(at: index, color: color, tintColor: .white)
    delegate?.didSelectSlice?(at: index)
    selectedIndex = index
  }

  func updateLayer(at index: Int, color: UIColor, tintColor: UIColor) {
    let slice: Slice = slicesArray[index]
    slice.imageView?.tintColor = tintColor
    if let layer = layer.sublayers?.first(where: { $0 == slice.shapeLayer }),
       let shape = layer.model() as? CAShapeLayer {
      shape.strokeColor = color.cgColor
    }
  }

  func shouldIgnoreTap(at currentPoint: CGPoint) -> Bool {
    let deltaX = currentPoint.x - pieChartCenter.x
    let deltaY = currentPoint.y - pieChartCenter.y
    let sqrRoot = sqrt(deltaX * deltaX + deltaY * deltaY)
    return sqrRoot < smallRadius || sqrRoot > (bigRadius + (bigRadius - smallRadius) / 2)
  }

  /**
   Computes and returns a path representing a slice
   :param: start start angle
   :param: end   end angle
   :returns: the UIBezierPath build
  */
  func computeAnimationPath(start: CGFloat, end: CGFloat) -> UIBezierPath {
    let radius = smallRadius + (bigRadius - smallRadius) / 2
    let animationPath = UIBezierPath()
    animationPath.move(to: getMiddlePoint(start))
    animationPath.addArc(withCenter: pieChartCenter, radius: radius, startAngle: start, endAngle: end, clockwise: false)
    animationPath.addArc(withCenter: pieChartCenter, radius: radius, startAngle: end, endAngle: start, clockwise: true)
    return animationPath
  }

  /**
   Tells whether or not the given frame is overlapping with a shape (delimited by an UIBezierPath)
   :param: frame  the frame
   :param: path   the path
   :param: inside tells whether or not the path should be inside the path
   :returns: true if it fits, false otherwise
  */
  func frameFitInPath(frame: CGRect, path: UIBezierPath, inside: Bool) -> Bool {
    let topLeftPoint = frame.origin
    let topRightPoint = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y)
    let bottomLeftPoint = CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)
    let bottomRightPoint = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height)
    if inside {
      if !path.contains(topLeftPoint)
           || !path.contains(topRightPoint)
           || !path.contains(bottomLeftPoint)
           || !path.contains(bottomRightPoint) {
        return false
      }
    }
    else {
      if path.contains(topLeftPoint)
           || path.contains(topRightPoint)
           || path.contains(bottomLeftPoint)
           || path.contains(bottomRightPoint) {
        return false
      }
    }
    return true
  }
}

/**
 *  Stores both BezierPaths, one for the animation and the "real one"
 */
private struct DualPath {
  let bezierPath: UIBezierPath
  let animationBezierPath: UIBezierPath
}

/**
 *  Stores a slice
 */
private struct Slice {
  let paths: DualPath
  let shapeLayer: CAShapeLayer
  let angle: CGFloat
  let value: CGFloat
  var imageView: UIImageView?
  let percent: CGFloat

  init(paths: DualPath, shapeLayer: CAShapeLayer, angle: CGFloat, value: CGFloat, percent: CGFloat) {
    self.paths = paths
    self.shapeLayer = shapeLayer
    self.angle = angle
    self.value = value
    self.percent = percent
  }
}
