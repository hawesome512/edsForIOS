//
//  MineController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import MessageUI

class MineController: UIViewController {

    private let disposeBag = DisposeBag()
    let headerView = MineHeaderView()
    let tableView = UITableView()
    //头图↕️偏移当约束
    private var headerViewTopConstraint: NSLayoutConstraint?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initViews()
    }

    private func initViews() {
        headerView.loginedPhone = AccountUtility.sharedInstance.loginedPhone
        headerView.parentVC = self
        view.addSubview(headerView)
        headerView.horizontalToSuperview()
        headerView.height(to: view, multiplier: 0.4)
        //TinyConstraint未找到相关用法：后台动态约束
        headerViewTopConstraint = headerView.topAnchor.constraint(equalTo: headerView.superview!.topAnchor)
        headerViewTopConstraint?.isActive = true

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = edsDivideColor
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        view.addSubview(tableView)
        tableView.edgesToSuperview(excluding: .top)
        tableView.topToBottom(of: headerView)
    }

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
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 1
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
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

extension MineController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return MineSectionModel.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MineSectionModel(rawValue: section)?.getNumberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = MineSectionModel.getCellTitle(indexPath)
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        if let sectionModel = MineSectionModel(rawValue: indexPath.section) {
            switch sectionModel {
            case .user:
                break
            case .eds:
                break
            default:
                break
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sectionModel = MineSectionModel(rawValue: indexPath.section) {
            switch sectionModel {
            case .user:
                if indexPath.row == 0 {
                    let accountListVC = AccountListController()
                    accountListVC.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(accountListVC, animated: true)
                } else {
                    let qrcodeVC = AccountQRCodeController()
                    qrcodeVC.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(qrcodeVC, animated: true)
                }
            case .eds:
                if indexPath.row == 0 {
                    let aboutVC = AboutController()
                    aboutVC.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(aboutVC, animated: true)
                } else if indexPath.row == 1 {
                    let helpVC = HelpListController()
                    helpVC.hidesBottomBarWhenPushed = true
                    present(helpVC, animated: true, completion: nil)
                } else {
                    let emailAddress = "haisheng.xu@xseec.cn"
                    let title = "feedbackEDS".localize()
                    ShareUtility.sendMail(to: emailAddress, title: title, content: "", imageData: nil, in: self)
                }
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = edsDivideColor
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if MineSectionModel(rawValue: section) == MineSectionModel.exit {
            let exitButton = UIButton()
            exitButton.setTitle("exitEDS".localize(), for: .normal)
            exitButton.setTitleColor(.systemRed, for: .normal)
            exitButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
            exitButton.backgroundColor = .white
            exitButton.rx.tap.bind(onNext: {
                AccountUtility.sharedInstance.prepareExitAccount()
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
            return exitButton
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if MineSectionModel(rawValue: section) == MineSectionModel.exit {
            return 50
        } else {
            return 0
        }
    }

}

extension MineController: MFMailComposeViewControllerDelegate {
    //邮件派发状态
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
