//
//  DeviceInfoCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/1.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  设备静态信息单元格

import UIKit

class FixedInfoCell: UITableViewCell {

    var nameLabel = UILabel()
    var valueLabel = UILabel()
    private let preferredFont = UIFont.preferredFont(forTextStyle: .title3)

    fileprivate func initViews() {
        //cell右边icon样式“>"
        accessoryType = .disclosureIndicator

        nameLabel.textColor = edsDefaultColor
        nameLabel.font = preferredFont
        contentView.addSubview(nameLabel)
        nameLabel.centerYToSuperview()
//        nameLabel.verticalToSuperview(insets:.vertical(edsSpace))
        nameLabel.leadingToSuperview(offset: edsSpace)
        valueLabel.font = preferredFont
        contentView.addSubview(valueLabel)
        valueLabel.centerYToSuperview()
        //因cell右边存在accessoryType，space*2,避免其被覆盖
        valueLabel.trailingToSuperview(offset: edsMinSpace)
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
