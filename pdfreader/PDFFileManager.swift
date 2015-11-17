//
//  PDFFileManager.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/16.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit
import CoreData

class PDFFileManager: NSObject {

    let serverURL = "http://192.168.144.46:8080/bpm_wechat/bpmclient/getFileInfo.json"

    lazy var queue: NSOperationQueue = NSOperationQueue()

    lazy var context: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let coordinator = appDelegate.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    func checkUpdate() {

        if queue.operations.isEmpty {
            queue.addOperationWithBlock {
                self.doCheckUpdate()
            }
        }
    }

    var root: TreeEntity? {
        didSet {
            self.lastUpdateTime = root?.timeStamp
        }
    }

    var lastUpdateTime: String?

    private func doCheckUpdate() {
        // 检查是否有新数据

        let url = NSURL(string: serverURL)

        if let jsonData = NSData(contentsOfURL: url!) {

            do {
                let jsonObj = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
//                print(jsonObj)
                queue.addOperationWithBlock({ () -> Void in
                    let result = jsonObj["result"] as! [String:AnyObject]
                    self.checkNewData(result)
                })
            } catch {
                print("json 解析出错")
            }
        }
        else {
            print("网络通信出错")
        }
    }

    private func checkNewData(data: [String:AnyObject]) {


        if let last = lastUpdateTime {
            if let time = data["edate"] {
                if time as! String == last {
                    print("不需要更新！")

                    return
                }
            }
        }

        // 插入新的数据
        queue.addOperationWithBlock { () -> Void in
            self.insertNewRoot(data)
        }
    }

    private func insertNewRoot(data: [String:AnyObject]) {
        let privateContext = self.context

        // 生成新的根
        let newRoot = NSEntityDescription.insertNewObjectForEntityForName("TreeEntity", inManagedObjectContext: privateContext) as! TreeEntity

        newRoot.timeStamp = data["edate"] as? String
        newRoot.refreshTime = NSDate()

        // 创建group数组
        if let groupInfos = data["groups"] as? [[String: AnyObject]] {
            _ = groupInfos.map({ (groupInfo: [String: AnyObject]) -> GroupEntity in
                let group = NSEntityDescription.insertNewObjectForEntityForName("GroupEntity", inManagedObjectContext: privateContext) as! GroupEntity
                group.configWithDictionary(groupInfo)
                group.root = newRoot
                return group
            })
        }

        // 创建文件数组
        if let fileInfos = data["files"] as? [[String: AnyObject]] {
            _ = fileInfos.map({ (info: [String : AnyObject]) -> FileEntity in
                let newFile = NSEntityDescription.insertNewObjectForEntityForName("FileEntity", inManagedObjectContext: privateContext) as! FileEntity
                newFile.configWithDictionary(info)

                let groupID = info["filemoduleid"] as! String

                newFile.ownerGroup = newRoot.groupWithID(groupID)

                return newFile
            })
        }

        self.root = newRoot

        // 检查数据的结果
        checkResult()
    }

    private func checkResult() {
        if let theGroups = self.root!.groups {
            for group in theGroups {
                let theGroup = group as! GroupEntity
                //                print("group[\(theGroup.name), \(theGroup.files)]")
                print("group[\(theGroup.name)]")

                if let theFiles = theGroup.files {
                    for file in theFiles {
                        let theFile = file as! FileEntity
                        print("    File:\(theFile.name)")
                    }
                }
            }
        }
    }
}


