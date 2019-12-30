//
//  DeviceTextCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/18.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Deviced文字显示（状态背景渐变）：init>backgroundGradientColor>valueLabel

import UIKit

class DeviceTextCell: UITableViewCell {

    private let space: CGFloat = 20

    var valueLabel = UILabel()

    var backgroundGradientColor: UIColor? {
        didSet {
            if let color = backgroundGradientColor {
                //当添加背景色时，文本颜色变为白色更直观
                gradientLayer.setHorCenterGradientLayer(centerColor: color)
                valueLabel.textColor = .white
            }
        }
    }

    private var gradientLayer = CAGradientLayer()

    fileprivate func initViews() {
        //自适应字体大小
        valueLabel.font = valueLabel.font.withSize(80)
        valueLabel.text = "100"
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 1
        addSubview(valueLabel)
        valueLabel.horizontalToSuperview(insets: .horizontal(space))
        valueLabel.heightToSuperview()

        //添加渐变层,默认透明
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        //渐变层添加时frame(0,0,0,0),CAGradientLayer不能使用约束
        gradientLayer.frame = rect
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

