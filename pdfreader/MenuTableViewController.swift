//
//  MenuTableViewController.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/17.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewController: UITableViewController {

    static let notificationKeyForPDF = "用户在menu上点击cell"
    static let notificationKeyForIndexPath = "indexPathKey"

    static let buttonTagBase = 456

    var root: TreeEntity? {
        return appDelegate.root
    }

    var appDelegate: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    var managedContext: NSManagedObjectContext {
        return appDelegate.managedObjectContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        reloadData()

        tableView.tableFooterView = UIView()


        // 注册全局通知监听menu的更新
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadData"), name: AppDelegate.menuUpdatedNotificationKey, object: nil)
    }

    func reloadData() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.checkResult()
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let count = self.root?.groups?.count {
            return count
        }
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let group = self.root?.groups?.objectAtIndex(section) as? GroupEntity {
            if let count = group.files?.count {
                return count
            }
        }

        return 0
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let width = tableView.bounds.size.width

        let sectionHeader = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 55))
        sectionHeader.backgroundColor = UIColor(white: 240.0/255.0, alpha: 1.0)

        let theGroup = self.groupForSection(section)!

        let line = UIView(frame: CGRect(x: 10.0, y: 0.0, width: (width - 20.0), height: 3.0))
        line.backgroundColor = theGroup.color

        let label = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: width, height: 60.0))
        label.text = theGroup.name
        label.backgroundColor = UIColor.clearColor()
        label.font = label.font.fontWithSize(20.0)

        let image = UIImage(named: "arrow")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 346.0, y: 13.0, width: 35.0, height: 35.0)

        // 点击的按钮
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: sectionHeader.bounds.size.height))
        button.addTarget(self, action: Selector("headerClickAction:"), forControlEvents: .TouchUpInside)
        button.tag = MenuTableViewController.buttonTagBase + section

        sectionHeader.addSubview(line)
        sectionHeader.addSubview(label)
        sectionHeader.addSubview(imageView)
        sectionHeader.addSubview(button)

        imageView.contentMode = .Center
        imageView.backgroundColor = theGroup.color
        imageView.layer.cornerRadius = 5.0

        return sectionHeader
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath)

        // Configure the cell...

        if let file = fileForIndexPath(indexPath) {
            if let name = file.name {
                if let tag = file.tag {
                    cell.textLabel?.text = "\(name) · \(tag)"
                }
                else {
                    cell.textLabel?.text = "\(name)"
                }
                return cell
            }
        }

        cell.textLabel?.text = ""

        return cell
    }

    func headerClickAction(button: UIButton) {
        let indexPath = NSIndexPath(forRow: -1, inSection: (button.tag - MenuTableViewController.buttonTagBase))
        NSNotificationCenter.defaultCenter().postNotificationName(MenuTableViewController.notificationKeyForPDF, object: self, userInfo:[MenuTableViewController.notificationKeyForIndexPath: indexPath] )
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 发布全局通知
        NSNotificationCenter.defaultCenter().postNotificationName(MenuTableViewController.notificationKeyForPDF, object: self, userInfo:[MenuTableViewController.notificationKeyForIndexPath: indexPath] )
    }

    func groupForSection(section: Int) ->GroupEntity? {
        if let group = root?.groups?.objectAtIndex(section) {
            return group as? GroupEntity
        }

        return nil
    }

    func fileForIndexPath(indexPath: NSIndexPath) -> FileEntity? {
            let theGroup = self.groupForSection(indexPath.section)
            if let file = theGroup?.files?.objectAtIndex(indexPath.row) {
                return file as? FileEntity
            }
        return nil
    }

    private func checkResult() {

        print("checkResult")

        if let theGroups = self.root?.groups {
            for group in theGroups {
                let theGroup = group as! GroupEntity
                //                print("group[\(theGroup.name), \(theGroup.files)]")
                print("列表中：[\(theGroup.name)]")

                if let theFiles = theGroup.files {
                    for file in theFiles {
                        let theFile = file as! FileEntity
                        print("    File:\(theFile.name)")
                    }
                }
            }
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
