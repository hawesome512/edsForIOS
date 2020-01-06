//
//  DeviceViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/27.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  当TableView滚动时，头图↕️偏移

import UIKit
import Parchment
import TinyConstraints

class DeviceViewController: UIViewController, DevicePageScrollDelegate {

    private let headerView = DeviceHeaderView()
    private var navigationBar: UINavigationBar?
    //头图↕️偏移当约束
    private var headerViewTopConstraint: NSLayoutConstraint?

    private var pages: [DevicePage] = []

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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.subviews.first?.alpha = 0
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
            //Icon类型的Menu Item
            pages = DeviceModel.sharedInstance?.types.first(where: { $0.type == deviceType })?.pages ?? []
            let pagingViewController = PagingViewController<IconItem>()
            pagingViewController.dataSource = self
            pagingViewController.menuItemSource = .class(type: IconPagingCell.self)
            //均分window.width
            pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 60)
            //活跃页颜色
            pagingViewController.indicatorColor = .systemRed

            addChild(pagingViewController)
            pagingViewController.didMove(toParent: self)
            containerView.addSubview(pagingViewController.view)
            pagingViewController.view.edgesToSuperview()
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
        navigationController?.navigationBar.subviews.first?.alpha = offset / maxOffset
    }

    private func calStatusAndNavBarHeight() -> CGFloat {

        let statusHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let navHeight = navigationController?.navigationBar.frame.height ?? 0
        return statusHeight + navHeight
    }

}

// MARK: -Paging View Controller DataSource
extension DeviceViewController: PagingViewControllerDataSource {

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
        let pageVC = DevicePageTableViewController()
        pageVC.set(with: pages[index], in: deviceName)
        pageVC.scrollDelegate = self
        return pageVC
    }

    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
        let icon = "device_\(pages[index].title)"
        return IconItem(icon: icon, index: index) as! T
    }

    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
        return pages.count
    }

}
