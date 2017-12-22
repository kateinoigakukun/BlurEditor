//
//  CGImage+Extension.swift
//  BlurEditor
//
//  Created by SaitoYuta on 2017/12/19.
//  Copyright © 2017年 bangohan. All rights reserved.
//

import Accelerate
import CoreGraphics

extension CGImage {

    // Gaussian blur
    // https://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement

    func blurred(blurRadius: CGFloat, scale: CGFloat) -> CGImage? {

        let bytes: Int = bytesPerRow * height
        guard let providerData = dataProvider?.data else { return nil }

        let inputRadius: Float = Float(scale * blurRadius)

        // For build performance
        let three: Float = 3
        let two: Float = 2
        let four: Float = 4
        let oneHalf: Float = 0.5

        var radius: UInt32 = UInt32(floor((inputRadius * three * sqrt(two * Float.pi) / four + oneHalf) / two))
        if radius % 2 == 0 { radius += 1 }

        let inData = malloc(bytes)
        var inBuffer = vImage_Buffer.init(data: inData, height: .init(height), width: .init(width), rowBytes: bytesPerRow)

        let outData = malloc(bytes)
        var outBuffer = vImage_Buffer.init(data: outData, height: .init(height), width: .init(width), rowBytes: bytesPerRow)

        let tempSize = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend + kvImageGetTempBufferSize))
        let tempData = malloc(tempSize)


        let source = CFDataGetBytePtr(providerData)
        memcpy(inBuffer.data, source, bytes)

        for _ in 0..<3 {
            vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, tempData, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
            swap(&inBuffer, &outBuffer)
        }

        let image = colorSpace.flatMap {
            CGContext(data: inBuffer.data,
                      width: width, height: height,
                      bitsPerComponent: bitsPerComponent,
                      bytesPerRow: bytesPerRow,
                      space: $0,
                      bitmapInfo: bitmapInfo.rawValue)
            }?.makeImage()
        free(inData)
        free(outData)
        free(tempData)
        return image
    }
}
