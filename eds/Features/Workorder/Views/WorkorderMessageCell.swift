//
//  WorkorderMessageCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MessageDelegate {
    func delete(message: WorkorderMessage)
}

class WorkorderMessageCell: UITableViewCell {

    private let userImage = UIImageView()
    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let messageLabel = UILabel()
    let deleteButton = UIButton()
    let levelImage = UIImageView()
    private let disposeBag = DisposeBag()

    private var messageType: MessageType = .text
    var message: WorkorderMessage? {
        didSet {
            if let name = message?.name {
                nameLabel.text = name
                if let photo = AccountUtility.sharedInstance.getPhone(by: name)?.photo {
                    let url=photo.getEDSServletImageUrl()
                    ViewUtility.setWebImage(in: userImage, with: url, disposeBag: disposeBag,placeholder: edsDefaultImage)
                } else {
                    userImage.image = UIImage(named: "eds")
                }
            }
            timeLabel.text = message?.date
            if let types = message?.getType() {
                messageLabel.attributedText = types.attrText
                messageType = types.type
            }
        }
    }
    var delegate: MessageDelegate?
    var parentVC: UIViewController?

    private func initViews() {

        userImage.layer.borderColor = UIColor.systemBlue.cgColor
        userImage.layer.borderWidth = 2
//        userImage.image = UIImage(named: "device_A1")
        userImage.contentMode = .scaleAspectFit
        userImage.tintColor = .systemGray
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

        levelImage.tintColor = .systemRed
        levelImage.image = UIImage(named: "manager")?.withRenderingMode(.alwaysTemplate)
        levelImage.contentMode = .scaleAspectFit
        addSubview(levelImage)
        levelImage.width(edsSpace)
        levelImage.height(edsSpace)
        levelImage.centerY(to: nameLabel)
        levelImage.leadingToTrailing(of: nameLabel)

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

        deleteButton.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        deleteButton.tintColor = .systemGray
        deleteButton.rx.tap.asObservable().bind(onNext: {
            self.delegate?.delete(message: self.message!)
        }).disposed(by: disposeBag)
        addSubview(deleteButton)
        deleteButton.width(edsSpace)
        deleteButton.height(edsSpace)
        deleteButton.top(to: userImage)
        deleteButton.trailingToSuperview(offset: edsMinSpace)
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
        if selected {
            guard let content = message?.content else {
                return
            }
            switch messageType {
            case .instruction:
                ShareUtility.openWeb(content.getEDSServletWorkorderDocUrl())
            case .alarm:
                if let alarm = AlarmUtility.sharedInstance.get(by: content) {
                    let alarmVC = AlarmViewController()
                    alarmVC.alarm = alarm
                    parentVC?.navigationController?.pushViewController(alarmVC, animated: true)
                }
                break
            default:
                break
            }
        }
    }

}
