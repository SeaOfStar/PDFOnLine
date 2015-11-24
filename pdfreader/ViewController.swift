//
//  ViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit



class ViewController: UIViewController, TreeTaskDelegate {
    let 动画时间 = 0.4

    @IBOutlet weak var maskView: UIVisualEffectView!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var menuLeftEdge: NSLayoutConstraint!

    @IBOutlet weak var downloadStatusLabel: UILabel!

    var showMenu = false {
        didSet {
            if showMenu {
                // 显示目录
                maskView.hidden = false
                UIView.animateWithDuration(动画时间, animations: { () -> Void in
                    self.menuLeftEdge.constant = 0
                    self.view.layoutIfNeeded()
                })
            }
            else {
                // 隐藏目录
                UIView.animateWithDuration(动画时间, animations: { () -> Void in
                    self.menuLeftEdge.constant = -1 * self.menuContainerView.bounds.size.width
                    self.view.layoutIfNeeded()
                    }, completion: {(isFinished: Bool) -> Void in
                        self.maskView.hidden = true
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // 收到任何菜单传来的通知都隐藏菜单
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("closeMenuButtonAction:"), name: MenuTableViewController.notificationKeyForPDF, object: nil)

    }

    @IBOutlet weak var circelArrowImageView: UIImageView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBAction func refreshButtonAction(sender: UIButton) {

        sender.enabled = false
        self.downloadStatusLabel.text = "数据更新中 ..."

        startRotation()

        let task = TreeTask()
        task.delegate = self

        task.fetch()
    }

    func startRotation() {

        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = M_PI * -2.0
        rotation.duration = 0.8
        rotation.cumulative = true
        rotation.repeatCount = .infinity

        circelArrowImageView.layer.addAnimation(rotation, forKey: nil)
    }

    func stopRotation() {
        circelArrowImageView.layer.removeAllAnimations()
    }

    // mark - task的回调操作
    func taskDidFinishedMenu(task: TreeTask) {
        print("菜单取得完成")
        self.downloadStatusLabel.text = "开始缓冲文件..."
    }

    func binaryDownloadStatusDidChanged(task: TreeTask) {
        let info = "\(task.downloadStaus.done) / \(task.downloadStaus.total)"
        self.downloadStatusLabel.text = info
    }

    func taskDidFinishedCache(task: TreeTask) {
        print("数据缓冲完成")
        // 发送全局通知，通知数据已经更新

        stopRotation()

        let dateFormate = NSDateFormatter()
        dateFormate.dateFormat = "yy年MM月dd日 HH:mm"
        let timeString = dateFormate.stringFromDate(NSDate())
        let info = "失败：【\(task.downloadStaus.total - task.downloadStaus.done)】最后更新时间：\(timeString)"
        self.downloadStatusLabel.text = info

        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.menuUpdatedNotificationKey, object: self)

        self.refreshButton.enabled = true
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // mark - 菜单按钮

    @IBAction func menuButtonAction(sender: AnyObject) {
        showMenu = !showMenu
    }

    @IBAction func closeMenuButtonAction(sender: AnyObject) {
        showMenu = false
    }
}

