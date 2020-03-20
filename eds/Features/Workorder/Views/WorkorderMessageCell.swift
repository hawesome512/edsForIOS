//
//  WorkorderMessageCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class WorkorderMessageCell: UITableViewCell {

    private let userImage = UIImageView()
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let messageLabel = UILabel()

    var message: WorkorderMessage? {
        didSet {
            if let name = message?.user?.name {
                nameLabel.text = name
                if let photo = AccountUtility.sharedInstance.getPhone(by: name)?.photo {
                    userImage.kf.setImage(with: photo.getEDSServletImageUrl(), placeholder: edsDefaultImage)
                }
            }
            timeLabel.text = message?.date
            messageLabel.text = message?.content
        }
    }

    private func initViews() {

        userImage.layer.borderColor = UIColor.systemBlue.cgColor
        userImage.layer.borderWidth = 2
//        userImage.image = UIImage(named: "device_A1")
        userImage.contentMode = .scaleAspectFit
        addSubview(userImage)
        userImage.width(edsHeight)
        userImage.height(edsHeight)
        userImage.topToSuperview(offset: edsMinSpace)
        userImage.leadingToSuperview(offset: edsSpace)
        userImage.layer.cornerRadius = edsHeight / 2
        userImage.layer.masksToBounds = true
//        userImage.clipsToBounds = true

        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
//        nameLabel.text = "徐海生"
        addSubview(nameLabel)
        nameLabel.top(to: userImage)
        nameLabel.leadingToTrailing(of: userImage, offset: edsSpace)

        timeLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        timeLabel.textColor = .systemGray
//        timeLabel.text = Date().toDateString()
        addSubview(timeLabel)
        timeLabel.bottom(to: userImage)
        timeLabel.leadingToTrailing(of: userImage, offset: edsSpace)

        messageLabel.numberOfLines = 0
//        messageLabel.text = "EDS云管理平台EDS云管理平台EDS云管理平台"
        addSubview(messageLabel)
        messageLabel.topToBottom(of: userImage, offset: edsMinSpace)
        messageLabel.bottomToSuperview(offset: -edsMinSpace)
        messageLabel.leadingToTrailing(of: userImage, offset: edsSpace)
        messageLabel.trailingToSuperview(offset: edsSpace)
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
