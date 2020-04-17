//
//  HomeDeviceListHeaderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/14.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HomeDeviceListHeaderView: UIView {

    let titleLabel = UILabel()
    let closeButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init?(coder:) not completed!")
    }

    private func initViews() {
        addSubview(titleLabel)
        titleLabel.centerInSuperview()

        closeButton.tintColor = .systemGray
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        addSubview(closeButton)
        closeButton.width(edsIconSize)
        closeButton.height(edsIconSize)
        closeButton.edgesToSuperview(excluding: .leading, insets: .uniform(edsMinSpace))
    }

}
