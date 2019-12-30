//
//  ViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/4.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON
import HandyJSON
import CocoaMQTT
import Foundation
import RxSwift
import RxCocoa

class ViewController: UIViewController {


    let disposeBag = DisposeBag()
    let button = UIButton()
    let label = UILabel()
    var tag: Tag?

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        TagUtility.sharedInstance.loadProjectTagList()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
    }

    fileprivate func initViews() {
        title = "首页"

        button.backgroundColor = .systemBlue
        button.setTitle("Execute", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.rx.tap.bind(onNext: {

            //跳转设备列表
            let deviceListVC = DeviceViewController()
            deviceListVC.deviceName = "KB_M2_3"
            self.navigationController?.pushViewController(deviceListVC, animated: true)

        }).disposed(by: disposeBag)
        view.addSubview(button)
        button.center(in: view)
        button.width(200)
        button.height(60)

        label.text = "0"
        view.addSubview(label)
        label.topToBottom(of: button, offset: 20)
        label.centerXToSuperview()
    }
}

