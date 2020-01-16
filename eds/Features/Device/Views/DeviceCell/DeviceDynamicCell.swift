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
    private let statusView = UILabel()

    private let disposeBag = DisposeBag()

    public var deviceName: String? {
        didSet {
            if let deviceName = deviceName {
                if let image = TagUtility.getDeviceIcon(with: deviceName) {
                    deviceImageView.image = image
                }
                nameLabel.text = deviceName
                setStatus(with: deviceName)
            }
        }
    }

    private func setStatus(with deviceName: String) {
        let deviceType = TagUtility.getDeviceType(with: deviceName)
        if let deviceModel = DeviceModel.sharedInstance?.types.first(where: { $0.type == deviceType }) {
            //tag全名：RD_A3_1:Ia
            let tag = TagUtility.sharedInstance.getTagList(by: [deviceModel.status.tag], in: deviceName).first
            tag?.showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { showValue in
                if let status = TagValueConverter.getText(value: showValue, items: deviceModel.status.items).status {
                    self.statusView.backgroundColor = status.getStatusColor()
                    let text = status.getStatusText().localize(with: prefixDevice)
                    //圆角Label,text应当适当缩进，简易处理：在text前后添加空格，使lable.width变大
                    self.statusView.text = "  \(text)  "

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
        nameLabel.leadingToTrailing(of: deviceImageView, offset: space)
        nameLabel.height(to: deviceImageView, multiplier: 0.5)

        infoLabel.text = NSLocalizedString("edit basic info here.", comment: "device_info_default")
        infoLabel.font = UIFont.preferredFont(forTextStyle: .body)
        infoLabel.textColor = .systemGray
        addSubview(infoLabel)
        infoLabel.topToBottom(of: nameLabel, offset: space)
        infoLabel.leadingToTrailing(of: deviceImageView, offset: space)
        infoLabel.trailingToSuperview(offset: space)

        //圆角
        statusView.layer.cornerRadius = size / 2
        statusView.clipsToBounds = true
        statusView.textColor = .white
        statusView.numberOfLines = 1
        addSubview(statusView)
        statusView.height(size)
        statusView.centerY(to: nameLabel)
        statusView.leadingToTrailing(of: nameLabel, offset: space)
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
