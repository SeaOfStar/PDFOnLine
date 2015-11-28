//
//  LineViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/28.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

protocol LineViewControllerDelegate: NSObjectProtocol {
    func didClickCloseButtonOnLineController(lineController: LineViewController)
}

class LineViewController: UIViewController {

    weak var delegate: LineViewControllerDelegate?

    @IBOutlet var drawView: DrawableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        drawView.lineColor = UIColor.orangeColor().colorWithAlphaComponent(0.8)

        // Do any additional setup after loading the view.
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

    // MARK: - 按钮事件
    @IBAction func clearButtonAction(sender: AnyObject) {
        drawView.clearLine()
    }

    @IBAction func closeButtonAction(sender: AnyObject) {
        drawView.clearLine()
        delegate?.didClickCloseButtonOnLineController(self)
    }




}
