//
//  GroupFrameworkViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/19.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class GroupFrameworkViewController: UIViewController {

    var listController: GroupListViewController?

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

    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "分组列表" {
            self.listController = segue.destinationViewController as? GroupListViewController
        }
    }


}
