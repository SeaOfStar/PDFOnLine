//
//  BinaryEntity+CoreDataProperties.swift
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

extension BinaryEntity {

    @NSManaged var data: NSData?
    @NSManaged var remoteURL: String?
    @NSManaged var filesData: NSSet?
    @NSManaged var filesIcon: NSSet?
    @NSManaged var roots: NSSet?

}
