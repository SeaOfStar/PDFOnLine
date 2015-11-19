//
//  ContentProviderViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class ContentProviderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var app: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    var root: TreeEntity? {
        return app.root
    }

    var indexPath: NSIndexPath? {
        didSet {
            reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.indexPath = NSIndexPath(forRow: 0, inSection: 2)

        // 注册全局通知，监听数据更新操作
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadData"), name: AppDelegate.menuUpdatedNotificationKey, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var tagView: UICollectionView!

    func reloadData() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.tagView.reloadData()
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

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let groups = self.root?.groups {
            return groups.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("分组cell", forIndexPath: indexPath) as! GroupCell

        if let group = self.root?.groups?[indexPath.row] {
            let theGroup = group as! GroupEntity
            cell.ChineseTitle.text = theGroup.name
            cell.EnglishTitle.text = theGroup.nameInEnglish

            let color = theGroup.color
            cell.topColorLine.backgroundColor = color

            // 选中状态
            if let selection = self.indexPath {
//                print("\(indexPath.row) == \(selection.section)")
                cell.userSelected = (indexPath.row == selection.section)
            }
        }
        else {
            cell.ChineseTitle.text = ""
            cell.EnglishTitle.text = ""
            cell.topColorLine.backgroundColor = UIColor.grayColor()
            cell.userSelected = false
        }

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.indexPath = NSIndexPath(forRow: 0, inSection: indexPath.row)
    }

}
