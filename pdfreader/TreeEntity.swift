//
//  TreeEntity.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/16.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import Foundation
import CoreData


class TreeEntity: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func groupWithID(groupID: String) -> GroupEntity? {

        // 根据group进行检索
        let filtedGroup = self.groups?.filter({ (element) -> Bool in
            let group = element as! GroupEntity
            return group.groupID == groupID
        })

        // 返回第一个
        if let first = filtedGroup?.first as? GroupEntity {
            return first
        }

        return nil
    }


    func indexPathForFile(targetFile: FileEntity) -> NSIndexPath? {

        var result:NSIndexPath?

        if let groups = self.groups {
            groups.enumerateObjectsUsingBlock({ (group, groupIndex, stop) -> Void in
                let theGroup = group as! GroupEntity
                if let files = theGroup.files {
                    files.enumerateObjectsUsingBlock({ (file, fileIndex, fileStop) -> Void in
                        let theFile = file as! FileEntity
                        if theFile.fileID == targetFile.fileID {
                            result = NSIndexPath(forRow: fileIndex, inSection: groupIndex)
                        }
                    })
                }
            })
        }

        return result
    }

    func binEntityForURLString(url: String) -> BinaryEntity? {
        if let context = self.managedObjectContext {
            // 不直接查找内容，检索数据库，节省内存使用量
            let request = NSFetchRequest(entityName: "BinaryEntity")
            request.predicate = NSPredicate(format: "remoteURL = %@", url)
            request.sortDescriptors = [NSSortDescriptor(key: "remoteURL", ascending: true)]

            do {
                let result = try context.executeFetchRequest(request)
                return result.first as? BinaryEntity
            } catch {
                return nil
            }
        }

        return nil
    }

}
