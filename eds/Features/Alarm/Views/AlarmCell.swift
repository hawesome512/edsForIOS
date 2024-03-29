//
//  AlarmCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class AlarmCell: UITableViewCell {

    private let deviceImage = UIImageView()
    private let statusView = RoundLabel()
    let titleLabel = UILabel()
    let deviceLabel = UILabel()
    private let timeLabel = UILabel()
    private let disposeBag = DisposeBag()

    var alarm: Alarm? {
        didSet {
            if let alarm = alarm, let device = DeviceUtility.sharedInstance.getDevice(of: alarm.device) {
                self.device = device
                ViewUtility.setWebImage(in: deviceImage, photo: device.image, download: .small, disposeBag: disposeBag, placeholder: device.getDefaultImage(), contentMode: .scaleAspectFill)
                titleLabel.text = TagValueConverter.getAlarmText(with: alarm.alarm, device: device)
                statusView.innerText = alarm.confirm.getText()
                statusView.backgroundColor = alarm.confirm.getState().color
                deviceLabel.text = device.title
                timeLabel.text = alarm.time
            }
        }
    }

    private var device: Device?

    private func initViews() {
        let _ = ViewUtility.addCardEffect(in: self)

        deviceImage.contentMode = .scaleAspectFit
        deviceImage.layer.masksToBounds = true
        deviceImage.layer.cornerRadius = 5
        deviceImage.clipsToBounds = true
        deviceImage.image = Device.icon
        contentView.addSubview(deviceImage)
        deviceImage.heightToSuperview(offset: -edsSpace * 2)
        deviceImage.widthToHeight(of: deviceImage)
        deviceImage.leadingToSuperview(offset: edsSpace)
        deviceImage.centerYToSuperview()

//        titleLabel.text = "过载"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        contentView.addSubview(titleLabel)
        titleLabel.top(to: deviceImage)
        titleLabel.leadingToTrailing(of: deviceImage, offset: edsMinSpace)

        statusView.textColor = .white
//        statusView.innerText = "未排查"
//        statusView.backgroundColor = .systemRed
        statusView.adjustsFontSizeToFitWidth = true
        statusView.layer.borderColor = edsDefaultColor.withAlphaComponent(0).cgColor
        contentView.addSubview(statusView)
        statusView.height(24)
        statusView.centerY(to: titleLabel)
        statusView.leadingToTrailing(of: titleLabel, offset: edsMinSpace)
        statusView.trailingToSuperview(offset: edsSpace)

        let deviceIcon = UIImageView()
        deviceIcon.tintColor = .systemGray
        deviceIcon.image = Device.icon
        contentView.addSubview(deviceIcon)
        deviceIcon.width(edsIconSize)
        deviceIcon.height(edsIconSize)
        deviceIcon.topToBottom(of: titleLabel, offset: edsMinSpace)
        deviceIcon.leadingToTrailing(of: deviceImage, offset: edsMinSpace)

//        deviceLabel.text = "成型3#4#柜"
        deviceLabel.textColor = .systemGray
        contentView.addSubview(deviceLabel)
        deviceLabel.centerY(to: deviceIcon)
        deviceLabel.leadingToTrailing(of: deviceIcon, offset: edsMinSpace)

        let timeImage = UIImageView()
        timeImage.tintColor = .systemGray
        timeImage.image = UIImage(systemName: "clock")
        contentView.addSubview(timeImage)
        timeImage.width(edsIconSize)
        timeImage.height(edsIconSize)
        timeImage.topToBottom(of: deviceIcon, offset: edsMinSpace)
        timeImage.leadingToTrailing(of: deviceImage, offset: edsMinSpace)

//        timeLabel.text = Date().toDateTimeString()
        timeLabel.textColor = .systemGray
        timeLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(timeLabel)
        timeLabel.centerY(to: timeImage)
        timeLabel.leadingToTrailing(of: timeImage, offset: edsMinSpace)
        timeLabel.trailingToSuperview(offset: edsSpace)
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
