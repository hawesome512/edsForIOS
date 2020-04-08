//
//  GotoCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/6.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  静态页面单元格：工单和异常跳转指令

import UIKit
import RxSwift

class FixedGotoCell: UITableViewCell {

    private let workorderButton = ImageButton()
    private let alarmButton = ImageButton()
    private let disposeBag = DisposeBag()

    var device: Device?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        workorderButton.backgroundColor = .systemGreen
        workorderButton.setImage(Workorder.icon, for: .normal)
        workorderButton.setTitle(Workorder.description, for: .normal)
        workorderButton.rx.tap.bind(onNext: {
            let workorderListController = WorkorderListViewController()
            workorderListController.deviceFilter = self.device?.title
            (self.window?.rootViewController as? UINavigationController)?.pushViewController(workorderListController, animated: true)
        }).disposed(by: disposeBag)
        addSubview(workorderButton)
        workorderButton.widthToSuperview(multiplier: 0.5, offset: -edsSpace * 1.5)
        workorderButton.edgesToSuperview(excluding: .leading, insets: .uniform(edsSpace))

        alarmButton.backgroundColor = .systemRed
        alarmButton.setImage(Alarm.icon, for: .normal)
        alarmButton.setTitle(Alarm.description, for: .normal)
        alarmButton.rx.tap.bind(onNext: {
            let alarmListController = AlarmListViewController()
            if let deviceID = self.device?.getShortID() {
                alarmListController.filter(with: deviceID)
            }
            (self.window?.rootViewController as? UINavigationController)?.pushViewController(alarmListController, animated: true)
        }).disposed(by: disposeBag)
        addSubview(alarmButton)
        alarmButton.widthToSuperview(multiplier: 0.5, offset: -edsSpace * 1.5)
        alarmButton.edgesToSuperview(excluding: .trailing, insets: .uniform(edsSpace))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
