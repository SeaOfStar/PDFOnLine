//
//  DrawableView.swift
//  MyDrawView
//
//  Created by 吴向东 on 15/11/28.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class DrawableView: UIView {

    let defaultLineWidth:CGFloat = 8.0
    let defaultLineColor:UIColor = UIColor.orangeColor()

    var pan = UIPanGestureRecognizer()

    var lineLayer: CAShapeLayer! {
        return layer as! CAShapeLayer
    }

    override class func layerClass() ->AnyClass {
        return CAShapeLayer.self
    }

    private func moveToPoint(point: CGPoint) {
        if let cgPath = lineLayer.path {
            let path = UIBezierPath(CGPath: cgPath)
            path.moveToPoint(point)
            lineLayer.path = path.CGPath
        }
        else {
            let path = UIBezierPath()
            path.moveToPoint(point)
            lineLayer.path = path.CGPath
        }
    }

    private func addPointToLine(point: CGPoint) {
        let path = UIBezierPath(CGPath: lineLayer.path!)
        path.addLineToPoint(point)
        lineLayer.path = path.CGPath
    }

    func clearLine() {
        lineLayer.path = nil
    }

    init() {
        self.lineColor = defaultLineColor
        self.lineWidth = defaultLineWidth
        super.init(frame: CGRectZero)
        // 添加拖动手势
        addPanGestureRecognizer()
        configDefautLayerSetting()

    }

    required init?(coder aDecoder: NSCoder) {
        self.lineColor = defaultLineColor
        self.lineWidth = defaultLineWidth
        super.init(coder: aDecoder)
        addPanGestureRecognizer()
        configDefautLayerSetting()
    }

    required override init(frame: CGRect) {
        self.lineColor = defaultLineColor
        self.lineWidth = defaultLineWidth
        super.init(frame: frame)
        addPanGestureRecognizer()
        configDefautLayerSetting()
    }

    func panAction(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .Began:
            moveToPoint(pan.locationInView(self))

        case .Changed:
            addPointToLine(pan.locationInView(self))

        default:
            break
        }

    }

    private func addPanGestureRecognizer() {
        pan.addTarget(self, action: Selector("panAction:"))
        self.addGestureRecognizer(pan)
    }

    private func configDefautLayerSetting() {
        lineLayer.fillColor = UIColor.clearColor().CGColor
        lineLayer.strokeColor = defaultLineColor.CGColor
        lineLayer.lineWidth = defaultLineWidth
        lineLayer.lineCap = "round"
        lineLayer.lineJoin = "round"
    }

    var lineWidth: CGFloat {
        didSet {
            lineLayer.lineWidth = lineWidth
        }
    }

    var lineColor: UIColor {
        didSet {
            lineLayer.strokeColor = lineColor.CGColor
        }
    }

}
