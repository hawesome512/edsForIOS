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

class DynamicDeviceController: UIViewController, DevicePageScrollDelegate {
    
    private let headerView = DeviceHeaderView()
    private let pagingViewController = PagingViewController() //PagingViewController<IconItem>()
    private var navigationBar: UINavigationBar?
    
    //头图↕️偏移当约束
    private var headerViewTopConstraint: NSLayoutConstraint?
    
    private var pages: [DevicePage] = []
    
    var device: Device? {
        didSet {
            initViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem=UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(sharePage))
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
        guard let device = device else {
            return
        }
        title = device.title
        
        //顶部图片
        headerView.parentVC = self
        view.addSubview(headerView)
        headerView.horizontalToSuperview()
        headerView.height(to: view, multiplier: 0.3)
        //TinyConstraint未找到相关用法：后台动态约束
        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: headerView.superview!.topAnchor)
        headerViewTopConstraint?.isActive = true
        headerView.device = device
        
        let containerView = UIView()
        view.addSubview(containerView)
        containerView.edgesToSuperview(excluding: .top)
        containerView.topToBottom(of: headerView)
        
        //添加Page View Controller
        if let type = TagUtility.getDeviceType(with: device.getShortID()) {
            let deviceType = DeviceModel.sharedInstance?.types.first(where: { $0.type == type })
            //Icon类型的Menu Item
            pages = deviceType?.pages ?? []
            pagingViewController.dataSource = self
            pagingViewController.delegate = self
//            pagingViewController.menuItemSource = .class(type: IconPagingCell.self)
            pagingViewController.register(IconPagingCell.self, for: IconItem.self)
            //均分window.width
            pagingViewController.menuItemSize = .sizeToFit(minWidth: 100, height: 60)
            //活跃页颜色
            pagingViewController.indicatorColor = .systemRed
            pagingViewController.select(index: 0)
            
            addChild(pagingViewController)
            pagingViewController.didMove(toParent: self)
            containerView.addSubview(pagingViewController.view)
            pagingViewController.view.edgesToSuperview()
        }
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

// MARK: -Paging View Controller DataSource
extension DynamicDeviceController: PagingViewControllerDataSource, PagingViewControllerDelegate {
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        let iconName = (index == pages.count) ? "info" : pages[index].title
        let icon = "device_\(iconName)"
        return IconItem(icon: icon, index: index)
    }
    
    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        if index == pages.count {
            let tableVC = FixedInfoChildController(style: .plain)
            tableVC.scrollDelegate = self
            tableVC.device = device
            tableVC.parentVC = self
            return tableVC
        } else {
            let pageVC = PageItemController()
            pageVC.set(with: pages[index], in: device!.getShortID())
            pageVC.scrollDelegate = self
            pageVC.parentVC = self
            return pageVC
        }
    }
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return pages.count+1
    }
    
    
    //在最后面+1静态信息页
    
//    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController {
//        if index == pages.count {
//            let tableVC = FixedInfoChildController(style: .plain)
//            tableVC.scrollDelegate = self
//            tableVC.device = device
//            tableVC.parentVC = self
//            return tableVC
//        } else {
//            let pageVC = PageItemController()
//            pageVC.set(with: pages[index], in: device!.getShortID())
//            pageVC.scrollDelegate = self
//            pageVC.parentVC = self
//            return pageVC
//        }
//
//    }
//
//    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T {
//        let iconName = (index == pages.count) ? "info" : pages[index].title
//        let icon = "device_\(iconName)"
//        return IconItem(icon: icon, index: index) as! T
//    }
//
//    func numberOfViewControllers<T>(in: PagingViewController<T>) -> Int {
//        return pages.count + 1
//    }
    
}
