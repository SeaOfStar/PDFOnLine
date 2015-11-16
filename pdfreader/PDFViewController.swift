//
//  PDFViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController, PDFReaderViewDelegate {

    var urlForPDF: NSURL?
    var pageCount = 0


    @IBOutlet weak var PDFReader: PDFReaderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let path = NSBundle.mainBundle().pathForResource("人力资源管理平台", ofType: "pdf")
        let url = NSURL(fileURLWithPath: path!)

        self.PDFReader.url = url
        self.PDFReader.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func didReachEndOfPDFView(view: PDFReaderView) {
        let path = NSBundle.mainBundle().pathForResource("华信云数据中心服务手册", ofType: "pdf")
        let url = NSURL(fileURLWithPath: path!)
        view.url = url
    }

    func didReachTopOfPDFView(view: PDFReaderView) {
        let path = NSBundle.mainBundle().pathForResource("其他行业", ofType: "pdf")
        let url = NSURL(fileURLWithPath: path!)
        view.url = url
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
