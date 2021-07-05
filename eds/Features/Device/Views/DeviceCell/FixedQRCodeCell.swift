//
//  QRCodeCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/6.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  二维码

import UIKit

class FixedQRCodeCell: UITableViewCell {

    let qrImageView = UIImageView()

    private func initViews() {
        qrImageView.contentMode = .scaleAspectFit
        contentView.addSubview(qrImageView)
        qrImageView.width(240)
        qrImageView.height(240)
        qrImageView.edgesToSuperview(insets: .uniform(edsSpace))
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
