//
//  PDFPageView.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class PDFPageView: UIView {

    var pageRef: CGPDFPageRef? {
        didSet {
            if let _ = pageRef {
                self.setNeedsDisplay()
            }
        }
    }

    override func drawRect(rect: CGRect) {
        // Drawing code
        if let ref = pageRef {
            let context = UIGraphicsGetCurrentContext()
            // 翻转坐标
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextTranslateCTM(context, 0, self.bounds.size.height);
            CGContextScaleCTM(context, 1.2, -1.2);
            CGContextDrawPDFPage(context, ref);
        }
        else {
            super.drawRect(rect)
        }
    }
}
