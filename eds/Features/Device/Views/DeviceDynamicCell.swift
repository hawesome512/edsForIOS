//
//  DeviceCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/19.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device设备列表页的cell,含运行状态statusView

import UIKit
import RxCocoa
import RxSwift

class DeviceDynamicCell: UITableViewCell {

    private let space: CGFloat = 10
    private let size: CGFloat = 24

    private let deviceImageView = UIImageView()
    private let nameLabel = UILabel()
    private let infoLabel = UILabel()
    private let statusView = UIView()

    private let disposeBag = DisposeBag()

    public var deviceName: String? {
        didSet {
            if let deviceName = deviceName {
                deviceImageView.image = TagUtility.getDeviceIcon(with: deviceName)
                nameLabel.text = deviceName
//                infoLabel.text=
                setStatus(with: deviceName)
            }
        }
    }

    private func setStatus(with deviceName: String) {
        let deviceType = TagUtility.getDeviceType(with: deviceName)
        if let deviceModel = DeviceModel.sharedInstance?.types.first(where: { $0.type == deviceType }) {
            //tag全名：RD_A3_1:Ia
            let tagName = deviceModel.status.tag
            let tag = TagUtility.sharedInstance.getTag(by: deviceName + Tag.nameSeparator + tagName)
            tag?.showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { showValue in
                if let showValue = showValue, let items = deviceModel.status.items {
                    if let status = TagValueConverter.getStatus(value: showValue, items: items) {
                        self.statusView.backgroundColor = status.getStatusColor()
                    }
                }
            }).disposed(by: disposeBag)
        }
    }

    fileprivate func initViews() {

        deviceImageView.image = UIImage(named: "device_static")
        deviceImageView.contentMode = .scaleAspectFit
        addSubview(deviceImageView)
        deviceImageView.heightToSuperview(offset: -space * 2)
        deviceImageView.widthToHeight(of: deviceImageView)
        deviceImageView.topToSuperview(offset: space)
        deviceImageView.leadingToSuperview(offset: space)

        nameLabel.text = "#000"
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(nameLabel)
        nameLabel.topToSuperview(offset: space)
        nameLabel.leadingToTrailing(of: deviceImageView)
        nameLabel.height(to: deviceImageView, multiplier: 0.5)

        infoLabel.text = NSLocalizedString("编辑资产基本信息", comment: "device_info_default")
        infoLabel.font = UIFont.preferredFont(forTextStyle: .body)
        infoLabel.textColor = .systemGray
        addSubview(infoLabel)
        infoLabel.topToBottom(of: nameLabel, offset: space)
        infoLabel.leadingToTrailing(of: deviceImageView, offset: space)
        infoLabel.trailingToSuperview(offset: space)

        statusView.layer.cornerRadius = size / 2
        statusView.clipsToBounds = true
        addSubview(statusView)
        statusView.width(size)
        statusView.height(size)
        statusView.centerY(to: nameLabel)
        statusView.leadingToTrailing(of: nameLabel)
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
