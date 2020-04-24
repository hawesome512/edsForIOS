//
//  HomeHeaderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Kingfisher

class HomeHeaderView: UIView {

    let bannerImage = UIImageView()
    let titleLabel = UILabel()
    let locationButton = UIButton()
    let noticeButton = UIButton()
    let noticeLabel = UILabel()

    var basic: Basic? {
        didSet {
            guard let basic = self.basic else {
                return
            }
            titleLabel.text = basic.user
            let imageURL = basic.banner.getEDSServletImageUrl()
            bannerImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "banner_default"))
            if let notice = Notice.getNotice(with: basic.notice) {
                noticeLabel.text = notice.message
            } else {
                noticeLabel.text = ""
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        bannerImage.contentMode = .scaleAspectFill
        bannerImage.image = UIImage(named: "banner_default")
        addSubview(bannerImage)
        bannerImage.edgesToSuperview()

//        messageLabel.text = "5月1日 0:00～6:00 系统维护，部分功能将受影响！"
        noticeLabel.textColor = .systemYellow
        noticeLabel.textAlignment = .right
        addSubview(noticeLabel)
        noticeLabel.bottomToSuperview(offset: -edsMinSpace)
        noticeLabel.horizontalToSuperview(insets: .horizontal(edsSpace))

//        titleLabel.text = "厦门士林电机"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        addSubview(titleLabel)
        titleLabel.leadingToSuperview(offset: edsSpace)
        titleLabel.bottomToTop(of: noticeLabel, offset: -edsMinSpace)

        noticeButton.setBackgroundImage(UIImage(systemName: "speaker.2"), for: .normal)
        noticeButton.tintColor = .white
        addSubview(noticeButton)
        noticeButton.width(edsIconSize)
        noticeButton.height(edsIconSize)
        noticeButton.trailingToSuperview(offset: edsSpace)
        noticeButton.centerY(to: titleLabel)

        locationButton.tintColor = .white
        locationButton.setBackgroundImage(UIImage(named: "location")?.withTintColor(.white), for: .normal)
        addSubview(locationButton)
        locationButton.width(edsIconSize)
        locationButton.height(edsIconSize)
        locationButton.leadingToTrailing(of: titleLabel, offset: edsMinSpace)
        locationButton.centerY(to: titleLabel)

    }

}
