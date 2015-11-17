//
//  GroupEntity.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/16.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class GroupEntity: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    var color :UIColor? {
        get {
            if let r = colorRed?.doubleValue {
                if let g = colorGreen?.doubleValue {
                    if let b = colorBlue?.doubleValue {
                        if let a = colorAlpha?.doubleValue {
                            return UIColor(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(a / 255.0))
                        }
                    }
                }
            }
            return nil
        }
    }

    func configWithDictionary(dataSource: [String: AnyObject]) {
        self.groupID = dataSource["groupid"] as? String

        self.name = dataSource["groupname"] as? String
        self.nameInEnglish = dataSource["groupenglishname"] as? String

        self.colorRed = dataSource["modulercolor"] as? Int
        self.colorGreen = dataSource["modulegcolor"] as? Int
        self.colorBlue = dataSource["modulebcolor"] as? Int
        self.colorAlpha = dataSource["moduleacolor"] as? Int
    }
}
