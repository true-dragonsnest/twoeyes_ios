//
//  CVPixelBuffer+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/02/19.
//

import Accelerate
import AVFoundation
import CoreImage
import Foundation

public extension CVPixelBuffer {
    func crop(to rect: CGRect) -> CVPixelBuffer? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }

        let inputImageRowBytes = CVPixelBufferGetBytesPerRow(self)

        let imageChannels = 4
        let startPos = Int(rect.origin.y) * inputImageRowBytes + imageChannels * Int(rect.origin.x)
        let outWidth = UInt(rect.width)
        let outHeight = UInt(rect.height)
        let croppedImageRowBytes = Int(outWidth) * imageChannels

        var inBuffer = vImage_Buffer()
        inBuffer.height = outHeight
        inBuffer.width = outWidth
        inBuffer.rowBytes = inputImageRowBytes

        inBuffer.data = baseAddress + UnsafeMutableRawPointer.Stride(startPos)

        guard let croppedImageBytes = malloc(Int(outHeight) * croppedImageRowBytes) else {
            return nil
        }

        var outBuffer = vImage_Buffer(data: croppedImageBytes, height: outHeight, width: outWidth, rowBytes: croppedImageRowBytes)

        let scaleError = vImageScale_ARGB8888(&inBuffer, &outBuffer, nil, vImage_Flags(0))

        guard scaleError == kvImageNoError else {
            free(croppedImageBytes)
            return nil
        }

        return croppedImageBytes.toCVPixelBuffer(pixelBuffer: self, targetWith: Int(outWidth), targetHeight: Int(outHeight), targetImageRowBytes: croppedImageRowBytes)
    }

    func flip() -> CVPixelBuffer? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }

        let width = UInt(CVPixelBufferGetWidth(self))
        let height = UInt(CVPixelBufferGetHeight(self))
        let inputImageRowBytes = CVPixelBufferGetBytesPerRow(self)
        let outputImageRowBytes = inputImageRowBytes

        var inBuffer = vImage_Buffer(
            data: baseAddress,
            height: height,
            width: width,
            rowBytes: inputImageRowBytes
        )

        guard let targetImageBytes = malloc(Int(height) * outputImageRowBytes) else {
            return nil
        }
        var outBuffer = vImage_Buffer(data: targetImageBytes, height: height, width: width, rowBytes: outputImageRowBytes)

        // See https://developer.apple.com/documentation/accelerate/vimage/vimage_operations/image_reflection for other transformations
        let reflectError = vImageHorizontalReflect_ARGB8888(&inBuffer, &outBuffer, vImage_Flags(0))
        // let reflectError = vImageVerticalReflect_ARGB8888(&inBuffer, &outBuffer, vImage_Flags(0))

        guard reflectError == kvImageNoError else {
            free(targetImageBytes)
            return nil
        }

        return targetImageBytes.toCVPixelBuffer(pixelBuffer: self, targetWith: Int(width), targetHeight: Int(height), targetImageRowBytes: outputImageRowBytes)
    }
}
