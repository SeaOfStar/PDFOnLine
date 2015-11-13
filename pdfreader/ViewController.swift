//
//  ViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    let 动画时间 = 0.4

    @IBOutlet weak var maskView: UIVisualEffectView!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var menuLeftEdge: NSLayoutConstraint!

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

