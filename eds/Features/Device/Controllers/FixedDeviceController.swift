//
//  FixedDeviceViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/2/28.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class FixedDeviceController: UIViewController, DevicePageScrollDelegate {

    private let headerView = DeviceHeaderView()
    private let fixedVC = FixedInfoChildController(style: .plain)
    //头图↕️偏移当约束
    private var headerViewTopConstraint: NSLayoutConstraint?

    var device: Device? {
        didSet {
            initViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fixedVC.scrollDelegate = self
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(sharePage))
    }
    
    @objc func sharePage(_ sender: UIBarButtonItem){
        let image = QRCodeUtility.generate(with: .device, param: device!.getShortID())
        let sourceView = navigationItem.rightBarButtonItem?.plainView
        ShareUtility.shareImage(image: image, controller: self, sourceView: sourceView ?? view)
        sender.plainView.loadedWithAnimation()
    }

    override func viewWillAppear(_ animated: Bool) {

        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.subviews.first?.alpha = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: edsDefaultColor]
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.subviews.first?.alpha = 1
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        //当前VC的父级vc是navigationController,必须设置如UINavigationController-Ext.swift
        return .lightContent
    }

    fileprivate func initViews() {
        title = device?.title
        //顶部图片
        view.addSubview(headerView)
        headerView.horizontalToSuperview()
        headerView.height(to: view, multiplier: 0.3)
        //TinyConstraint未找到相关用法：后台动态约束
        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: headerView.superview!.topAnchor)
        headerViewTopConstraint?.isActive = true
        headerView.device = device
        headerView.parentVC = self

        view.addSubview(fixedVC.view)
        fixedVC.device = device
        fixedVC.parentVC = self
        fixedVC.view.edgesToSuperview(excluding: .top)
        fixedVC.view.topToBottom(of: headerView)

    }

    //MARK:头图滚动偏移

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //动画：tableview往上滚动👉头图偏移往上👉title大>小👉导航栏透明>不透明
        let maxOffset = headerView.frame.height - ViewUtility.calStatusAndNavBarHeight(in: self)
        var offset = min(maxOffset, scrollView.contentOffset.y)
        offset = max(0, offset)
        headerViewTopConstraint?.constant = -offset

        headerView.layoutIfNeeded()
        navigationController?.navigationBar.prefersLargeTitles = offset < maxOffset / 2
        navigationController?.navigationBar.subviews.first?.alpha = offset / maxOffset
    }
}
