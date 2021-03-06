//
//  UIImage+Extension.swift
//  BlurEditor
//
//  Created by SaitoYuta on 2017/12/19.
//  Copyright © 2017年 bangohan. All rights reserved.
//

import UIKit

extension UIImage {

    static func filled(with color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(CGRect.init(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func blurred(blurRadius: CGFloat) -> UIImage? {
        guard let blurredCGImage = cgImage?.blurred(blurRadius: blurRadius, scale: scale) else { return nil }
        return UIImage.init(cgImage: blurredCGImage, scale: scale, orientation: imageOrientation)
    }

    func union(below image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: .init(origin: .zero, size: size))
        image.draw(in: .init(origin: .zero, size: image.size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func suitableSize(heightLimit: CGFloat? = nil,
                      widthLimit: CGFloat? = nil )-> CGSize? {

        if let height = heightLimit {

            let width = (height / self.size.height) * self.size.width

            return CGSize(width: width, height: height)
        }

        if let width = widthLimit {
            let height = (width / self.size.width) * self.size.height
            return CGSize(width: width, height: height)
        }

        if size.height > size.width {
            let width = (size.height / self.size.height) * self.size.width
            return CGSize(width: width, height: size.height)
        } else if size.width > size.height {
            let height = (size.width / self.size.width) * self.size.height
            return CGSize(width: size.width, height: height)
        } else {
            return size
        }
    }
}
