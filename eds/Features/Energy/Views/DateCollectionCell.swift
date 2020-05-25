//
//  EnergyDateCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class DateCollectionCell: UICollectionViewCell {

    private let valueLabel = UILabel()

    var title: String? {
        didSet {
            valueLabel.text = title
        }
    }

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                UIView.animate(withDuration: 0.5, animations: {
                    let transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    self.valueLabel.transform = transform
                    self.valueLabel.textColor = edsDefaultColor
                })
            } else {
                valueLabel.transform = .identity
                valueLabel.textColor = UIColor.label //UIColor.darkText
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        valueLabel.textColor = .label
        addSubview(valueLabel)
        valueLabel.centerInSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
