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

    override func drawInContext(ctx: CGContext) {

        if let ref = pageRef {
            CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
            CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
            CGContextScaleCTM(ctx, 1.2, -1.2);
            CGContextDrawPDFPage(ctx, ref);
        }
        else {
            super.drawInContext(ctx)
        }
    }
}
