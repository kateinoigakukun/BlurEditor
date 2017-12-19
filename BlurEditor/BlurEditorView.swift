//
//  BlurEditorView.swift
//  BlurEditor
//
//  Created by SaitoYuta on 2017/12/19.
//  Copyright © 2017年 bangohan. All rights reserved.
//

import UIKit

open class BlurEditorView: UIView {

    private struct Path {
        let fromPoint: CGPoint
        let toPoint: CGPoint
    }

    // MARK: - open properties

    open var originalImage: UIImage? {
        didSet { refreshImage() }
    }

    open var editedImage: UIImage? {
        return captureView()
    }

    open var blurRadius: CGFloat = 20.0 {
        didSet { refreshImage() }
    }

    open var lineWidth: CGFloat = 20.0
    open var lineCap: CGLineCap = .round

    // MARK: - private properties

    private let topImageView: UIImageView = .init()
    private let underlyingImageView: UIImageView = .init()
    private var lastPoint: CGPoint?
    private var chunkedPath: [Path] = []

    // MARK: - initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    private func initialize() {
        underlyingImageView.frame = .init(origin: .zero, size: frame.size)
        topImageView.frame = .init(origin: .zero, size: frame.size)
        addSubview(underlyingImageView)
        addSubview(topImageView)
        bringSubview(toFront: topImageView)
    }

    // MARK: - override

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        if lastPoint == nil {
            lastPoint = point
        }
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let point = touches.first?.location(in: self) else { return }
        defer { lastPoint = point }
        guard let lastPoint = lastPoint else { return }

        drawPath(from: lastPoint, to: point)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let _ = lastPoint else { return }
        lastPoint = nil
    }

    // MARK: - private mathods

    private func refreshImage() {
        guard let originalImage = originalImage else { return }
        topImageView.contentMode = .scaleToFill
        underlyingImageView.contentMode = .scaleToFill
        topImageView.image = originalImage.resized(max: max(frame.width, frame.height))
        underlyingImageView.image = originalImage.blurred(blurRadius: blurRadius)
    }

    private func captureView() -> UIImage? {
        return commit(paths: chunkedPath)
    }

    private func drawPath(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        topImageView.image?.draw(in: .init(origin: .zero, size: frame.size))
        let path = Path.init(fromPoint: fromPoint, toPoint: toPoint)
        chunkedPath.append(path)
        addStrokePath(context, from: fromPoint, to: toPoint)

        topImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    }

    private func commit(paths: [Path]) -> UIImage? {
        guard let originalImage = originalImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, originalImage.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        originalImage.draw(in: .init(origin: .zero, size: originalImage.size))

        let ratio = (width: originalImage.size.width / frame.width, height: originalImage.size.height / frame.height)

        paths.forEach { path in
            let scaledFromPoint = CGPoint.init(x: path.fromPoint.x * ratio.width,
                                               y: path.fromPoint.y * ratio.height)
            let scaledToPoint = CGPoint.init(x: path.toPoint.x * ratio.width,
                                             y: path.toPoint.y * ratio.height)

            addStrokePath(context, from: scaledFromPoint, to: scaledToPoint,
                          lineWidthRatio: max(ratio.width, ratio.height))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()

        return image
    }

    private func addStrokePath(_ context: CGContext, from fromPoint: CGPoint, to toPoint: CGPoint, lineWidthRatio: CGFloat = 1.0) {
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
        context.setLineCap(lineCap)
        context.setLineWidth(lineWidth * lineWidthRatio)
        context.setStrokeColor(UIColor.clear.cgColor)
        context.setBlendMode(.clear)
        context.strokePath()
    }
}

