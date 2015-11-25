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

    let 显示进度条距离:CGFloat = 20.0
    let 隐藏进度条距离:CGFloat = -180.0

    @IBOutlet weak var progessBarRightDistance: NSLayoutConstraint!
    @IBOutlet weak var progessBar: UIProgressView!
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

        // 显示进度条
        UIView.animateWithDuration(0.4) { () -> Void in
            self.progessBarRightDistance.constant = self.显示进度条距离
            self.view.layoutIfNeeded()
        }

        progessBar.setProgress(0.0, animated: true)
    }

    func stopRotation() {
        circelArrowImageView.layer.removeAllAnimations()

        // 显示进度条
        UIView.animateWithDuration(0.4) { () -> Void in
            self.progessBarRightDistance.constant = self.隐藏进度条距离
            self.view.layoutIfNeeded()
        }
    }

    // mark - task的回调操作
    func taskDidFinishedMenu(task: TreeTask) {
        print("菜单取得完成")
        self.downloadStatusLabel.text = "开始缓冲文件..."
    }

    func binaryDownloadStatusDidChanged(task: TreeTask) {
        let info = "\(task.downloadStaus.done) / \(task.downloadStaus.total)"
        self.downloadStatusLabel.text = info

        if task.downloadStaus.total > 0 {
            let value = Float(task.downloadStaus.done) / Float(task.downloadStaus.total)
            self.progessBar.setProgress(value, animated: true)
        }
        else {
            self.progessBar.setProgress(0.0, animated: true)
        }
    }

    func taskDidFinishedCache(task: TreeTask) {
        print("数据缓冲完成")
        // 发送全局通知，通知数据已经更新

        stopRotation()

        let 失败数量 = task.downloadStaus.total - task.downloadStaus.done
        if 失败数量 > 0 {
            self.downloadStatusLabel.text = "失败：【\(失败数量)】\(currentTimeString())"
        }
        else {
            self.downloadStatusLabel.attributedText = successfulString()
        }

        NSNotificationCenter.defaultCenter().postNotificationName(AppDelegate.menuUpdatedNotificationKey, object: self)

        self.refreshButton.enabled = true
    }

    func currentTimeString() -> String {
        let dateFormate = NSDateFormatter()
//        dateFormate.dateFormat = "  最后更新:yyyy年MM月dd日 HH:mm"
        dateFormate.dateFormat = "  最后更新(HH:mm)"
        return dateFormate.stringFromDate(NSDate())
    }

    func successfulString() -> NSAttributedString {

        let 强调效果 = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSBackgroundColorAttributeName: UIColor.lightGrayColor(),
            NSFontAttributeName: UIFont.boldSystemFontOfSize(downloadStatusLabel.font.pointSize),
        ]
        let 缓冲成功 = NSAttributedString(string: "缓冲成功!", attributes: 强调效果)

        let buffer = NSMutableAttributedString()
        buffer.appendAttributedString(缓冲成功)
        buffer.appendAttributedString(NSMutableAttributedString(string: currentTimeString()))

        return buffer
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

