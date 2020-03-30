//
//  SectionView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {

    private let label = UILabel()

    var title: String? {
        didSet {
            label.text = title
        }
    }

    private func initViews() {
        backgroundColor = edsDivideColor
        addSubview(label)
        label.edgesToSuperview(insets: .uniform(edsMinSpace))
        label.font=UIFont.preferredFont(forTextStyle: .headline)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
