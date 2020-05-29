//
//  HomeEnergyView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HomeEnergyView: UIView {

    let nameLabel = UILabel()
    private let valueLabel = UILabel()
    

    var valueFont = UIFont.preferredFont(forTextStyle: .title1)
    var value: String = "0" {
        didSet {
            let attrText = NSMutableAttributedString(string: value, attributes: [
                NSAttributedString.Key.foregroundColor: tintColor as Any,
                NSAttributedString.Key.font: valueFont
            ])
            attrText.append(NSAttributedString(string: " kW.h", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.systemGray,
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]))
            valueLabel.attributedText = attrText
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

        tintColor = .white

//        backgroundColor = .systemGray5
        nameLabel.textColor = edsDivideColor
        addSubview(nameLabel)
        nameLabel.leadingToSuperview()
        nameLabel.centerYToSuperview()

        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.textAlignment = .left
        addSubview(valueLabel)
        valueLabel.leadingToTrailing(of: nameLabel, offset: edsMinSpace)
        valueLabel.trailingToSuperview()
        valueLabel.verticalToSuperview()
    }

}
