//
//  UIImage.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/02/16.
//
//

import AptoSDK
import Foundation

class PodBundle: Bundle {
    public static func bundle() -> Bundle {
        return Bundle(for: classForCoder())
    }
}

extension UIImage {
    static func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage! // swiftlint:disable:this force_unwrapping
    }

    static func imageFromPodBundle(_ imageName: String) -> UIImage? {
        let themeImage = UIImage(named: "theme_2\(imageName)", in: PodBundle.bundle(), compatibleWith: nil)
        let regularImage = UIImage(named: imageName, in: PodBundle.bundle(), compatibleWith: nil)
        return themeImage ?? regularImage
    }

    func asTemplate() -> UIImage {
        return withRenderingMode(.alwaysTemplate)
    }

    func imageRotatedByDegrees(_ degrees: CGFloat) -> UIImage {
        let radians = degrees * CGFloat(Double.pi) / 180

        var newSize = CGRect(origin: CGPoint.zero,
                             size: size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, true, scale)
        let context = UIGraphicsGetCurrentContext()! // swiftlint:disable:this force_unwrapping

        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))

        draw(in: CGRect(x: -size.width / 2,
                        y: -size.height / 2,
                        width: size.width,
                        height: size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage! // swiftlint:disable:this force_unwrapping
    }

    func crop(cropRect: CGRect) -> UIImage {
        let croppedCGImage: CGImage = (cgImage?.cropping(to: cropRect))! // swiftlint:disable:this force_unwrapping
        return UIImage(cgImage: croppedCGImage)
    }

    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
