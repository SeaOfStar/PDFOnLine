//
//  FileEntity+CoreDataProperties.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/16.
//  Copyright © 2015年 MIBD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FileEntity {

    @NSManaged var name: String?
    @NSManaged var tag: String?
    @NSManaged var iconURL: String?
    @NSManaged var icon: NSData?
    @NSManaged var dataURL: String?
    @NSManaged var data: NSData?
    @NSManaged var fingerprint: String?
    @NSManaged var fileID: String?
    @NSManaged var ownerGroup: GroupEntity?

}
