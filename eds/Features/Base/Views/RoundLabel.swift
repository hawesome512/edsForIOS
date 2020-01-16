//
//  RoundLabel.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class RoundLabel: UILabel {

    var innerText: String? {
        didSet {
            if let innerText = innerText {
                //圆角时，水平方向缩进两个空格，避免被圆角切割
                text = "  \(innerText)  "
                layoutIfNeeded()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        //必须添加父类draw，否则text不显示
        super.draw(rect)
        layer.cornerRadius = rect.height / 2
    }

}
