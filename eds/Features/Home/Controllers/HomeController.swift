//
//  HomeController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class HomeController: UIViewController {

    private let headerView = HomeHeaderView()
    private let disposeBag = DisposeBag()
    //头图↕️偏移当约束
    private var headerViewTopConstraint: NSLayoutConstraint?

    private let tableView = UITableView()
    private var myWorkorder: Workorder?

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        // Do any additional setup after loading the view.
    }

    private func initViews() {

        //此处不设置title,因title将影响tab bar item的title,在本页中它应一直保持为“首页”
        navigationItem.title = BasicUtility.sharedInstance.basic?.user
        navigationController?.navigationBar.subviews.first?.alpha = 0
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]

        let qrButton = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(scanQRCode))
        navigationItem.rightBarButtonItem = qrButton

        //顶部图片
        headerView.parentVC = self
        view.addSubview(headerView)
        headerView.horizontalToSuperview()
        headerView.height(to: view, multiplier: 0.3)
        //TinyConstraint未找到相关用法：后台动态约束
        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: headerView.superview!.topAnchor)
        headerViewTopConstraint?.isActive = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(HomeDeviceCell.self, forCellReuseIdentifier: String(describing: HomeDeviceCell.self))
        tableView.register(HomeEnergyCell.self, forCellReuseIdentifier: String(describing: HomeEnergyCell.self))
        tableView.register(HomeWorkorderCell.self, forCellReuseIdentifier: String(describing: HomeWorkorderCell.self))
        view.addSubview(tableView)
        tableView.edgesToSuperview(excluding: .top)
        tableView.topToBottom(of: headerView)
    }

    @objc func scanQRCode() { }


    //MARK:头图滚动偏移
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //动画：tableview往上滚动👉头图偏移往上👉title大>小👉导航栏透明>不透明
        let maxOffset = headerView.frame.height - ViewUtility.calStatusAndNavBarHeight(in: self)
        var offset = min(maxOffset, scrollView.contentOffset.y)
        offset = max(0, offset)
        headerViewTopConstraint?.constant = -offset

        updateNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        //从其他页面返回此页面时，导航栏样式可能被更改
        updateNavigationBar()
        headerView.basic = BasicUtility.sharedInstance.basic
        myWorkorder = WorkorderUtility.sharedInstance.getMyWorkorder()
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 1
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(1)]
    }

    func updateNavigationBar() {
        guard let offset = headerViewTopConstraint?.constant else {
            return
        }
        let maxOffset = headerView.frame.height - ViewUtility.calStatusAndNavBarHeight(in: self)
        headerView.layoutIfNeeded()
        let alpha: CGFloat = offset / maxOffset
        navigationController?.navigationBar.subviews.first?.alpha = alpha
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(alpha)]
        headerView.alpha = 1 - alpha
    }

}

extension HomeController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bottomHeight = tabBarController?.tabBar.bounds.height ?? 0
        let height = UIScreen.main.bounds.height * 0.7 - bottomHeight
        return max(edsCardHeight, height / 3)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeDeviceCell.self), for: indexPath) as! HomeDeviceCell
            cell.parentVC = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeEnergyCell.self), for: indexPath) as! HomeEnergyCell
            cell.energyData = BasicUtility.sharedInstance.energyBranch?.energyData
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeWorkorderCell.self), for: indexPath) as! HomeWorkorderCell
            cell.workorder = myWorkorder
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            let energyVC = EnergyController()
            //copy传递副本，在用电分析中branch.energyData会更改，不能影响EnergyUtility.energyBranch
            energyVC.energyBranch = BasicUtility.sharedInstance.energyBranch?.copy()
            energyVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(energyVC, animated: true)
        case 2:
            let workorderVC = WorkorderViewController()
            workorderVC.workorder = myWorkorder
            workorderVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(workorderVC, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
