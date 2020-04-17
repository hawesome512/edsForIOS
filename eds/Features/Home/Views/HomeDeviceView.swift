//
//  HomeDeviceView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HomeDeviceView: UIButton {

    let nameLabel = UILabel()
    let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        nameLabel.textAlignment = .center
        nameLabel.textColor = edsDivideColor
        addSubview(nameLabel)
        nameLabel.edgesToSuperview(excluding: .bottom)
        nameLabel.heightToSuperview(multiplier: 0.3)

        valueLabel.text = "0"
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center
        valueLabel.clipsToBounds = true
        valueLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        addSubview(valueLabel)
        valueLabel.widthToHeight(of: valueLabel)
        valueLabel.bottomToSuperview()
        valueLabel.topToBottom(of: nameLabel, offset: edsMinSpace)
        valueLabel.centerXToSuperview()
    }

    override func draw(_ rect: CGRect) {
        valueLabel.layer.cornerRadius = valueLabel.bounds.height / 2
    }

}
