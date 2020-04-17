//
//  HomeChainRatioView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HomeRatioView: UIView {

    let valueLabel = UILabel()
    private let valueImage = UIImageView()
    var value: Double = 0 {
        didSet {
            valueLabel.text = value.clean + "%"
            let imageName = value > 0 ? "arrow.up" : "arrow.down"
            let imageColor = value > 0 ? UIColor.systemRed : UIColor.systemGreen
            valueImage.tintColor = imageColor
            valueImage.image = UIImage(systemName: imageName)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        valueLabel.text = "0%"
        valueLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        valueLabel.textColor = .white
        addSubview(valueLabel)
        valueLabel.centerYToSuperview()
        valueLabel.leadingToSuperview()

        valueImage.tintColor = .systemGreen
        valueImage.image = UIImage(systemName: "arrow.down")
        addSubview(valueImage)
        valueImage.edgesToSuperview(excluding: .leading)
        valueImage.leadingToTrailing(of: valueLabel)
        valueImage.width(edsIconSize)
        valueImage.height(edsIconSize)
    }

}
