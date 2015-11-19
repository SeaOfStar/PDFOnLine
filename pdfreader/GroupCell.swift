//
//  GroupCell.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/13.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class GroupCell: UICollectionViewCell {
    
    @IBOutlet weak var topColorLine: UIView!
    @IBOutlet weak var EnglishTitle: UILabel!
    @IBOutlet weak var ChineseTitle: UILabel!

    var userSelected: Bool = false {
        didSet {
            self.backgroundColor = userSelected ? self.topColorLine.backgroundColor : UIColor.clearColor()
        }
    }

}
