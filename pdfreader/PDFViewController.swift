//
//  PDFViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController, PDFReaderViewDelegate {

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func didReachEndOfPDFView(view: PDFReaderView) {
        if let next = pdf?.nextFile {
            pdf = next
        }
    }

    func didReachTopOfPDFView(view: PDFReaderView) {
        if let last = pdf?.lastFile {
            pdf = last
        }
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
