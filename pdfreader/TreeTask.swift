//
//  TreeTask.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/18.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit
import CoreData

class TreeTask {

    static let defaultString = "http://192.168.144.45:8080/bpm_wechat/bpmclient/getFileInfo.json"

    let serverURL: NSURL = NSURL(string: TreeTask.defaultString)!

    static let menuUpdatedNotificationKey = "目录数据已经更新"

    init() {
        queue = NSOperationQueue()
        queue.name = "目录信息后台"
    }

    func fetch() {

        let fetchOpreation = fetchDataOpreation
        let jsonParse = jsonParseOpreation
        let emptyTreeMake = emptyTreeMakeOperation
        let groupsMake = groupsMakeOperation
        let filesMake = filesMakeOperation

        let cacheOpreation = NSBlockOperation { () -> Void in
            self.saveContext()
            self.cacheBinarysInTree()
        }

        jsonParse.addDependency(fetchOpreation)
        emptyTreeMake.addDependency(jsonParse)
        groupsMake.addDependency(emptyTreeMake)
        filesMake.addDependency(groupsMake)
        cacheOpreation.addDependency(filesMake)

        queue.addOperation(fetchOpreation)
        queue.addOperation(jsonParse)
        queue.addOperation(emptyTreeMake)
        queue.addOperation(groupsMake)
        queue.addOperation(filesMake)
        queue.addOperation(cacheOpreation)

    }
    var root: TreeEntity?

    private var queue: NSOperationQueue!

    private var jsonObject: [String :AnyObject?]?
    private var receivedData: NSData?

    lazy var context: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let coordinator = appDelegate.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    func saveContext () {

        queue.addOperationWithBlock { () -> Void in
            if self.context.hasChanges {
                do {
                    try self.context.save()

                    // 发送全局通知，通知数据已经更新
                    NSNotificationCenter.defaultCenter().postNotificationName(PDFFileManager.menuUpdatedNotificationKey, object: self)

                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
        }
    }

    private var reportOperation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            print("缓冲完成")
            // 发送全局通知，通知数据已经更新
            NSNotificationCenter.defaultCenter().postNotificationName(TreeTask.menuUpdatedNotificationKey, object: self)
        })
    }

//    MARK: - 相关操作
    private func cacheBinarysInTree() {

        if let bins = root?.caches {
            let report = reportOperation
            for entity in bins {
                let binEntity = entity as! BinaryEntity
                let cacheOperation = binaryDownloadOpreationForEntity(binEntity)

                // 回报操作要依赖于所有的缓冲操作完成
                report.addDependency(cacheOperation)
                self.queue.addOperation(cacheOperation)
            }
            self.queue .addOperation(report)
        }
    }

    private var fetchDataOpreation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            self.receivedData = NSData(contentsOfURL: self.serverURL)
        })
    }

    private var jsonParseOpreation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            if let data = self.receivedData {
                do {
                    let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    self.jsonObject = jsonObj["result"] as! [String:AnyObject]
                } catch {}
            }
        })
    }

    private var groupsMakeOperation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in

            if let root = self.root {
                let json = self.jsonObject!
                if let groupInfos = json["groups"] as? [[String: AnyObject]] {
                    _ = groupInfos.map({ (groupInfo: [String: AnyObject]) -> GroupEntity in
                        let group = NSEntityDescription.insertNewObjectForEntityForName("GroupEntity", inManagedObjectContext: self.context) as! GroupEntity
                        group.configWithDictionary(groupInfo)
                        group.root = root
                        return group
                    })
                }
            }
        })
    }

    private var filesMakeOperation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            // 创建文件数组

            if let root = self.root {
                // root 存在则json必然存在
                let json = self.jsonObject!

                if let fileInfos = json["files"] as? [[String: AnyObject]] {
                    _ = fileInfos.map({ (info: [String : AnyObject]) -> FileEntity in
                        let newFile = NSEntityDescription.insertNewObjectForEntityForName("FileEntity", inManagedObjectContext: self.context) as! FileEntity
                        newFile.configWithDictionary(info)

                        let groupID = info["filemoduleid"] as! String

                        newFile.ownerGroup = root.groupWithID(groupID)

                        // 建立缓冲的二进制数据
                        let iconURLString = info["fileimageurl"] as! String
                        let icon = self.fetchOrCreateBinaryEntityForURL(iconURLString)
                        newFile.icon = icon;
                        icon.root = root


                        let dataURLString = info["fileurl"] as! String
                        let data = self.fetchOrCreateBinaryEntityForURL(dataURLString)
                        newFile.data = data
                        data.root = root
                        
                        return newFile
                    })
                }
            }
        })
    }

    private func binaryDownloadOpreationForEntity(bin: BinaryEntity) ->NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            if let _ = bin.data {
                // 已经存在缓冲数据
                return
            }

            if let url = NSURL(string: bin.remoteURL!) {
                if let data = NSData(contentsOfURL: url) {
                    bin.data = data

                    print("下载完成：\(bin.remoteURL)")

                    do {
                        try self.context.save()
                    } catch {
                        NSLog("保存数据出错")
                    }
                }
            }
        })
    }

    private var emptyTreeMakeOperation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            if let jsonObj = self.jsonObject {
                // 生成新的根
                let newRoot = NSEntityDescription.insertNewObjectForEntityForName("TreeEntity", inManagedObjectContext: self.context) as! TreeEntity

                newRoot.timeStamp = jsonObj["edate"] as? String
                newRoot.refreshTime = NSDate()
                
                self.root = newRoot
            }
        })
    }

    // MARK: - 关于文件缓冲的操作
    private func binaryForURL(urlString: String) ->BinaryEntity? {
        let request = NSFetchRequest(entityName: "BinaryEntity")
        request.predicate = NSPredicate(format: "remoteURL = %@", urlString)
        request.sortDescriptors = [NSSortDescriptor(key: "remoteURL", ascending: false)]

        do {
            let result = try context.executeFetchRequest(request)
            return result.first as? BinaryEntity
        } catch {
            return nil
        }
    }

    private func fetchOrCreateBinaryEntityForURL(urlString: String) -> BinaryEntity! {
        if let old = binaryForURL(urlString) {
            return old
        }
        else {
            let newBin = NSEntityDescription.insertNewObjectForEntityForName("BinaryEntity", inManagedObjectContext: context) as! BinaryEntity
            newBin.remoteURL = urlString
            return newBin
        }
    }
}
