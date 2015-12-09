//
//  FileEntity.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/16.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import Foundation
import CoreData


class FileEntity: NSManagedObject {

    enum FileType: String {
        case PDF = "pdf"
        case Video = "video"
        case Unknown = ""
    }

// Insert code here to add functionality to your managed object subclass

    var fileType: FileType? = .Unknown

    func configWithDictionary(dataSource: [String: AnyObject]) {
        self.fileID = dataSource["fileid"] as? String
        self.name = dataSource["filename"] as? String
        self.introduce = dataSource["filemessage"] as? String
        self.tag = dataSource["filetag"] as? String
        self.fileTypeString = dataSource["filetype"] as? String
        if let typeString = fileTypeString {
            self.fileType = FileType(rawValue: typeString)
        }

        NSLog("string：\(fileTypeString), value: \(fileType)")
    }

    private var sortedAllFiles: [FileEntity] {
        let root = self.ownerGroup!.root!

        // 最暴力也是最简单的方法，所有人出来排队啦~~~
        var allFiles: [FileEntity] = []

        for group in root.groups! {
            let theGroup = group as! GroupEntity

            if let files = theGroup.files {
                let theFiles = files.array as! [FileEntity]
                allFiles.appendContentsOf(theFiles)
            }
        }

        return allFiles
    }

    var nextFile: FileEntity? {

        let all = sortedAllFiles

        let index = all.indexOf(self)!
        if index < (all.count - 1) {
            return all[index + 1]
        }

        return nil
    }

    var lastFile: FileEntity? {
        let all = sortedAllFiles

        let index = all.indexOf(self)!
        if index > 0 {
            return all[index - 1]
        }
        return nil
    }

}
