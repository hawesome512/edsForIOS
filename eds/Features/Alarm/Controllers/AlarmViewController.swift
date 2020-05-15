//
//  AlarmViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class AlarmViewController: UIViewController {

    let headerView = DeviceHeaderView()
    let trendController = DeviceTrendTableViewController()

    var alarm: Alarm? {
        didSet {
            if let alarm = alarm, let device = DeviceUtility.sharedInstance.getDevice(of: alarm.device) {
                headerView.device = device
                let deviceType = DeviceModel.sharedInstance?.types.first { $0.type == TagUtility.getDeviceType(with: device.getShortID()) }
                if let alarmMode = deviceType?.alarm {
                    let tags = TagUtility.sharedInstance.getTagList(by: alarmMode.items, in: device.getShortID())
                    let condition = WATagLogRequestCondition.alarmCondition(with: tags, time: alarm.time)
                    let limits = getLimitValues(alarmMode: alarmMode, deviceName: device.getShortID())
                    trendController.trend(with: tags, condition: condition, isAccumulated: false, upperLimit: limits.upper, lowerLimit: limits.lower)
                }
            }
        }
    }

    private func getLimitValues(alarmMode: AlarmMode, deviceName: String) -> (upper: Double?, lower: Double?) {
        var upper: Double?
        var lower: Double?
        if let upperName = alarmMode.upper {
            let upperTag = TagUtility.sharedInstance.getTagList(by: [upperName], in: deviceName).first
            upper = upperTag?.getValue()
        }
        if let lowerName = alarmMode.lower {
            let lowerTag = TagUtility.sharedInstance.getTagList(by: [lowerName], in: deviceName).first
            lower = lowerTag?.getValue()
        }
        return (upper, lower)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initViews()
    }

    fileprivate func initViews() {

        view.addSubview(headerView)
        headerView.edgesToSuperview(excluding: .bottom)
        headerView.heightToSuperview(multiplier: 0.3)

        view.addSubview(trendController.view)
        trendController.view.edgesToSuperview(excluding: .top)
        trendController.view.topToBottom(of: headerView)

        navigationItem.rightBarButtonItem = getShareButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        //当前VC的父级vc是navigationController,必须设置如UINavigationController-Ext.swift
        return .lightContent
    }

}

