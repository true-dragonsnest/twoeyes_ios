//
//  UIImage+.swift
//  Nest1
//
//  Created by Yongsik Kim on 2021/11/22.
//

import UIKit

// MARK: - aspect things

public extension UIImage {
    func resizeAspectFill(into targetSize: CGSize, cropToCenter: Bool = false) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = max(widthRatio, heightRatio)
        let scaledImageSize = CGSize(width: floor(size.width * scaleFactor), height: floor(size.height * scaleFactor))

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        if cropToCenter {
            return scaledImage.cropToCenter()
        }
        return scaledImage
    }

    func cropToCenter() -> UIImage? {
        let sideLength = min(size.width, size.height) * scale
        let xOffset = (size.width * scale - sideLength) / 2.0
        let yOffset = (size.height * scale - sideLength) / 2.0
        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength).integral

        guard let croppedCGImage = cgImage?.cropping(to: cropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: imageRendererFormat.scale, orientation: imageOrientation)
    }
    
    func fixOrientation() -> UIImage {
        guard let cgImage, let colorSpace = cgImage.colorSpace else { return self }
        if imageOrientation == .up { return self }
        
        var transform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -(.pi / 2))
        default: break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default: break
        }
        
        if let ctx = CGContext(data: nil,
                               width: Int(size.width),
                               height: Int(size.height),
                               bitsPerComponent: cgImage.bitsPerComponent,
                               bytesPerRow: 0,
                               space: colorSpace,
                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        {
            ctx.concatenate(transform)
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
            if let finalImage = ctx.makeImage() {
                return UIImage(cgImage: finalImage)
            }
        }
        
        return self
    }
}

// MARK: - heic
import AVFoundation

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}

public extension UIImage {
    var isHeicSupported: Bool {
        (CGImageDestinationCopyTypeIdentifiers() as? [String])?.contains((AVFileType.heic as CFString) as String) ?? false
    }
    
    var cgImageOrientation: CGImagePropertyOrientation { .init(imageOrientation) }
    
    var heic: Data? { heic() }
    func heic(compression: CGFloat = 0.8) -> Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, AVFileType.heic as CFString, 1, nil),
              let cgImage
        else {
            "UIImage \(self) cannot converted into HEIC CGImage, check image source or device".le()
            return nil
        }
        CGImageDestinationAddImage(destination,
                                   cgImage,
                                   [kCGImageDestinationLossyCompressionQuality: compression,
                                                   kCGImagePropertyOrientation: cgImageOrientation.rawValue] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}

// MARK: - stroke around image

public extension UIImage {
    /**
     Returns the flat colorized version of the image, or self when something was wrong

     - Parameters:
         - color: The colors to user. By defaut, uses the ``UIColor.white`

     - Returns: the flat colorized version of the image, or the self if something was wrong
     */
    func colorized(with color: UIColor = .white) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        defer {
            UIGraphicsEndImageContext()
        }

        guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        color.setFill()
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.clip(to: rect, mask: cgImage)
        context.fill(rect)

        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }

        return colored
    }

    /**
     Returns the stroked version of the fransparent image with the given stroke color and the thickness.

     - Parameters:
         - color: The colors to user. By defaut, uses the ``UIColor.white`
         - thickness: the thickness of the border. Default to `2`
         - quality: The number of degrees (out of 360): the smaller the best, but the slower. Defaults to `10`.

     - Returns: the stroked version of the image, or self if something was wrong
     */

    func stroked(with color: UIColor = .white, thickness: CGFloat = 2, quality: CGFloat = 10) -> UIImage {
        guard let cgImage = cgImage else { return self }

        // Colorize the stroke image to reflect border color
        let strokeImage = colorized(with: color)

        guard let strokeCGImage = strokeImage.cgImage else { return self }

        /// Rendering quality of the stroke
        let step = quality == 0 ? 10 : abs(quality)

        let oldRect = CGRect(x: thickness, y: thickness, width: size.width, height: size.height).integral
        let newSize = CGSize(width: size.width + 2 * thickness, height: size.height + 2 * thickness)
        let translationVector = CGPoint(x: thickness, y: 0)

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)

        guard let context = UIGraphicsGetCurrentContext() else { return self }

        defer {
            UIGraphicsEndImageContext()
        }
        context.translateBy(x: 0, y: newSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.interpolationQuality = .high

        for angle: CGFloat in stride(from: 0, to: 360, by: step) {
            let vector = translationVector.rotated(around: .zero, byDegrees: angle)
            let transform = CGAffineTransform(translationX: vector.x, y: vector.y)

            context.concatenate(transform)

            context.draw(strokeCGImage, in: oldRect)

            let resetTransform = CGAffineTransform(translationX: -vector.x, y: -vector.y)
            context.concatenate(resetTransform)
        }

        context.draw(cgImage, in: oldRect)

        guard let stroked = UIGraphicsGetImageFromCurrentImageContext() else { return self }

        return stroked
    }
}

extension CGPoint {
    /**
     Rotates the point from the center `origin` by `byDegrees` degrees along the Z axis.

     - Parameters:
         - origin: The center of he rotation;
         - byDegrees: Amount of degrees to rotate around the Z axis.

     - Returns: The rotated point.
     */
    func rotated(around origin: CGPoint, byDegrees: CGFloat) -> CGPoint {
        let dx = x - origin.x
        let dy = y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + byDegrees * .pi / 180.0 // to radians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
}
