//
//  HomeAlarmCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/28.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class HomeAlarmCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let stateImage = UIImageView()
    private var items: Dictionary<AlarmConfirm,CardItemButton> = [:]
    private let disposeBag = DisposeBag()
    private var alarm:Alarm?
    
    var parentVC:UIViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
        initData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews() {
        tintColor = .white
        let contentView = ViewUtility.addCardEffect(in: self)
        ViewUtility.addColorEffect(in: contentView)
        
        let icon = UIImageView()
        icon.image = Alarm.icon
        contentView.addSubview(icon)
        icon.width(edsIconSize)
        icon.height(edsIconSize)
        icon.leadingToSuperview(offset: edsMinSpace)
        icon.topToSuperview(offset: edsMinSpace)
        
        let title = UILabel()
        title.textColor = .white
        title.text = Alarm.description
        title.font = UIFont.preferredFont(forTextStyle: .title3)
        contentView.addSubview(title)
        title.centerY(to: icon)
        title.leadingToTrailing(of: icon, offset: edsMinSpace)
        
        let state = AlarmConfirm.unchecked.getState()
        stateImage.tintColor = state.color
        stateImage.image = state.icon
        contentView.addSubview(stateImage)
        stateImage.width(edsIconSize)
        stateImage.height(edsIconSize)
        stateImage.centerYToSuperview()
        stateImage.trailingToSuperview(offset: edsSpace)
        
        titleLabel.text = "none_alarm".localize(with: prefixHome)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)
        titleLabel.leading(to: icon)
        titleLabel.trailingToLeading(of: stateImage, offset: -edsSpace, relation: .equalOrLess)
        titleLabel.centerYToSuperview()
        
        AlarmConfirm.allCases.enumerated().forEach({ (offset,confirm) in
            let state = confirm.getState()
            let itemButton = CardItemButton()
            itemButton.tintColor = state.color
            itemButton.iconImage.image = state.icon
            itemButton.valueLabel.text = "0"
            itemButton.rx.tap.bind(onNext: {
                let alarmsVC = AlarmListViewController()
                alarmsVC.confirmFilter = confirm
                alarmsVC.hidesBottomBarWhenPushed = true
                self.parentVC?.navigationController?.pushViewController(alarmsVC, animated: true)
            }).disposed(by: disposeBag)
            contentView.addSubview(itemButton)
            itemButton.widthToSuperview(multiplier: 1/2)
            itemButton.height(edsIconSize+edsSpace)
            itemButton.bottomToSuperview()
            if offset == 0 {
                itemButton.leadingToSuperview()
            } else {
                let lastConfirm = AlarmConfirm.init(rawValue: offset-1)!
                itemButton.leadingToTrailing(of: items[lastConfirm]!)
            }
            items[confirm] = itemButton
        })
    }
    
    private func initData(){
        let deviceLoaded = DeviceUtility.sharedInstance.successfulUpdated
        let alarmLoaded = AlarmUtility.sharedInstance.successfulUpdated
        Observable.combineLatest(deviceLoaded, alarmLoaded).throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {(deviceResult,alarmResult) in
            guard deviceResult == true, alarmResult == true else { return }
            guard let alarm = AlarmUtility.sharedInstance.getAlarmList().first, let device = DeviceUtility.sharedInstance.getDevice(of: alarm.device) else{
                    return
            }
            self.alarm = alarm
            let alarmText = TagValueConverter.getAlarmText(with: alarm.alarm, device: device)
            self.titleLabel.text = "\(device.title)(\(alarmText))"
            let state = alarm.confirm.getState()
            self.stateImage.image = state.icon
            self.stateImage.tintColor = state.color
            
            let classifiedAlarms = AlarmUtility.sharedInstance.getClassifiedAlarm()
            classifiedAlarms.forEach{(confirm,alarms) in
                self.items[confirm]?.valueLabel.text = "\(alarms.count)"
            }
        }).disposed(by: disposeBag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        guard selected==true, let alarm = alarm else { return }
        let alarmVC = AlarmViewController()
        alarmVC.alarm = alarm
        alarmVC.hidesBottomBarWhenPushed = true
        alarmVC.title = titleLabel.text
        parentVC?.navigationController?.pushViewController(alarmVC, animated: true)
        
    }
    
}
