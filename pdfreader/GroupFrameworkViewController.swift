//
//  GroupFrameworkViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/19.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

protocol GroupFrameworkViewControllerDelegate: NSObjectProtocol {
    // 用户点击了group中的数据
    func groupController(groupController: GroupFrameworkViewController, didSelectedCellAtIndex index:Int)
}

class GroupFrameworkViewController: UIViewController {

    var listController: GroupListViewController?

    static let defaultIcon = UIImage(named: "注册商标_淡化")

    weak var delegate: GroupFrameworkViewControllerDelegate?

    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var firstPDFTitle: UILabel!

    var group: GroupEntity? {
        didSet {
            if let list = listController {
                list.group = group
            }
            reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadData() {

        firstIcon.image = GroupFrameworkViewController.defaultIcon
        firstPDFTitle.text = ""

        if let firstPDF = group?.files?.firstObject {
            let pdf = firstPDF as! FileEntity
            firstPDFTitle.text = pdf.name

            if let imageData = pdf.icon?.data {
                firstIcon.image = UIImage(data: imageData)
            }
        }
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "分组列表" {
            self.listController = segue.destinationViewController as? GroupListViewController
        }
    }

    @IBAction func fistPDFIconAction(sender: UIButton) {
        self.delegate?.groupController(self, didSelectedCellAtIndex: 0)
    }

}
