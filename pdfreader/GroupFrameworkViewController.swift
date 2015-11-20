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
    func didRequestToNextGroup(groupController: GroupFrameworkViewController)
    func didRequestToLastGroup(groupController: GroupFrameworkViewController)
}

class GroupFrameworkViewController: UIViewController, GroupListViewControllerDelegate {

    var listController: GroupListViewController!

    static let defaultIcon = UIImage(named: "注册商标_淡化")

    weak var delegate: GroupFrameworkViewControllerDelegate?

    @IBOutlet weak var firstIcon: UIImageView!
    @IBOutlet weak var firstPDFTitle: UILabel!
    @IBOutlet weak var colorView: UIView!

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

        // 在自己的页面上添加左右滑动的手势

        configGestureRecognizer()

    }

    func configGestureRecognizer() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("swipeLeftAction:"))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)

        let swipRight = UISwipeGestureRecognizer(target: self, action: Selector("swipeRightAction:"))
        swipRight.direction = .Right
        view.addGestureRecognizer(swipRight)
    }

    func swipeLeftAction(sender: UISwipeGestureRecognizer) {
        self.delegate?.didRequestToNextGroup(self)
    }
    
    func swipeRightAction(sender: UISwipeGestureRecognizer) {
        self.delegate?.didRequestToLastGroup(self)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadData() {

        firstIcon.image = GroupFrameworkViewController.defaultIcon
        firstPDFTitle.text = ""

        colorView.backgroundColor = group?.color

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
            self.listController.delegate = self
        }
    }

    @IBAction func fistPDFIconAction(sender: UIButton) {
        self.delegate?.groupController(self, didSelectedCellAtIndex: 0)
    }

    func listController(groupListController: GroupListViewController, didClickAtIndex index: Int) {
        self.delegate?.groupController(self, didSelectedCellAtIndex: (index + 1))
    }

}
