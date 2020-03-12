//
//  AlarmCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class AlarmCell: UITableViewCell {

    private let deviceImage = UIImageView()
    private let statusView = RoundLabel()
    private let titleLabel = UILabel()
    private let deviceLabel = UILabel()
    private let timeLabel = UILabel()

    var alarm: Alarm? {
        didSet {

            if let alarm = alarm, let device = DeviceUtility.sharedInstance.getDevice(of: alarm.device) {
                self.device = device
                DeviceUtility.setImage(in: deviceImage, with: device)
                titleLabel.text = TagValueConverter.getAlarmText(with: alarm.alarm, device: device)
                statusView.innerText = "\(alarm.confirm)".localize(with: prefixAlarm)
                statusView.backgroundColor = alarm.confirm.getConfirmColor()
                deviceLabel.text = device.title
                timeLabel.text = alarm.time
            }
        }
    }

    private var device: Device?

    private func initViews() {
        deviceImage.contentMode = .scaleAspectFit
//        deviceImage.image = UIImage(named: "device_A1")
        addSubview(deviceImage)
        deviceImage.heightToSuperview(offset: -edsSpace)
        deviceImage.widthToHeight(of: deviceImage)
        deviceImage.leadingToSuperview()
        deviceImage.centerYToSuperview()

//        titleLabel.text = "过载"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        addSubview(titleLabel)
        titleLabel.top(to: deviceImage)
        titleLabel.leadingToTrailing(of: deviceImage, offset: edsVerSpace)

        statusView.textColor = .white
//        statusView.innerText = "未排查"
//        statusView.backgroundColor = .systemRed
        statusView.layer.borderColor = edsDefaultColor.withAlphaComponent(0).cgColor
        addSubview(statusView)
        statusView.height(24)
        statusView.centerY(to: titleLabel)
        statusView.leadingToTrailing(of: titleLabel, offset: edsVerSpace)

        let deviceIcon = UIImageView()
        deviceIcon.tintColor = .systemGray
        deviceIcon.image = UIImage(systemName: "bolt.circle")
        addSubview(deviceIcon)
        deviceIcon.width(edsIconSize)
        deviceIcon.height(edsIconSize)
        deviceIcon.topToBottom(of: titleLabel, offset: edsVerSpace)
        deviceIcon.leadingToTrailing(of: deviceImage, offset: edsVerSpace)

//        deviceLabel.text = "成型3#4#柜"
        deviceLabel.textColor = .systemGray
        addSubview(deviceLabel)
        deviceLabel.centerY(to: deviceIcon)
        deviceLabel.leadingToTrailing(of: deviceIcon, offset: edsVerSpace)

        let timeImage = UIImageView()
        timeImage.tintColor = .systemGray
        timeImage.image = UIImage(systemName: "clock")
        addSubview(timeImage)
        timeImage.width(edsIconSize)
        timeImage.height(edsIconSize)
        timeImage.topToBottom(of: deviceIcon, offset: edsVerSpace)
        timeImage.leadingToTrailing(of: deviceImage, offset: edsVerSpace)

//        timeLabel.text = Date().toDateTimeString()
        timeLabel.textColor = .systemGray
        addSubview(timeLabel)
        timeLabel.centerY(to: timeImage)
        timeLabel.leadingToTrailing(of: timeImage, offset: edsVerSpace)
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
        if selected, let device = device, let alarm = alarm {

            let alarmController = AlarmViewController()
            alarmController.config = (device, alarm)
            alarmController.title = "\(device.title) \(titleLabel.text ?? "")"
            (window?.rootViewController as? UINavigationController)?.pushViewController(alarmController, animated: true)
        }
        // Configure the view for the selected state
    }

}
