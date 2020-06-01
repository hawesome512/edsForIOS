//
//  HomeDeviceCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class HomeDeviceCell: UITableViewCell {

    private let disposeBag = DisposeBag()
    private var deviceViews: Dictionary<DeviceClass, HomeDeviceView> = [:]
    private var classfiedDevices: Dictionary<DeviceClass, [Device]> = [:]

    var parentVC: UIViewController?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        tintColor = .white
        let contentView = ViewUtility.addCardEffect(in: self)
        ViewUtility.addColorEffect(in: contentView)

        let deviceImage = UIImageView()
        deviceImage.image = Device.icon
        contentView.addSubview(deviceImage)
        deviceImage.width(edsIconSize)
        deviceImage.height(edsIconSize)
        deviceImage.leadingToSuperview(offset: edsMinSpace)
        deviceImage.topToSuperview(offset: edsMinSpace)

        let deviceLabel = UILabel()
        deviceLabel.textColor = .white
        deviceLabel.text = Device.description
        deviceLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        contentView.addSubview(deviceLabel)
        deviceLabel.centerY(to: deviceImage)
        deviceLabel.leadingToTrailing(of: deviceImage, offset: edsMinSpace)

        DeviceClass.allCases.enumerated().forEach { (offset, item) in
            let view = HomeDeviceView()
            view.nameLabel.text = item.getText()
            view.valueLabel.backgroundColor = item.getColor()
            view.rx.tap.asObservable().bind(onNext: {
                let deviceListVC = HomeDeviceListController()
                var devices = self.classfiedDevices[item] ?? []
                //非通讯型（other）按资产层级排列,全展开
                if item == .other {
                    devices = DeviceUtility.sharedInstance.getProjDeviceList(visiableOnly: false, sources: devices)
                }
                deviceListVC.deviceList = devices
                deviceListVC.parentVC = self.parentVC
                deviceListVC.title = item.getText()
                self.parentVC?.navigationController?.present(deviceListVC, animated: true, completion: nil)
            }).disposed(by: disposeBag)
            deviceViews[item] = view

            contentView.addSubview(view)
            //横向等宽
            view.widthToSuperview(multiplier: 1.0 / CGFloat(DeviceClass.allCases.count))
            view.topToBottom(of: deviceImage, offset: edsMinSpace)
            view.bottomToSuperview(offset: -edsMinSpace)
            if offset == 0 {
                view.leadingToSuperview()
            } else {
                let lastItem = DeviceClass.init(rawValue: offset - 1)!
                view.leadingToTrailing(of: deviceViews[lastItem]!)
            }
        }

        //点列表和设备列表加载完成后再出发
        let loadedTaglist = TagUtility.sharedInstance.successfulLoadedTagList
        let loadedDeviceList = DeviceUtility.sharedInstance.successfulUpdated
        Observable.combineLatest(loadedTaglist, loadedDeviceList).throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: { (loadedTags, loadedDevices) in
            guard loadedTags == true, loadedDevices == true else {
                return
            }
            //Observable.of(array)👉多个通讯设备状态点数组订阅
            let dynamicTags = DeviceUtility.sharedInstance.getDynamicTags()
            Observable.from(dynamicTags.map { $0.tag.showValue }).merge().subscribe(onNext: { _ in
                //订阅到状态点变化，更新设备分类
                self.classfiedDevices = DeviceUtility.sharedInstance.classifyDevice(dynamicStates: dynamicTags)
                self.classfiedDevices.forEach { item in
                    self.deviceViews[item.key]?.valueLabel.text = "\(item.value.count)"
                }
            }).disposed(by: self.disposeBag)

        }).disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
