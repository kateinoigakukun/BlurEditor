//
//  UIImage+Extension.swift
//  BlurEditor
//
//  Created by SaitoYuta on 2017/12/19.
//  Copyright © 2017年 bangohan. All rights reserved.
//

import UIKit

extension UIImage {

    func blurred(blurRadius: CGFloat) -> UIImage? {
        guard let blurredCGImage = cgImage?.blurred(blurRadius: blurRadius, scale: scale) else { return nil }
        return UIImage.init(cgImage: blurredCGImage, scale: scale, orientation: imageOrientation)
    }

    func resized(max length: CGFloat) -> UIImage {
        let originalSize: CGSize = size
        let ratio: CGFloat = length / max(originalSize.width, originalSize.height)
        let resizedSize: CGSize = CGSize(width: originalSize.width * ratio, height: originalSize.height * ratio)
        let resizedRect: CGRect = CGRect(origin: .zero, size: resizedSize)
        let resizedImage: UIImage

        if #available(iOS 10.0, *) {
            let renderer: UIGraphicsImageRenderer = UIGraphicsImageRenderer(size: resizedSize)
            resizedImage = renderer.image { [weak self] _ in
                self?.draw(in: resizedRect)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
            draw(in: resizedRect)
            resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }

        return resizedImage
    }

    func union(below image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: .init(origin: .zero, size: size))
        image.draw(in: .init(origin: .zero, size: image.size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
