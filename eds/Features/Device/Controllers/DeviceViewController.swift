//
//  DeviceViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/27.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  当TableView滚动时，头图↕️偏移

import UIKit
import Parchment

class DeviceViewController: UIViewController, DevicePageScrollDelegate {

    private let headerView = DeviceHeaderView()
    private var navigationBar: UINavigationBar?
    //头图↕️偏移当约束
    private var headerViewTopConstraint: NSLayoutConstraint?

    var deviceName: String = "" {
        didSet {
            initViews()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        navigationController?.navigationBar.prefersLargeTitles = traitCollection.horizontalSizeClass == .regular
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        //当前VC的父级vc是navigationController,必须设置如UINavigationController-Ext.swift
        return .lightContent
    }

    fileprivate func initViews() {
        title = deviceName
        //顶部图片
        view.addSubview(headerView)
        headerView.horizontalToSuperview()
        headerView.height(to: view, multiplier: 0.3)
        //TinyConstraint未找到相关用法：后台动态约束
        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: headerView.superview!.topAnchor)
        headerViewTopConstraint?.isActive = true

        headerView.imageView.image = TagUtility.getDeviceIcon(with: deviceName)

        let containerView = UIView()
        view.addSubview(containerView)
        containerView.edgesToSuperview(excluding: .top)
        containerView.topToBottom(of: headerView)

        //添加Page View Controller
        if let deviceType = TagUtility.getDeviceType(with: deviceName) {
            let pageVCs = DeviceModel.sharedInstance?.types.first(where: { $0.type == deviceType })?.pages.map { page -> DevicePageTableViewController in
                let pageVC = DevicePageTableViewController()
                pageVC.pageModel = page
                pageVC.scrollDelegate = self
                return pageVC
            }
            //Parchment
            let pagingVC = FixedPagingViewController(viewControllers: pageVCs!)
            addChild(pagingVC)
            containerView.addSubview(pagingVC.view)
            pagingVC.didMove(toParent: self)
            pagingVC.view.edgesToSuperview()
        }
    }

    //MARK:头图滚动偏移

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //动画：tableview往上滚动👉头图偏移往上👉title大>小👉导航栏透明>不透明
        let maxOffset = headerView.frame.height - calStatusAndNavBarHeight()
        var offset = min(maxOffset, scrollView.contentOffset.y)
        offset = max(0, offset)
        headerViewTopConstraint?.constant = -offset

        headerView.layoutIfNeeded()
        navigationController?.navigationBar.prefersLargeTitles = offset < maxOffset / 2
        //navigationController?.navigationBar.subviews.first?.alpha = offset / maxOffset
    }

    private func calStatusAndNavBarHeight() -> CGFloat {

        let statusHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let navHeight = navigationController?.navigationBar.frame.height ?? 0
        return statusHeight + navHeight
    }

}
