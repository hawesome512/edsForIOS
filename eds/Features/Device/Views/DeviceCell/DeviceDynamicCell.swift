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
import TinyConstraints

class DeviceDynamicCell: UITableViewCell {

    private let deviceImageView = UIImageView()
    private let nameLabel = UILabel()
    private let statusView = RoundLabel()
    private var imageViewLeading: Constraint?

    private let disposeBag = DisposeBag()

    override var indentationLevel: Int {
        didSet {
            let constant = CGFloat(indentationLevel) * edsSpace
            imageViewLeading?.constant = constant
            //自定义cell控件约束不受layoutMargin影响，它只影响分割线
            layoutMargins.left = constant
        }
    }

//    public var deviceName: String? {
//        didSet {
//            if let deviceName = deviceName {
////                if let image = TagUtility.getDeviceIcon(with: deviceName) {
////                    deviceImageView.image = image
////                }
//                nameLabel.text = deviceName
//                setStatus(with: deviceName)
//            }
//        }
//    }

    var device: Device? {
        didSet {
            if let device = device {
                nameLabel.text = device.title
                setStatus(with: device.getShortID())
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
                    let text = status.getStatusText()
                    //圆角Label,text应当适当缩进，简易处理：在text前后添加空格，使lable.width变大
                    self.statusView.innerText = text //.text = "  \(text)  "

                }
            }).disposed(by: disposeBag)
        }
    }

    fileprivate func initViews() {

        deviceImageView.image = UIImage(named: "device_fixed")?.withTintColor(edsDefaultColor)
        deviceImageView.contentMode = .scaleAspectFit
        addSubview(deviceImageView)
        deviceImageView.heightToSuperview(offset: -edsSpace)
        deviceImageView.widthToHeight(of: deviceImageView)
        imageViewLeading = deviceImageView.leadingToSuperview(offset: edsSpace)
        deviceImageView.centerYToSuperview()

        nameLabel.text = "#000"
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        nameLabel.textColor = edsDefaultColor
        addSubview(nameLabel)
        nameLabel.centerY(to: deviceImageView)
        nameLabel.leadingToTrailing(of: deviceImageView, offset: edsSpace / 2)
        nameLabel.height(to: deviceImageView, multiplier: 0.5)

        //圆角
        statusView.textColor = .white
//        statusView.numberOfLines = 1
        //不显示边框
        statusView.layer.borderColor = edsDefaultColor.withAlphaComponent(0).cgColor
        addSubview(statusView)
        statusView.height(24)
        statusView.centerY(to: nameLabel)
        statusView.leadingToTrailing(of: nameLabel, offset: edsSpace / 2)
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
