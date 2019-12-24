//
//  DeviceButtonCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/16.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device的按键控制，一行建议最多3个按键，超出时用多行row处理：init>items(addButtons)

import UIKit

class DeviceButtonCell: UITableViewCell {

    private let space: CGFloat = 20

    // MARK: 外部设置
    //items格式：["ON_AAAA_red","OFF_5555_green"]
    //cell在滚动时会频繁实例cell，判断count!=0时，不新增button
    var items: [String] = [] {
        didSet {
            if buttons.count == 0 {
                initViews()
            }
        }
    }

    private var buttons = [UIButton]()

    fileprivate func initViews() {
        //Add buttons by items
        items.forEach { item in
            let infos = item.components(separatedBy: "_")
            if infos.count == 3 {
                let button = UIButton()
                button.backgroundColor = UIColor.init(colorName: infos[2])
                button.tintColor = UIColor.white
                button.setTitle(infos[0], for: .normal)
                button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
                addSubview(button)
                buttons.append(button)
            }
        }
        //Add Constraints
        if let superView = buttons.first?.superview {
            //CGFloat方便下面的“宽”的计算公式
            let count = CGFloat( buttons.count)
            for index in 0..<buttons.count {

                let button = buttons[index]
                button.translatesAutoresizingMaskIntoConstraints = false

                let top = button.topAnchor.constraint(equalTo: superView.topAnchor, constant: space)
                let bottom = button.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -space)

                //宽：[width-space*(n+1)]/n,注意constant设置负数
                let ratio = 1 / count
                let widthConstant = (count + 1) / count * space
                let width = button.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: ratio, constant: -widthConstant)

                //水平间距约束：space
                let xAxisAnchor = index == 0 ? superView.leadingAnchor : buttons[index - 1].trailingAnchor
                let leading = button.leadingAnchor.constraint(equalTo: xAxisAnchor, constant: space)
                NSLayoutConstraint.activate([top, bottom, leading, width])
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
