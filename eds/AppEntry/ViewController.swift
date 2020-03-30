//
//  ViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/4.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Foundation
import Moya
import SwiftyJSON
import HandyJSON
import CocoaMQTT
import RxSwift
import RxCocoa
import SwiftDate
import EFQRCode
import YPImagePicker
import MessageUI

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    let button = ImageButton()
    let label = UILabel()
    var tag: Tag?

    var collectionView: UICollectionView?
    let imageList = (0..<100).map { _ in YPMediaItem.photo(p: YPMediaPhoto(image: UIImage(named: "device_A1")!)) }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()

        //初始化后台数据，导入数据列表
        TagUtility.sharedInstance.loadProjectTagList()
        DeviceUtility.sharedInstance.loadProjectDeviceList()
        AlarmUtility.sharedInstance.loadProjectAlarmList()
        WorkorderUtility.sharedInstance.loadProjectWorkerorderList()
        AccountUtility.sharedInstance.loadProjectAccount()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
    }

    fileprivate func initViews() {
        title = "首页"

        button.backgroundColor = .systemGreen
        button.setTitle("运维工单", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.rx.tap.bind(onNext: {

            //跳转设备列表
            let deviceListVC = WorkorderAdditionViewController() //WorkorderListViewController()
            self.navigationController?.pushViewController(deviceListVC, animated: true)
        }).disposed(by: disposeBag)
        view.addSubview(button)
        button.center(in: view)
        button.width(180)
        button.height(60)

    }
}




