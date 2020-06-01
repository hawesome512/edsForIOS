//
//  ViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/4.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Foundation

class MainController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    fileprivate func initViews() {
        view.backgroundColor = .white
        addChildVC(child: HomeController(), title: Home.description, image: Home.icon, tag: 0)
        addChildVC(child: DeviceListController(), title: Device.description, image: Device.icon, tag: 1)
        addChildVC(child: AlarmListController(), title: Alarm.description, image: Alarm.icon, tag: 2)
        addChildVC(child: WorkorderListController(), title: Workorder.description, image: Workorder.icon, tag: 3)
        addChildVC(child: MineController(), title: Mine.description, image: Mine.icon, tag: 4)

    }

    func addChildVC(child: UIViewController, title: String?, image: UIImage?, tag: Int) {
        let navVC = UINavigationController(rootViewController: child)
        navVC.title = title
        navVC.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        addChild(navVC)
    }
}


