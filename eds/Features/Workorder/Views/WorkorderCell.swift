//
//  WorkorderCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class WorkorderCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let typeLabel = RoundLabel()
    private let deviceIcon = UIImageView()
    private let deviceLabel = UILabel()
    private let workerIcon = UIImageView()
    private let workerLabel = UILabel()
    private let timeIcon = UIImageView()
    private let timeLabel = UILabel()
    private let stateImageView = UIImageView()
//    private let sceneImageView = UIImageView()

    var workorder: Workorder? {
        didSet {
            if let workorder = workorder {
                titleLabel.text = workorder.title
                typeLabel.innerText = workorder.type.getText()
                typeLabel.backgroundColor = workorder.type.getColor()
                deviceLabel.text = workorder.location
                timeLabel.text = workorder.getTimeRange()
                let state = workorder.getTimeState()
                stateImageView.image = state.icon
                stateImageView.tintColor = state.color
                workerLabel.text = workorder.worker.separateNameAndPhone().name
            }
        }
    }

    private func initViews() {

        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        addSubview(titleLabel)
        titleLabel.topToSuperview(offset: edsSpace)
        titleLabel.leadingToSuperview(offset: edsSpace)

        typeLabel.textColor = .white
        typeLabel.layer.borderColor = edsDefaultColor.withAlphaComponent(0).cgColor
        addSubview(typeLabel)
        typeLabel.centerY(to: titleLabel)
        typeLabel.leadingToTrailing(of: titleLabel, offset: edsMinSpace)

        workerIcon.tintColor = .systemGray
        workerIcon.image = UIImage(systemName: "person.crop.circle")
        addSubview(workerIcon)
        workerIcon.width(edsIconSize)
        workerIcon.height(edsIconSize)
        workerIcon.leading(to: titleLabel)
        workerIcon.topToBottom(of: titleLabel, offset: edsMinSpace)

        workerLabel.textColor = .systemGray
        addSubview(workerLabel)
        workerLabel.centerY(to: workerIcon)
        workerLabel.leadingToTrailing(of: workerIcon, offset: edsMinSpace)
        workerLabel.width(60)

        timeIcon.tintColor = .systemGray
        timeIcon.image = UIImage(systemName: "calendar")
        addSubview(timeIcon)
        timeIcon.width(edsIconSize)
        timeIcon.height(edsIconSize)
        timeIcon.centerY(to: workerIcon)
        timeIcon.leadingToTrailing(of: workerLabel, offset: edsSpace)

        timeLabel.textColor = .systemGray
        timeLabel.textAlignment = .right
        addSubview(timeLabel)
        timeLabel.leadingToTrailing(of: timeIcon, offset: edsMinSpace)
        timeLabel.centerY(to: workerIcon)

        addSubview(stateImageView)
        stateImageView.width(edsIconSize)
        stateImageView.height(edsIconSize)
        stateImageView.centerY(to: workerIcon)
        stateImageView.trailingToSuperview(offset: edsSpace)

        deviceIcon.image = Device.icon
        deviceIcon.tintColor = .systemGray
        addSubview(deviceIcon)
        deviceIcon.width(edsIconSize)
        deviceIcon.height(edsIconSize)
        deviceIcon.topToBottom(of: workerIcon, offset: edsMinSpace)
        deviceIcon.leading(to: titleLabel)

        deviceLabel.textColor = .systemGray
        addSubview(deviceLabel)
        deviceLabel.centerY(to: deviceIcon)
        deviceLabel.leadingToTrailing(of: deviceIcon, offset: edsMinSpace)
        deviceLabel.trailingToSuperview(offset: edsSpace)
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
