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

    private class DrawingView: UIView {

        private var lastPoint: CGPoint?
        fileprivate var drawHandler: ((_ fromPoint: CGPoint, _ toPoint: CGPoint) -> Void)?

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

            drawHandler?(lastPoint, point)
        }

        open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesEnded(touches, with: event)

            guard let _ = lastPoint else { return }
            lastPoint = nil
        }

    }


    // MARK: - open properties

    open var originalImage: UIImage? {
        didSet {
            currentEditingImage = originalImage
            blurredImage = originalImage?.blurred(blurRadius: blurRadius)
            topImageViewHeightConstraint?.constant = originalImage?.suitableSize(widthLimit: frame.size.width)?.height ?? 0.0
            refreshImage()
        }
    }

    open var blurRadius: CGFloat = 20.0 {
        didSet { refreshImage() }
    }

    open var mode: Mode = .pen {
        willSet { commit() }
        didSet { refreshImage() }
    }

    open var lineWidth: CGFloat = 20.0
    open var lineCap: CGLineCap = .round

    // MARK: - private properties

    private let topImageView: UIImageView = .init()
    private let underlyingImageView: UIImageView = .init()
    private let drawingView: DrawingView = .init()

    private var topImageViewHeightConstraint: NSLayoutConstraint?
    private var chunkedPath: [Path] = []
    private var currentEditingImage: UIImage? {
        didSet { topImageView.image = currentEditingImage }
    }
    private var blurredImage: UIImage?

    // MARK: - initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    // MARK: - public methods

    public func exportCanvas() -> UIImage? {
        commit()
        return currentEditingImage.flatMap { [weak self] image -> UIImage? in
            return self?.blurredImage?.union(below: image)
        }
    }

    private func initialize() {
        underlyingImageView.frame = .init(origin: .zero, size: frame.size)
        underlyingImageView.contentMode = .scaleAspectFit
        underlyingImageView.translatesAutoresizingMaskIntoConstraints = false

        topImageView.frame = .init(origin: .zero, size: frame.size)
        topImageView.contentMode = .scaleAspectFit
        topImageView.translatesAutoresizingMaskIntoConstraints = false

        drawingView.translatesAutoresizingMaskIntoConstraints = false
        drawingView.drawHandler = { [weak self] fromPoint, toPoint in
            self?.drawPath(from: fromPoint, to: toPoint)
        }

        addSubview(underlyingImageView)
        addSubview(topImageView)
        addSubview(drawingView)
        bringSubview(toFront: topImageView)
        bringSubview(toFront: drawingView)

        let viewTopConstraint = NSLayoutConstraint.init(
            item: topImageView, attribute: .top,
            relatedBy: .equal, toItem: self, attribute: .top,
            multiplier: 1.0, constant: 0.0)
        viewTopConstraint.priority = .defaultHigh

        let viewBottomConstraint = NSLayoutConstraint.init(
            item: topImageView, attribute: .bottom,
            relatedBy: .equal, toItem: self, attribute: .bottom,
            multiplier: 1.0, constant: 0.0)
        viewBottomConstraint.priority = .defaultHigh

        let imageViewHeightConstraint = topImageView.heightAnchor.constraint(equalToConstant: 0)
        topImageViewHeightConstraint = imageViewHeightConstraint

        let constraints = [
            topImageView.heightAnchor.constraint(equalTo: underlyingImageView.heightAnchor),
            topImageView.widthAnchor.constraint(equalTo: underlyingImageView.widthAnchor),
            topImageView.centerXAnchor.constraint(equalTo: underlyingImageView.centerXAnchor),
            topImageView.centerYAnchor.constraint(equalTo: underlyingImageView.centerYAnchor),

            topImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            topImageView.centerYAnchor.constraint(equalTo: centerYAnchor),

            drawingView.centerXAnchor.constraint(equalTo: topImageView.centerXAnchor),
            drawingView.centerYAnchor.constraint(equalTo: topImageView.centerYAnchor),
            drawingView.widthAnchor.constraint(equalTo: topImageView.widthAnchor),
            drawingView.heightAnchor.constraint(equalTo: topImageView.heightAnchor),
            viewTopConstraint, viewBottomConstraint, imageViewHeightConstraint
            ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - private mathods

    private func refreshImage() {
        guard let originalImage = originalImage else { return }
        switch mode {
        case .pen:
            underlyingImageView.image = blurredImage
        case .erase:
            underlyingImageView.image = originalImage
        }
    }

    private func captureView() -> UIImage? {
        commit()
        return currentEditingImage.flatMap { [weak self] image -> UIImage? in
            return self?.blurredImage?.union(below: image)
        }
    }

    private func drawPath(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(topImageView.frame.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        topImageView.image?.draw(in: .init(origin: .zero, size: topImageView.frame.size))
        let path = Path.init(fromPoint: fromPoint, toPoint: toPoint)
        chunkedPath.append(path)
        addStrokePath(context, from: fromPoint, to: toPoint)

        topImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    }

    private func commit() {
        guard let currentEditingImage = currentEditingImage else { return }
        guard !chunkedPath.isEmpty else { return }
        defer { chunkedPath.removeAll() }

        UIGraphicsBeginImageContextWithOptions(currentEditingImage.size, false, currentEditingImage.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        currentEditingImage.draw(in: .init(origin: .zero, size: currentEditingImage.size))

        let ratio = (width: currentEditingImage.size.width / topImageView.frame.width, height: currentEditingImage.size.height / topImageView.frame.height)

        chunkedPath.forEach { path in
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
            self.currentEditingImage = image.flatMap { originalImage?.union(below: $0) }
        case .pen:
            self.currentEditingImage = image.flatMap { blurredImage?.union(below: $0) }
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

