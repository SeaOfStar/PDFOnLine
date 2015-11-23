//
//  PDFViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

protocol PDFViewControllerDelegate: NSObjectProtocol {
    // 在PDF上的下划操作
    func didSwipeDownAtController(pdfController: PDFViewController)
    func didSwipeUpAtController(pdfController: PDFViewController)

//    func didChangePDFFile(pdfController: PDFViewController)

    // 文章变换
    func reachEndOfPDFInController(controller: PDFViewController)
    func reachTopOfPDFInController(controller: PDFViewController)
}


class PDFViewController: UIViewController, PDFReaderViewDelegate {

    weak var delegate: PDFViewControllerDelegate?

    @IBOutlet weak var PDFReader: PDFReaderView!

    @IBOutlet weak var lineView: UIView!

    @IBOutlet weak var titleLabel: UILabel!

    var pdf: FileEntity? {
        didSet {
            if let theData = pdf {
                titleLabel.text = theData.name
                lineView.backgroundColor = UIColor.grayColor()
                lineView.backgroundColor = theData.ownerGroup?.color

                if let data = theData.data?.data {
                    PDFReader.data = data
                }
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        PDFReader.delegate = self

        // 添加下滑的手势操作用于显示tag列表
        let swipe = UISwipeGestureRecognizer(target: self, action: Selector("swipeDownAction:"))
        swipe.direction = .Down
        view.addGestureRecognizer(swipe)

        // 添加上滑的手势操作用于隐藏tag列表
        let swipeUp = UISwipeGestureRecognizer(target: self, action: Selector("swipeUpAction:"))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func didReachEndOfPDFView(view: PDFReaderView) {
        self.delegate?.reachEndOfPDFInController(self)
    }

    func didReachTopOfPDFView(view: PDFReaderView) {
        self.delegate?.reachTopOfPDFInController(self)
    }

    func swipeDownAction(sender: AnyObject) {
        self.delegate?.didSwipeDownAtController(self)
    }

    func swipeUpAction(sender: AnyObject) {
        self.delegate?.didSwipeUpAtController(self)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
