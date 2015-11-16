//
//  PDFPageLayer.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class PDFPageLayer: CALayer {

    var pageRef: CGPDFPageRef? {
        didSet {
            if let _ = pageRef {
                self.setNeedsDisplay()
            }
        }
    }

    var fitScaleRate: CGFloat {
        get {
            if let page = pageRef {
                let contextRect = CGPDFPageGetBoxRect(page, CGPDFBox.MediaBox)
                let myRect = bounds

                if contextRect.size.width > 1 && contextRect.size.height > 1 {
                    let widthRate = myRect.size.width / contextRect.size.width
                    let heightRate = myRect.size.height / contextRect.size.height

                    return min(widthRate, heightRate)
                }
                else {
                    // 异常数据，不进行缩放
                    return 1.0
                }
            }
            else {
                return 1.0
            }
        }
    }

    // 计算出将显示内容居中需要平移的x坐标
    var xOffset: CGFloat {
        get {
            let rate = self.fitScaleRate
            var contextRect = CGPDFPageGetBoxRect(pageRef, CGPDFBox.MediaBox)
            let myRect = bounds

            contextRect.size.width *= rate
            return (myRect.size.width - contextRect.size.width) / 2.0
        }
    }

    override func drawInContext(ctx: CGContext) {

        if let ref = pageRef {

//            CGContextFillRect(ctx, bounds)
            CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
            CGContextTranslateCTM(ctx, xOffset, self.bounds.size.height);

            let rate = self.fitScaleRate
            CGContextScaleCTM(ctx, rate, -rate);
            CGContextDrawPDFPage(ctx, ref);
        }
        else {
            super.drawInContext(ctx)
        }
    }
}
