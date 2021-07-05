//
//  HomeFooterCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/30.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HomeFooterCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = edsDivideColor
        let imageView = UIImageView()
        imageView.image = UIImage(named: "home_footer")
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.edgesToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
