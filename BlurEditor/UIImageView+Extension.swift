//
//  UIImageView+Extension.swift
//  BlurEditorDemo
//
//  Created by SaitoYuta on 2017/12/19.
//  Copyright © 2017年 bangohan. All rights reserved.
//

import UIKit

extension UIView {

    private func aspectFitSize(for contentSize: CGSize) -> CGSize {
        let contentSize = CGSize.init()
        let widthRatio = bounds.width / contentSize.width
        let heightRatio = bounds.height / contentSize.height
        let ratio = (widthRatio > heightRatio) ? heightRatio : widthRatio
        let resizedWidth = contentSize.width * ratio
        let resizedHeight = contentSize.height * ratio
        let aspectFitSize = CGSize(width: resizedWidth, height: resizedHeight)
        return aspectFitSize
    }

    private func aspectFillSize(for contentSize: CGSize) -> CGSize {
        let widthRatio = bounds.width / contentSize.width
        let heightRatio = bounds.height / contentSize.height
        let ratio = (widthRatio < heightRatio) ? heightRatio : widthRatio
        let resizedWidth = contentSize.width * ratio
        let resizedHeight = contentSize.height * ratio
        let aspectFitSize = CGSize(width: resizedWidth, height: resizedHeight)
        return aspectFitSize
    }

    private func aspectFillFrame(for contentSize: CGSize) -> CGRect {
        let size = aspectFillSize(for: contentSize)
        return CGRect(origin: CGPoint(x: frame.origin.x - (size.width - bounds.size.width) * 0.5,
                                      y: frame.origin.y - (size.height - bounds.size.height) * 0.5),
                      size: size)
    }

    private func aspectFitFrame(for contentSize: CGSize) -> CGRect {
        let size = aspectFitSize(for: contentSize)
        return CGRect(origin: CGPoint(x: frame.origin.x + (bounds.size.width - size.width) * 0.5,
                                      y: frame.origin.y + (bounds.size.height - size.height) * 0.5),
                      size: size)
    }

    func actualContentSize(for originalContentSize: CGSize) -> CGSize {
        switch contentMode {
        case .scaleToFill, .redraw:
            return frame.size
        case .scaleAspectFit:
            return aspectFitSize(for: originalContentSize)
        case .scaleAspectFill:
            return aspectFillSize(for: originalContentSize)
        case .center, .top, .bottom, .left, .right,
             .topLeft, .topRight, .bottomLeft, .bottomRight:
            return frame.size
        }
    }



    func contentFrame(_ contentMode: UIViewContentMode, for originalContentSize: CGSize) -> CGRect {
        switch contentMode {
        case .scaleToFill, .redraw:
            return frame
        case .scaleAspectFit:
            return aspectFitFrame(for: originalContentSize)
        case .scaleAspectFill:
            return aspectFillFrame(for: originalContentSize)
        case .center:
            let x = frame.origin.x - (originalContentSize.width - bounds.size.width) * 0.5
            let y = frame.origin.y - (originalContentSize.height - bounds.size.height) * 0.5
            return CGRect(origin: CGPoint(x: x, y: y), size: originalContentSize)
        case .topLeft:
            return CGRect(origin: frame.origin, size: originalContentSize)
        case .top:
            let x = frame.origin.x - (originalContentSize.width - bounds.size.width) * 0.5
            let y = frame.origin.y
            return CGRect(origin: CGPoint(x: x, y: y), size: originalContentSize)
        case .topRight:
            let x = frame.origin.x - (originalContentSize.width - bounds.size.width)
            let y = frame.origin.y
            return CGRect(origin: CGPoint(x: x, y: y), size: originalContentSize)
        case .right:
            let x = frame.origin.x - (originalContentSize.width - bounds.size.width)
            let y = frame.origin.y - (originalContentSize.height - bounds.size.height) * 0.5
            return CGRect(origin: CGPoint(x: x, y: y), size: originalContentSize)
        case .bottomRight:
            let x = frame.origin.x - (originalContentSize.width - bounds.size.width)
            let y = frame.origin.y + (bounds.size.height - originalContentSize.height)
            return CGRect(origin: CGPoint(x: x, y: y), size: originalContentSize)
        case .bottom:
            let x = frame.origin.x - (originalContentSize.width - bounds.size.width) * 0.5
            let y = frame.origin.y + (bounds.size.height - originalContentSize.height)
            return CGRect(origin: CGPoint(x: x, y: y), size: originalContentSize)
        case .bottomLeft:
            let x = frame.origin.x
            let y = frame.origin.y + (bounds.size.height - originalContentSize.height)
            return CGRect(origin: CGPoint(x: x, y: y), size: originalContentSize)
        case .left:
            let x = frame.origin.x
            let y = frame.origin.y - (originalContentSize.height - bounds.size.height) * 0.5
            return CGRect(origin: CGPoint(x: x, y: y), size: originalContentSize)
        }
    }
}

