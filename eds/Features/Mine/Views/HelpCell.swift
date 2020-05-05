//
//  HelpCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/5.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HelpCell: UITableViewCell {

    let typeImage = UIImageView()
    let nameLabel = UILabel()
    let sizeLabel = UILabel()

    var help: Help? {
        didSet {
            guard let help = self.help else {
                return
            }
            typeImage.image = help.type.getIcon()
            nameLabel.text = help.name
            sizeLabel.text = help.size
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        typeImage.image = UIImage(systemName: "doc")
        typeImage.contentMode = .scaleAspectFit
        addSubview(typeImage)
        typeImage.width(edsHeight)
        typeImage.height(edsHeight)
        typeImage.leadingToSuperview(offset: edsSpace)
        typeImage.verticalToSuperview(insets: .vertical(edsSpace))

        nameLabel.text = "helpEDS".localize()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        addSubview(nameLabel)
        nameLabel.leadingToTrailing(of: typeImage, offset: edsSpace)
        nameLabel.centerY(to: typeImage)

        sizeLabel.text = "1.0M"
        sizeLabel.textColor = .systemGray
        addSubview(sizeLabel)
        sizeLabel.trailingToSuperview(offset: edsSpace)
        sizeLabel.centerY(to: typeImage)
        sizeLabel.leadingToTrailing(of: nameLabel, offset: -edsSpace, relation: .equalOrLess)
    }

}
