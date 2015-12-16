//
//  BinaryEntity.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/17.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class BinaryEntity: NSManagedObject {

    static let subpathName = "videoCache"

    var fullURL: NSURL? {
        if let urlString = localURL {
            return BinaryEntity.cachePath.URLByAppendingPathComponent(urlString)
        }
        return nil
    }

    var data: NSData? {
        if let theFullURL = fullURL {
            return NSData(contentsOfURL: theFullURL)
        }
        return nil
    }

    class var cachePath: NSURL {
        let dictionary = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        let pathURL = dictionary!.URLByAppendingPathComponent(BinaryEntity.subpathName, isDirectory: true)
        return pathURL
    }

// Insert code here to add functionality to your managed object subclass
    func saveToLocalFile(tempURL: NSURL) {

        let manager = NSFileManager.defaultManager()
        let fileName = randomUUIDName()
        let fileURL = BinaryEntity.cachePath.URLByAppendingPathComponent(fileName, isDirectory: false)

        // 判断目录是否存在
        // 创建相应的目录
        do {
            // copy 文件
            try manager.copyItemAtURL(tempURL, toURL: fileURL)
            localURL = fileName
        } catch {
            NSLog("创建文件失败：【\(fileURL)】")
        }

    }

    func saveLocalFile(tempURL: NSURL) {

    }

    private func randomUUIDName() ->String {

        // 根据远程URL的扩展名确定本地文件的扩展名
        if let remoteString = remoteURL {
            let url = NSURL(string: remoteString)
            if let extern = url?.pathExtension {
                return NSUUID().UUIDString + "." + extern
            }
        }

        return NSUUID().UUIDString
    }
}
