//
//  GroupTableViewCell.swift
//  pdfreader
//
//  Created by 吴向东 on 15/11/19.
//  Copyright © 2015年 MIBD. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    let defaultIcon = UIImage(named: "注册商标_淡化")
    let defaultBackgroundColor = UIColor.grayColor()

    @IBOutlet weak var topLine: UIView!

    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var tagLabel: UILabel!

    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var arrowBackground: UIImageView!

    @IBOutlet weak var shortIntroduce: UITextView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        arrowBackground.layer.cornerRadius = 5
        arrowBackground.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configWithFileEntity(data: FileEntity) {
        if let color = data.ownerGroup?.color {
            topLine.backgroundColor = color
            arrowBackground.backgroundColor = color
        }
        else {
            topLine.backgroundColor = defaultBackgroundColor
            arrowBackground.backgroundColor = defaultBackgroundColor
        }

        if let bin = data.icon?.data {
            iconView.image = UIImage(data: bin)
        }
        else {
            iconView.image = defaultIcon;
        }

        tagLabel.text = data.tag
        titleLabel.text = data.name
        shortIntroduce.text = data.introduce

    }

}
