//
//  CornerView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/31.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class CornerView: UIView {

    var title: String? {
        didSet {
            label.text = title
        }
    }

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.contentMode = .right
        addSubview(label)
        label.topToSuperview(offset: 4)
        label.trailingToSuperview(offset: 2)
        label.widthToSuperview(multiplier: 0.5, offset: -4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func layoutSubviews() {
//        draw(bounds)
//    }

    override func draw(_ rect: CGRect) {
        let triangle = UIBezierPath()
        let start = CGPoint.zero
        triangle.move(to: start)
        triangle.addLine(to: start.offset(x: rect.width, y: 0))
        triangle.addLine(to: start.offset(x: rect.width, y: rect.height))
        edsDefaultColor.setFill()
        triangle.fill()
    }

}
