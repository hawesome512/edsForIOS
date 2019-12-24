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

        valueLabel.text = "1000"
        valueLabel.font = preferredFont
        addSubview(valueLabel)

        //右边界约束：space*[-2],因要保证valuelabel与accessoryView足够的空间，使用负数而非正数值
        //此处获取accessoryView为nil,故使用superview约束
        if let superView = nameLabel.superview {
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameLabel.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
                nameLabel.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: space),
                valueLabel.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
                valueLabel.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -space * 2)
            ])
        }
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
