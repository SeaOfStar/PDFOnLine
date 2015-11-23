//
//  ContentProviderViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit
import CoreData

class ContentProviderViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GroupFrameworkViewControllerDelegate, PDFViewControllerDelegate {


    var groupDetailController: GroupFrameworkViewController!
    var pdfViewController: PDFViewController!

    // 承载group内容和PDF内容的两个container view
    @IBOutlet weak var pdfContainer: UIView!
    @IBOutlet weak var groupContainer: UIView!

    @IBOutlet weak var tagViewUpperDistance: NSLayoutConstraint!


    var app: AppDelegate! {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    lazy var root: TreeEntity? = {
        // 做检索，检索出最新的数据
        let request = NSFetchRequest(entityName: "TreeEntity")
        request.predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "refreshTime", ascending: false)
        request.sortDescriptors = [sort]

        do {
            let trees = try self.app.managedObjectContext.executeFetchRequest(request)
            return trees.first as? TreeEntity
        } catch {
            return nil
        }
    }()


    var indexPath: NSIndexPath? {
        didSet {
            reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = self.root {
            self.indexPath = NSIndexPath(forRow: -1, inSection: 0)
        }

        // 注册全局通知，监听数据更新操作
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("resetAll"), name: AppDelegate.menuUpdatedNotificationKey, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showPDFFromMenu:"), name: MenuTableViewController.notificationKeyForPDF, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var tagView: UICollectionView!

    func resetAll() {
        // 强制清空原来的检索结果
        self.root = nil
        if let _ = self.root {
            self.indexPath = NSIndexPath(forRow: -1, inSection: 0)
        }
    }

    func reloadData() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.tagView.reloadData()

            if let _ = self.root {
                if let _ = self.indexPath {

                }
                else {
                    self.indexPath = NSIndexPath(forRow: -1, inSection: 0)
                }
            }


            if let theIndexPath = self.indexPath {
                // 滚动tag view
                let pathForTag = NSIndexPath(forRow: theIndexPath.section, inSection: 0)
                self.tagView.scrollToItemAtIndexPath(pathForTag, atScrollPosition: .CenteredHorizontally, animated: true)

                let theGroup = self.root?.groups?.objectAtIndex(theIndexPath.section) as? GroupEntity
                self.groupDetailController.group = theGroup

                // 判断是否显示内容的依据是row是否合法
                // row 小于0则显示group信息，反之则显示对应的PDF
                let row = theIndexPath.row
                if row < 0 {
                    // 显示group
                    self.bringGroupViewUp()
                    self.hideTagView(false)
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
        bringPDFViewUp()
        hideTagView(true)

        pdfViewController.pdf = file
    }

    func bringPDFViewUp() {
        view.sendSubviewToBack(groupContainer)
    }

    func bringGroupViewUp() {
        view.sendSubviewToBack(pdfContainer)
    }

    func hideTagView(hide: Bool) {

        UIView.animateWithDuration(0.4) { () -> Void in
            self.tagViewUpperDistance.constant = hide ? (-self.tagView.bounds.size.height) : 0.0
            self.tagView.layoutIfNeeded()
        }
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
            self.pdfViewController.delegate = self

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
        if let theGroup = groupController.group {
            if let section = root?.groups?.indexOfObject(theGroup) {
                let indexPath = NSIndexPath(forRow: index, inSection: section)
                self.indexPath = indexPath
            }
        }
    }
    // MARK: 用户在分组页面上左右滑动
    func didRequestToNextGroup(groupController: GroupFrameworkViewController) {
        if let theGroup = groupController.group {
            if let section = root?.groups?.indexOfObject(theGroup) {
                // 循环移动
                if section < (root!.groups!.count - 1) {
                    self.indexPath = NSIndexPath(forRow: -1, inSection: (section + 1))
                }
                else {
                    self.indexPath = NSIndexPath(forRow: -1, inSection: 0)
                }
            }
        }
    }

    func didRequestToLastGroup(groupController: GroupFrameworkViewController) {
        if let theGroup = groupController.group {
            if let section = root?.groups?.indexOfObject(theGroup) {
                // 循环移动
                if section > 0 {
                    self.indexPath = NSIndexPath(forRow: -1, inSection: (section - 1))
                }
                else {
                    self.indexPath = NSIndexPath(forRow: -1, inSection: (root!.groups!.count - 1))
                }
            }
        }
    }

//    MARK: - 用户在pdf页面下滑操作
    func didSwipeDownAtController(pdfViewController: PDFViewController) {
        hideTagView(false)
    }

//    MARK: 滑动后PDF文件变化
    func reachEndOfPDFInController(controller: PDFViewController) {
        if let old = controller.pdf {
            if let newOne = old.nextFile {
                indexPath = self.root?.indexPathForFile(newOne)
            }
        }
    }

    func reachTopOfPDFInController(controller: PDFViewController) {
        if let old = controller.pdf {
            if let newOne = old.lastFile {
                indexPath = self.root?.indexPathForFile(newOne)
            }
        }
    }

    func didChangePDFFile(pdfController: PDFViewController) {
        let pdf = pdfController.pdf!
        let showSection = root!.groups!.indexOfObject(pdf.ownerGroup!)

        let highlightSection = self.indexPath!.section

        if highlightSection != showSection {
            // 调整tagview中显示的高亮位置

        }
    }

//    相应侧面菜单上的点击事件
    func showPDFFromMenu(notification: NSNotification) {
        if let indexPathFromMenu = notification.userInfo![MenuTableViewController.notificationKeyForIndexPath] {
            self.indexPath = indexPathFromMenu as? NSIndexPath
        }
    }

}
