//
//  FileEntity+CoreDataProperties.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/18.
//  Copyright © 2015年 MIBD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FileEntity {

    @NSManaged var fileID: String?
    @NSManaged var introduce: String?
    @NSManaged var name: String?
    @NSManaged var tag: String?
    @NSManaged var data: BinaryEntity?
    @NSManaged var icon: BinaryEntity?
    @NSManaged var ownerGroup: GroupEntity?

}
