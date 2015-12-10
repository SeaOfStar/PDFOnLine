//
//  ContentProviderViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AVKit

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

    var root: TreeEntity?
    func refetchRoot() {
        // 做检索，检索出最新的数据
        let request = NSFetchRequest(entityName: "TreeEntity")
        request.predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "refreshTime", ascending: false)
        request.sortDescriptors = [sort]

        do {
            let trees = try self.app.managedObjectContext.executeFetchRequest(request)
            self.root = trees.first as? TreeEntity
        } catch {
            self.root = nil
        }
    }


    var indexPath: NSIndexPath? {
        didSet {
            reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refetchRoot()

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
        self.refetchRoot()
        if let _ = self.root {
            self.indexPath = NSIndexPath(forRow: -1, inSection: 0)
        }
    }

    func reloadData() {
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
                if theGroup?.files?.count > row {
                    if let file = theGroup?.files?.objectAtIndex(row) as? FileEntity {
                        // 根据文件的类型决定是播放视频还是现实PDF
                        if let type = file.fileType {
                            switch type {
                            case .PDF:
                                self.doShowPDF(file)

                            case .Video:
                                // 如果是从目录跳转过来的，还需要切换到分组页的相应位置
                                self.doShowVideo(file)

                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    func doShowVideo(file: FileEntity) {
        let player = AVPlayer(URL: NSURL(string: "http://192.168.144.32:8080/bpm_manager/uploadfile/527110e2fa5546c1890df9369ef036ba.mp4")!)
        let controller = AVPlayerViewController()
        controller.player = player

        presentViewController(controller, animated: true, completion: { () -> Void in

            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                player.play()
            })
        })
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

    func didSwipeUpAtController(pdfViewController: PDFViewController) {
        hideTagView(true)
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
