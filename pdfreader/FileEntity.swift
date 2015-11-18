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

// Insert code here to add functionality to your managed object subclass

    func configWithDictionary(dataSource: [String: AnyObject]) {
        self.fileID = dataSource["fileid"] as? String
        self.name = dataSource["filename"] as? String
        self.introduce = dataSource["filemessage"] as? String
        self.tag = dataSource["filetag"] as? String
    }

}
