//
//  DeviceDefaultCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/17.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device默认显示样式：实时之item,参数之list:init>value

import UIKit

class DeviceDefaultCell: UITableViewCell {

    private let space: CGFloat = 20
    private let preferredFont = UIFont.preferredFont(forTextStyle: .title3)

    var nameLabel = UILabel()
    var valueLabel = UILabel()

    fileprivate func initViews() {
        //cell右边icon样式“>"
        accessoryType = .disclosureIndicator

        nameLabel.text = "短路短延时(s)"
        nameLabel.textColor = UIColor.systemBlue
        nameLabel.font = preferredFont
        addSubview(nameLabel)
        nameLabel.centerYToSuperview()
        nameLabel.leadingToSuperview(offset: space)

        valueLabel.text = "1000"
        valueLabel.font = preferredFont
        addSubview(valueLabel)
        valueLabel.centerYToSuperview()
        valueLabel.trailingToSuperview(offset: space)
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
