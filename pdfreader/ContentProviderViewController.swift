//
//  ContentProviderViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class ContentProviderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GroupFrameworkViewControllerDelegate {

    var groupDetailController: GroupFrameworkViewController!
    var pdfViewController: PDFViewController!

    // 承载group内容和PDF内容的两个container view
    @IBOutlet weak var pdfContainer: UIView!
    @IBOutlet weak var groupContainer: UIView!



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

        self.indexPath = NSIndexPath(forRow: -1, inSection: 2)

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

            if let theIndexPath = self.indexPath {
                let theGroup = self.root?.groups?.objectAtIndex(theIndexPath.section) as? GroupEntity
                self.groupDetailController.group = theGroup

                // 判断是否显示内容的依据是row是否合法
                // row 小于0则显示group信息，反之则显示对应的PDF
                let row = theIndexPath.row
                if row < 0 {
                    // 显示group

                }
                else {
                    // 显示具体的PDF的内容
                    if let pdf = theGroup?.files?.objectAtIndex(row) as? FileEntity {
                        self.doShowPDF(pdf)
                    }
                }
            }
        }
    }

    func doShowPDF(file: FileEntity) {
        bringPDFViewToTop()
        hideTagView()

        pdfViewController.pdf = file
    }

    func bringPDFViewToTop() {
        view.bringSubviewToFront(pdfContainer)
    }

    func hideTagView() {

    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.


        switch segue.identifier! {
        case "显示分组":
            self.groupDetailController = segue.destinationViewController as! GroupFrameworkViewController
            self.groupDetailController.delegate = self

        case "显示PDF":
            self.pdfViewController = segue.destinationViewController as! PDFViewController

        default:
             break
        }

//        if segue.identifier == "显示分组" {
//
//        }
//        else if
    }


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
        self.indexPath = NSIndexPath(forRow: -1, inSection: indexPath.row)
    }

//    MARK: - 用户在分组的详细页面上点击了对应的数据
    func groupController(groupController: GroupFrameworkViewController, didSelectedCellAtIndex index: Int) {
        // 找到group相对应的section

        if let theGroup = groupController.group {
            if let section = root?.groups?.indexOfObject(theGroup) {
                let indexPath = NSIndexPath(forRow: index, inSection: section)
                self.indexPath = indexPath
            }
        }
    }

}
