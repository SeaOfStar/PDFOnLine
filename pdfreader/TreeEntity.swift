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
            print("\(group.groupID)  <---> \(groupID)")
            return group.groupID == groupID
        })

        // 返回第一个
        if let first = filtedGroup?.first as? GroupEntity {
            return first
        }

        return nil
    }

}
