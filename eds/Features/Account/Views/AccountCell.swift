//
//  AccountCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/30.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import Kingfisher

class AccountCell: UITableViewCell {
    private let disposeBag = DisposeBag()

    let profileImage = UIImageView()
    let nameLabel = UILabel()
    let levelImage = UIImageView()
    let phoneLabel = UILabel()
    let emailLabel = UILabel()
    let actionLabel = UILabel()
    let actionButton = UIImageView()
    let levelLabel = UILabel()
    let levelButton = UIButton()

    var phone: Phone? {
        didSet {
            guard let phone = self.phone, let loginedPhone = AccountUtility.sharedInstance.loginedPhone else {
                return
            }
            //只有登录用户是管理员，才能对“其他人”进行权限升降操作
            if loginedPhone.level <= .phoneAdmin, phone.level > .phoneAdmin {
                levelButton.alpha = 1
            } else {
                levelButton.alpha = 0
            }
            let profileURL = phone.photo.getEDSServletImageUrl()
            profileImage.kf.setImage(with: profileURL, placeholder: UIImage(named: "AppIcon"))
            nameLabel.text = phone.name
            phoneLabel.text = phone.number
            emailLabel.text = phone.email
            phoneLevel = phone.level
            if let action = ActionUtility.sharedInstance.getAction(by: phone.name ?? NIL).first {
                actionLabel.text = action.getShortInfo()
            }
        }
    }

    var phoneLevel: UserLevel = .phoneObserver {
        didSet {
            levelImage.image = phoneLevel.getIcon()
            levelImage.tintColor = phoneLevel.getTintColor()
            levelLabel.text = phoneLevel.getText()
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

        tintColor = .systemGray

        profileImage.image = UIImage(named: "AppIcon")
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = edsHeight / 2
        profileImage.layer.borderWidth = 2
        profileImage.layer.borderColor = edsDefaultColor.cgColor
        addSubview(profileImage)
        profileImage.width(edsHeight)
        profileImage.height(edsHeight)
        profileImage.leadingToSuperview(offset: edsSpace)
        profileImage.topToSuperview(offset: edsMinSpace)

        nameLabel.text = "XSEEC"
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        addSubview(nameLabel)
        nameLabel.leadingToTrailing(of: profileImage, offset: edsMinSpace)
        nameLabel.centerY(to: profileImage)

        let phoneImage = UIImageView()
        phoneImage.image = UIImage(systemName: "phone")
        phoneImage.contentMode = .scaleAspectFit
        addSubview(phoneImage)
        phoneImage.width(edsIconSize)
        phoneImage.height(edsIconSize)
        phoneImage.topToBottom(of: profileImage, offset: edsMinSpace)
        phoneImage.leading(to: profileImage)

        phoneLabel.text = "18700000000"
        phoneLabel.textColor = .systemGray
        phoneLabel.adjustsFontSizeToFitWidth = true
        addSubview(phoneLabel)
        phoneLabel.centerY(to: phoneImage)
        phoneLabel.leadingToTrailing(of: phoneImage)

        let emailImage = UIImageView()
        emailImage.image = UIImage(systemName: "envelope")
        emailImage.contentMode = .scaleAspectFit
        addSubview(emailImage)
        emailImage.width(edsIconSize)
        emailImage.height(edsIconSize)
        emailImage.centerY(to: phoneLabel)
        emailImage.centerXToSuperview()
//        emailImage.leadingToTrailing(of: phoneLabel, offset: edsSpace)

        emailLabel.text = "shihlineds@xseec.cn"
//        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.textColor = .systemGray
        addSubview(emailLabel)
        emailLabel.centerY(to: emailImage)
        emailLabel.widthToSuperview(multiplier: 0.4)
        emailLabel.leadingToTrailing(of: emailImage)
//        emailLabel.trailingToSuperview(offset: edsSpace)

        let actionImage = UIImageView()
        actionImage.image = UIImage(systemName: "clock")
        actionImage.contentMode = .scaleAspectFit
        addSubview(actionImage)
        actionImage.width(edsIconSize)
        actionImage.height(edsIconSize)
        actionImage.leading(to: phoneImage)
        actionImage.topToBottom(of: phoneImage, offset: edsMinSpace)
        actionImage.bottomToSuperview(offset: -edsMinSpace)

        actionButton.image = UIImage(systemName: "chevron.right.circle.fill")
        actionButton.tintColor = edsDefaultColor
        addSubview(actionButton)
        actionButton.width(edsIconSize)
        actionButton.height(edsIconSize)
        actionButton.centerY(to: actionImage)
        actionButton.trailingToSuperview(offset: edsSpace)

        actionLabel.text = "withoutAction".localize()
        actionLabel.textColor = .systemGray
        addSubview(actionLabel)
        actionLabel.centerY(to: actionImage)
        actionLabel.leading(to: phoneLabel)
        actionLabel.trailingToLeading(of: actionButton)

        let level = UserLevel.phoneAdmin

        levelImage.image = level.getIcon()
        levelImage.contentMode = .scaleAspectFit
        addSubview(levelImage)
        levelImage.width(edsIconSize)
        levelImage.height(edsIconSize)
        levelImage.trailingToSuperview(offset: edsSpace)
        levelImage.centerY(to: profileImage)

        levelLabel.text = level.getText()
        levelLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(levelLabel)
        levelLabel.trailingToLeading(of: levelImage)
        levelLabel.centerY(to: profileImage)

        levelButton.setBackgroundImage(UIImage(systemName: "arrow.up.arrow.down.square.fill"), for: .normal)
        levelButton.tintColor = edsDefaultColor
        levelButton.rx.tap.bind(onNext: {
            self.phone?.switchLevel()
            self.phoneLevel = self.phone?.level ?? UserLevel.phoneObserver
            AccountUtility.sharedInstance.updatePhone()
        }).disposed(by: disposeBag)
        addSubview(levelButton)
        levelButton.width(edsIconSize)
        levelButton.height(edsIconSize)
        levelButton.centerY(to: levelImage)
        levelButton.trailingToLeading(of: levelLabel, offset: -edsMinSpace)
        levelButton.alpha = 0
    }

}
