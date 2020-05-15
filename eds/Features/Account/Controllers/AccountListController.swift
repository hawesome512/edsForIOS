//
//  AccountListController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/30.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class AccountListController: UITableViewController, AdditionDelegate {

    private let disposeBag = DisposeBag()
    var accountList = [Phone]()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        title = "accountMember".localize()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = tableView.estimatedRowHeight
        tableView.register(AccountCell.self, forCellReuseIdentifier: String(describing: AccountCell.self))

        ActionUtility.sharedInstance.loadProjectActionList()
        ActionUtility.sharedInstance.successfulLoaded.bind(onNext: { loaded in
            if loaded {
                self.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        //从新增用户页面返回刷新列表
        accountList = AccountUtility.sharedInstance.phoneList
        tableView.reloadData()
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return accountList.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let loginedAccount = AccountUtility.sharedInstance.loginedPhone!
        guard loginedAccount.level <= .phoneAdmin else {
            return nil
        }
        let headerView = AdditionTableHeaderView()
        headerView.title.text = "addAccount".localize()
        headerView.delegate = self
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let loginedAccount = AccountUtility.sharedInstance.loginedPhone!
        return loginedAccount.level == .phoneAdmin ? tableView.estimatedRowHeight : 0
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //当前登录用户必须是管理员，且cell不是自身才能（删除+转让管理员
        let account = accountList[indexPath.row]
        let loginedAccount = AccountUtility.sharedInstance.loginedPhone!
        guard loginedAccount.level <= .phoneAdmin, account.level > .phoneAdmin else {
            return nil
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "delete".localize()) { _, _, completionHandler in
            let deleteVC = ControllerUtility.generateDeletionAlertController(with: account.name ?? "")
            let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive, handler: { _ in
                self.accountList.remove(at: indexPath.row)
                AccountUtility.sharedInstance.phoneList.remove(at: indexPath.row)
                AccountUtility.sharedInstance.updatePhone()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                ActionUtility.sharedInstance.addAction(.deleteAccount, extra: account.name)
            })
            deleteVC.addAction(deleteAction)
            self.present(deleteVC, animated: true, completion: nil)
            completionHandler(true)
        }
        let title = "transferAccount".localize()
        let transferAction = UIContextualAction(style: .normal, title: title) { _, _, completionHander in
            let message = "transferAccountAlert".localize()
            let transferVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "confirm".localize(), style: .default, handler: { _ in
                loginedAccount.level = .phoneOperator
                account.level = .phoneAdmin
                AccountUtility.sharedInstance.updatePhone()
                tableView.reloadData()
                ActionUtility.sharedInstance.addAction(.transferAccount, extra: account.name)
            })
            let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
            transferVC.addAction(cancelAction)
            transferVC.addAction(confirmAction)
            self.present(transferVC, animated: true, completion: nil)
            completionHander(true)
        }

        //系统管理员只能删除其他非管理员用户，不能删除手机管理员，也不能转移管理员
        if loginedAccount.level == .systemAdmin {
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, transferAction])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccountCell.self), for: indexPath) as! AccountCell
        let phone = accountList[indexPath.row]
        cell.phone = phone
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let username = accountList[indexPath.row].name {
            let actionListVC = ActionListController()
            actionListVC.actionList = ActionUtility.sharedInstance.getAction(by: username)
            actionListVC.title = username
            present(actionListVC, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //新增用户
    func add(inParent parent: Device?) {
        //用户组数量限制
        if accountList.count >= AccountUtility.sharedInstance.account!.number {
            let message = String(format: "addAccountLimit".localize(), accountList.count)
            let limitVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok".localize(), style: .cancel, handler: nil)
            limitVC.addAction(okAction)
            present(limitVC, animated: true, completion: nil)
            return
        }
        let additionVC = AccountAdditionController()
        navigationController?.pushViewController(additionVC, animated: true)
    }
}
