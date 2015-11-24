//
//  TreeTask.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/18.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit
import CoreData

protocol TreeTaskDelegate : NSObjectProtocol {
    func taskDidFinishedMenu(task: TreeTask)
    func taskDidFinishedCache(task: TreeTask)
    func binaryDownloadStatusDidChanged(task: TreeTask)
}

class TreeTask: NSObject, NSURLSessionDelegate {

    static let defaultString = "http://192.168.144.45:8080/bpm_wechat/bpmclient/getFileInfo.json"

    let serverURL: NSURL = NSURL(string: TreeTask.defaultString)!

    weak var delegate: TreeTaskDelegate?

    var urlStringsToCached = NSMutableSet()

    var root: TreeEntity?

    private var queue: NSOperationQueue = NSOperationQueue()

    private var jsonObject: [String :AnyObject?]?
    private var receivedData: NSData?

    lazy private var downloadSession: NSURLSession = {
        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate:
            self, delegateQueue: self.queue)
    }()

    lazy var context: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let coordinator = appDelegate.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // 下载状态标示
    var downloadStaus: (done: Int, total: Int) = (0, 0) {
        didSet {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.delegate?.binaryDownloadStatusDidChanged(self)
            })
        }
    }

    func fetch() {

        let fetchOpreation = fetchDataOpreation
        let jsonParse = jsonParseOpreation
        let emptyTreeMake = emptyTreeMakeOperation
        let groupsMake = groupsMakeOperation
        let filesMake = filesMakeOperation

        let cacheOpreation = NSBlockOperation { () -> Void in
            self.saveContext()

            // 通知委托者，目录结构生成完毕
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.delegate?.taskDidFinishedMenu(self)
            })

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


    func saveContext () {

        if self.context.hasChanges {
            do {
                try self.context.save()

            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }

    }

    private func downloadTaskForURL(url: NSURL) -> NSURLSessionTask {
        return downloadSession.downloadTaskWithURL(url, completionHandler: { (localURL, response, error) -> Void in
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {

                    if let theURLForData = localURL {
                        let urlString: String! = url.description
                        let request = NSFetchRequest(entityName: "BinaryEntity")
                        request.predicate = NSPredicate(format: "remoteURL = %@", urlString)
                        request.sortDescriptors = [NSSortDescriptor(key: "remoteURL", ascending: true)]

                        do {
                            let results = try self.context.executeFetchRequest(request)
                            for entity in results {
                                let bin = entity as! BinaryEntity
                                bin.data = NSData(contentsOfURL: theURLForData)

                                NSLog("保存：【%@】", urlString)
                            }

                            ++self.downloadStaus.done

                            self.saveContext()
                        } catch {
                            NSLog("缓冲失败：【%@】", url)
                        }
                    }
                }
            }
        })
    }

    private var reportOperation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.delegate?.taskDidFinishedCache(self)
            })
        })
    }

//    MARK: - 相关操作
    private func cacheBinarysInTree() {

        self.downloadStaus = (0, self.urlStringsToCached.count)

        for urlString in urlStringsToCached {
            let theString = urlString as! String
            let url = NSURL(string: theString)!
            let task = self.downloadTaskForURL(url)
            task.resume()
        }
        
        downloadSession.finishTasksAndInvalidate()
    }

    private var fetchDataOpreation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            self.receivedData = NSData(contentsOfURL: self.serverURL)
        })
    }

    private var jsonParseOpreation: NSBlockOperation {
        return NSBlockOperation(block: { () -> Void in
            if let data = self.receivedData {
                let string = String(data: data, encoding: NSUTF8StringEncoding)
                print(string)
                do {
                    let jsonObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    if let receivedResult = jsonObj["result"] {
                        self.jsonObject = receivedResult as! [String:AnyObject]
                    }

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


                        let dataURLString = info["fileurl"] as! String
                        let data = self.fetchOrCreateBinaryEntityForURL(dataURLString)
                        newFile.data = data
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
                self.downloadStaus = (self.downloadStaus.done + 1, self.downloadStaus.total)
                return
            }

            if let url = NSURL(string: bin.remoteURL!) {

                if let data = NSData(contentsOfURL: url) {
                    bin.data = data

//                    print("下载完成：\(bin.remoteURL)")

                    do {
                        try self.context.save()
                        self.downloadStaus = (self.downloadStaus.done + 1, self.downloadStaus.total)
                        print("下载：【\(self.downloadStaus)】-> \(bin.remoteURL)")
                    } catch {
                        NSLog("保存数据出错：\(bin.remoteURL)")
                        let nserror = error as NSError
                        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
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
            if old.data == nil {
                if let remoteURL = old.remoteURL {
                    self.urlStringsToCached.addObject(remoteURL)
                }
            }
            return old
        }
        else {
            let newBin = NSEntityDescription.insertNewObjectForEntityForName("BinaryEntity", inManagedObjectContext: context) as! BinaryEntity
            newBin.remoteURL = urlString

            // 记录下所有没有缓冲过的URL
            self.urlStringsToCached.addObject(urlString)
            return newBin
        }
    }

//    MARK: - 下载task的回调处理
    @objc func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {

        NSLog("处理结束\(self.downloadStaus)")

        // 进入这个函数意味着所有的task已经处理结束，而且回调也已经处理结束
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.delegate?.taskDidFinishedCache(self)
        })
    }

    @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        // 没什么要做的吧？
        NSLog("进入challenge：【%@】", challenge)
    }

    @objc func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        // 不应该引入到这里
        NSLog("进入URLSessionDidFinishEventsForBackgroundURLSession：【%@】", session)
    }
}
