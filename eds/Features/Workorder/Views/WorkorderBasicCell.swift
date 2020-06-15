//
//  WorkorderBasicCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import CallKit
import MessageUI

class WorkorderBasicCell: UITableViewCell {
    
    private let disposeBag = DisposeBag()
    private let workerIcon = UIImageView()
    private let workerLabel = UILabel()
//    private let workerButton = UIButton()
    private let timeIcon = UIImageView()
    private let timeLabel = UILabel()
    private let deviceIcon = UIImageView()
    private let deviceLabel = UILabel()
    private let deviceButton = UIButton()

    var parentVC: UIViewController?
    var workorder: Workorder? {
        didSet {
            guard let workorder = workorder else { return }
            workerLabel.text = workorder.worker
//            deviceLabel.text = workorder.location
            timeLabel.text = workorder.getTimeRange()
            deviceLabel.attributedText = NSMutableAttributedString(string: workorder.location, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }


    private func initViews() {

//        tintColor = .darkGray

        workerIcon.image = UIImage(systemName: "person")
        workerIcon.tintColor = .systemBlue
        addSubview(workerIcon)
        workerIcon.width(edsIconSize)
        workerIcon.height(edsIconSize)
        workerIcon.leadingToSuperview(offset: edsSpace)
        workerIcon.topToSuperview(offset: edsMinSpace)

        workerLabel.font=UIFont.preferredFont(forTextStyle: .headline)
        addSubview(workerLabel)
        workerLabel.centerY(to: workerIcon)
        workerLabel.leadingToTrailing(of: workerIcon, offset: edsMinSpace)

        deviceIcon.image = Device.icon
        deviceIcon.tintColor = .systemRed
        addSubview(deviceIcon)
        deviceIcon.width(edsIconSize)
        deviceIcon.height(edsIconSize)
        deviceIcon.topToBottom(of: workerIcon, offset: edsMinSpace)
        deviceIcon.leading(to: workerIcon)

        deviceLabel.font=UIFont.preferredFont(forTextStyle: .headline)
        deviceLabel.numberOfLines = 0
        addSubview(deviceLabel)
        deviceLabel.centerY(to: deviceIcon)
        deviceLabel.leadingToTrailing(of: deviceIcon, offset: edsMinSpace)
        deviceLabel.trailingToSuperview(offset: edsSpace)
        
        deviceButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {
            guard let device = WorkorderUtility.getDevice(of: self.workorder) else { return }
            if device.level == .dynamic {
                let dynamicVC = DynamicDeviceController()
                dynamicVC.device = device
                self.parentVC?.navigationController?.present(dynamicVC, animated: true, completion: nil)//(dynamicVC, animated: true)
            } else {
                let fixedVC = FixedDeviceController()
                fixedVC.device = device
                self.parentVC?.navigationController?.present(fixedVC, animated: true, completion: nil)//(dynamicVC, animated: true)
            }
        }).disposed(by: disposeBag)
        addSubview(deviceButton)
        deviceButton.edges(to: deviceLabel)

        timeIcon.image = UIImage(systemName: "calendar")
        timeIcon.tintColor = .systemGreen
        addSubview(timeIcon)
        timeIcon.width(edsIconSize)
        timeIcon.height(edsIconSize)
        timeIcon.topToBottom(of: deviceIcon, offset: edsMinSpace)
        timeIcon.leading(to: deviceIcon)
        timeIcon.bottomToSuperview(offset: -edsMinSpace)

        timeLabel.font=UIFont.preferredFont(forTextStyle: .headline)
        addSubview(timeLabel)
        timeLabel.leadingToTrailing(of: timeIcon, offset: edsMinSpace)
        timeLabel.centerY(to: timeIcon)
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

