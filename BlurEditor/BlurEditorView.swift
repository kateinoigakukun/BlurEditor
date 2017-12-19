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

    public enum Mode {
        case erase
        case pen
    }

    // MARK: - open properties

    open var originalImage: UIImage? {
        didSet {
            currentEditingImage = originalImage
            blurredImage = originalImage?.blurred(blurRadius: blurRadius)
            refreshImage()
        }
    }

    open var editedImage: UIImage? {
        return captureView()
    }

    open var blurRadius: CGFloat = 20.0 {
        didSet { refreshImage() }
    }

    open var mode: Mode = .pen {
        willSet { currentEditingImage = commit(paths: chunkedPath) }
        didSet { refreshImage() }
    }

    open var lineWidth: CGFloat = 20.0
    open var lineCap: CGLineCap = .round

    // MARK: - private properties

    private let topImageView: UIImageView = .init()
    private let underlyingImageView: UIImageView = .init()
    private var lastPoint: CGPoint?
    private var chunkedPath: [Path] = []
    private var currentEditingImage: UIImage?
    private var blurredImage: UIImage?

    private var topImage: UIImage? {
        didSet {
            topImageView.image = topImage
        }
    }
    private var underlyingImage: UIImage? {
        didSet {
            underlyingImageView.image = underlyingImage
        }
    }

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
        topImageView.contentMode = .scaleToFill
        underlyingImageView.contentMode = .scaleToFill
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
        chunkedPath.removeAll()
        switch mode {
        case .pen:
            topImage = currentEditingImage?.resized(max: max(frame.width, frame.height))
            underlyingImage = blurredImage
        case .erase:
            topImage = currentEditingImage?.resized(max: max(frame.width, frame.height))
            underlyingImage = originalImage
        }
    }

    private func captureView() -> UIImage? {
        return commit(paths: chunkedPath).flatMap { [weak self] image -> UIImage? in
            return self?.blurredImage?.union(below: image)
        }
    }

    private func drawPath(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        topImage?.draw(in: .init(origin: .zero, size: frame.size))
        let path = Path.init(fromPoint: fromPoint, toPoint: toPoint)
        chunkedPath.append(path)
        addStrokePath(context, from: fromPoint, to: toPoint)

        topImage = UIGraphicsGetImageFromCurrentImageContext()
    }

    private func commit(paths: [Path]) -> UIImage? {
        guard let currentEditingImage = currentEditingImage else { return nil }
        guard !paths.isEmpty else { return currentEditingImage }
        UIGraphicsBeginImageContextWithOptions(currentEditingImage.size, false, currentEditingImage.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        currentEditingImage.draw(in: .init(origin: .zero, size: currentEditingImage.size))

        let ratio = (width: currentEditingImage.size.width / frame.width, height: currentEditingImage.size.height / frame.height)

        paths.forEach { path in
            let scaledFromPoint = CGPoint.init(x: path.fromPoint.x * ratio.width,
                                               y: path.fromPoint.y * ratio.height)
            let scaledToPoint = CGPoint.init(x: path.toPoint.x * ratio.width,
                                             y: path.toPoint.y * ratio.height)

            addStrokePath(context, from: scaledFromPoint, to: scaledToPoint,
                          lineWidthRatio: max(ratio.width, ratio.height))
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()

        switch mode {
        case .erase:
            return image.flatMap { originalImage?.union(below: $0) }
        case .pen:
            return image.flatMap { blurredImage?.union(below: $0) }
        }
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

