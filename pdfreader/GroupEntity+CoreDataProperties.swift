//
//  GroupEntity+CoreDataProperties.swift
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

extension GroupEntity {

    @NSManaged var groupID: String?
    @NSManaged var colorRed: NSNumber?
    @NSManaged var name: String?
    @NSManaged var nameInEnglish: String?
    @NSManaged var colorBlue: NSNumber?
    @NSManaged var colorGreen: NSNumber?
    @NSManaged var colorAlpha: NSNumber?
    @NSManaged var files: NSOrderedSet?
    @NSManaged var root: TreeEntity?

}
