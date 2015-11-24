//
//  PDFReaderView.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

protocol PDFReaderViewDelegate: NSObjectProtocol {
    func didReachEndOfPDFView(view :PDFReaderView)
    func didReachTopOfPDFView(view :PDFReaderView)
    func didPageChangedInPDFView(view: PDFReaderView)

}


class PDFReaderView: UIView {

    weak var delegate :PDFReaderViewDelegate?

    // 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)

        leftGesture.addTarget(self, action: Selector("nextPage"))
        leftGesture.direction = UISwipeGestureRecognizerDirection.Left
        rightGesture.addTarget(self, action: Selector("lastPage"))  // 修改
        rightGesture.direction = UISwipeGestureRecognizerDirection.Right

        self.addGestureRecognizer(leftGesture)
        self.addGestureRecognizer(rightGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        leftGesture.addTarget(self, action: Selector("nextPage"))
        leftGesture.direction = UISwipeGestureRecognizerDirection.Left
        rightGesture.addTarget(self, action: Selector("lastPage"))  // 修改
        rightGesture.direction = UISwipeGestureRecognizerDirection.Right

        self.addGestureRecognizer(leftGesture)
        self.addGestureRecognizer(rightGesture)
    }

    var url: NSURL? {
        didSet {
            if let theURL = url {
                self.document = CGPDFDocumentCreateWithURL(theURL)
                self.data = nil
            }
        }
    }

    var data: NSData? {
        didSet {
            if let theData = data {
                self.document = CGPDFDocumentCreateWithProvider(CGDataProviderCreateWithCFData(theData))
                self.url = nil
            }
        }
    }


    private var document: CGPDFDocument? {
        didSet {
            pageCount = CGPDFDocumentGetNumberOfPages(document)
            self.index = 0
        }
    }
    var pageCount = 0
    var index = 0 {     // 0起始
        didSet {
            // 动画数组
            let group = CAAnimationGroup()
            group.duration = 0.7
            group.delegate = self


            // 修改当前的layer
            if let old = currentPageLayer {
                old.removeFromSuperlayer()
            }

            let page = PDFPageLayer()
            page.pageRef = CGPDFDocumentGetPage(document, index + 1)
            page.frame = self.bounds
            currentPageLayer = page
            self.layer.addSublayer(page)

            let showAnimation = CABasicAnimation(keyPath: "opacity")
            showAnimation.fromValue = 0.0
            showAnimation.toValue = 1.0
            showAnimation.delegate = self
            showAnimation.duration = 0.4
            page.addAnimation(showAnimation, forKey: "显示")

            self.delegate?.didPageChangedInPDFView(self)
        }
    }

    var currentPageLayer :PDFPageLayer?

    var circlePage = false  // 是否循环翻页

//    var lastLayer, currentLayer, nextLayer: PDFPageLayer?
//    var scrollLayer: CALayer?

    // 手势
    var leftGesture = UISwipeGestureRecognizer()
    var rightGesture = UISwipeGestureRecognizer()

    override func layoutSubviews() {
        super.layoutSubviews()

        currentPageLayer?.frame = bounds
    }

    func nextPage() ->Bool {
        if pageCount <= 0 {
            // 没有数据
            self.delegate?.didReachEndOfPDFView(self)
            return false
        }

        var next = index + 1
        if next >= pageCount {
            if circlePage {
                next = 0
            }
            else {
                self.delegate?.didReachEndOfPDFView(self)
                return false
            }
        }
        self.index = next
        return true
    }

    func lastPage() ->Bool {
        if pageCount <= 0 {
            // 没有数据
            self.delegate?.didReachTopOfPDFView(self)
            return false
        }

        let last = index - 1
        if last >= 0 {
            self.index = last
            return true
        }
        else {
            if circlePage {
                self.index = pageCount - 1
                return true
            }
        }
        
        self.delegate?.didReachTopOfPDFView(self)
        return false
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

//    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
//        self.currentPageLayer?.opacity = 1.0
//    }

}
