//
//  TreeEntity+CoreDataProperties.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/17.
//  Copyright © 2015年 MIBD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TreeEntity {

    @NSManaged var updateTime: NSDate?
    @NSManaged var groups: NSOrderedSet?

}
