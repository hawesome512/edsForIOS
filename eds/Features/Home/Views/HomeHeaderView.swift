//
//  HomeHeaderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HomeHeaderView: UIView {

    let bannerImage = UIImageView()
    let titleLabel = UILabel()
    let locationButton = UIButton()
    let messageButton = UIButton()
    let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        bannerImage.contentMode = .scaleAspectFill
        bannerImage.image = UIImage(named: "banner")
        addSubview(bannerImage)
        bannerImage.edgesToSuperview()

        messageLabel.text = "5月1日 0:00～6:00 系统维护，部分功能将受影响！"
        messageLabel.textAlignment = .right
        messageLabel.textColor = .systemYellow
        addSubview(messageLabel)
        messageLabel.edgesToSuperview(excluding: .top, insets: .uniform(edsMinSpace))

        titleLabel.text = "厦门士林电机"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        addSubview(titleLabel)
        titleLabel.leadingToSuperview(offset: edsSpace)
        titleLabel.bottomToTop(of: messageLabel, offset: -edsMinSpace)

        locationButton.tintColor = .white
        locationButton.setBackgroundImage(UIImage(named: "location")?.withTintColor(.white), for: .normal)
        addSubview(locationButton)
        locationButton.width(edsIconSize)
        locationButton.height(edsIconSize)
        locationButton.leadingToTrailing(of: titleLabel, offset: edsMinSpace)
        locationButton.centerY(to: titleLabel)

        messageButton.setBackgroundImage(UIImage(systemName: "speaker.2"), for: .normal)
        messageButton.tintColor = .systemYellow
        addSubview(messageButton)
        messageButton.width(edsIconSize)
        messageButton.height(edsIconSize)
        messageButton.trailingToSuperview(offset: edsSpace)
        messageButton.centerY(to: titleLabel)

    }

}
