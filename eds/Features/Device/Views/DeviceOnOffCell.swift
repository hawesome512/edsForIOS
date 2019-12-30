//
//  DeviceOnOffCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/17.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device功能保护开关onoff样式:init>change ui

import UIKit

class DeviceOnOffCell: UITableViewCell {

    private let space: CGFloat = 20

    var nameLabel = UILabel()
    var valueSwitch = UISwitch()

    fileprivate func initViews() {
        // Initialization code
        nameLabel.text = "短路保护"
        nameLabel.textColor = UIColor.systemBlue
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        addSubview(nameLabel)
        nameLabel.centerYToSuperview()
        nameLabel.leadingToSuperview(offset: space)

        valueSwitch.isOn = false
        addSubview(valueSwitch)
        valueSwitch.centerYToSuperview()
        valueSwitch.trailingToSuperview(offset: space)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
