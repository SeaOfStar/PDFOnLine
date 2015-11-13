//
//  PDFViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController {

    var urlForPDF: NSURL?
    var pageCount = 0

    @IBOutlet weak var pageView: PDFPageView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

//        if let url = urlForPDF {
//
//        }

        let path = NSBundle.mainBundle().pathForResource("人力资源管理平台", ofType: "pdf")
        print("")

        let url = NSURL(fileURLWithPath: path!)
        let document = CGPDFDocumentCreateWithURL(url)
        pageCount = CGPDFDocumentGetNumberOfPages(document)

        print("文件(\(pageCount)页)路径：\(path)")

        self.pageView.pageRef = CGPDFDocumentGetPage(document, 7)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
