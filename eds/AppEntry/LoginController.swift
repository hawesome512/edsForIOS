//
//  LoginController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/14.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import SwiftDate
class LoginController: UIViewController {

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()

        // Do any additional setup after loading the view.
        //初始化后台数据，导入数据列表
//        TagUtility.sharedInstance.loadProjectTagList()
//        DeviceUtility.sharedInstance.loadProjectDeviceList()
//        AlarmUtility.sharedInstance.loadProjectAlarmList()
//        WorkorderUtility.sharedInstance.loadProjectWorkerorderList()
//        AccountUtility.sharedInstance.loadProjectAccount()
        BasicUtility.sharedInstance.loadProjectBasicInfo()
    }

    private func initViews() {

        let button = UIButton()
        button.setTitle("登录", for: .normal)
        button.backgroundColor = .systemBlue
        button.rx.tap.bind(onNext: {

            let mainVC = MainController()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        view.addSubview(button)
        button.centerInSuperview()
        button.height(60)
        button.widthToSuperview(multiplier: 0.8)
    }
}
