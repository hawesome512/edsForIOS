//
//  CardItemButton.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/28.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class CardItemButton: UIButton {
    
    let iconImage = UIImageView()
    let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        addSubview(iconImage)
        iconImage.width(edsIconSize)
        iconImage.height(edsIconSize)
        iconImage.centerInSuperview(offset:CGPoint(x: -edsIconSize/2-edsMinSpace, y: 0))
        
        valueLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        valueLabel.textColor = .white
        addSubview(valueLabel)
        valueLabel.centerInSuperview(offset: CGPoint(x: edsMinSpace, y: 0))
        
        let line = UIView()
        line.backgroundColor = .systemGray
        addSubview(line)
        line.height(1)
        line.edgesToSuperview(excluding: .bottom)
    }
    
}
