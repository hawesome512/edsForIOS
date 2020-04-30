//
//  WorkorderAdditionViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/26.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya

class AccountAdditionController: UITableViewController {

    private let levelIndex = 1
    private let rows = ["username", "userlevel", "phone", "email"]
    //保持数据前要重各单元格取值，建立一个单元格数组，方便后期利用，因数量不多（4）不会影响整体性能
    private var textInputCells: [TextInputCell] = []
    private let operatorIndex = 0
    private let levelItems: [String] = [UserLevel.phoneOperator.getText(), UserLevel.phoneObserver.getText()]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initViews()
    }

    private func initViews() {

        textInputCells = rows.enumerated().map { row in
            let cell = TextInputCell()
            cell.title = row.element.localize()
            return cell
        }
        textInputCells[levelIndex].items = levelItems

        title = "addAccount".localize()

        tableView.separatorStyle = .none
        tableView.register(TextInputCell.self, forCellReuseIdentifier: String(describing: TextInputCell.self))
        tableView.allowsSelection = false

        //目标大标题显示无效，猜测跟TableVC冲突，待细研究 20.03.30 by.hs
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        navigationItem.rightBarButtonItem = doneButton
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAction))
    }

    @objc func doneAction() {
        let phone = Phone()
        phone.name = textInputCells[0].getValue()
        if let levelText = textInputCells[1].getValue(), let selectedIndex = levelItems.firstIndex(of: levelText) {
            phone.level = selectedIndex == operatorIndex ? .phoneOperator : .phoneObserver
        }
        phone.number = textInputCells[2].getValue()
        if let email = textInputCells[3].getValue(), !email.isEmpty {
            phone.email = email
        }
        //信息不完整,必要工单信息：id(自动生成),title,start,end,task
        guard phone.prepareSaved() else {
            let title = "imcomplete".localize()
            let message = ["username", "userlevel", "phone"].map { $0.localize() }.joined(separator: "/")
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok".localize(), style: .default, handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
            return
        }

        AccountUtility.sharedInstance.phoneList.append(phone)
        AccountUtility.sharedInstance.updatePhone()
        navigationController?.popViewController(animated: true)
    }

    //为了保证弹出的键盘可以被正常关闭，做如下操作：弹出确认框前取消tableView编辑状态，将关闭键盘
    //禁止左滑返回，必须调用dismissAction
    //如果tableView.endEdit触发关闭键盘后马上dismiss VC，键盘并不会被正常关闭，将一直留在APP页面中，影响正常使用
    @objc func dismissAction() {
        //是否编辑过
        let edited = textInputCells.contains(where: {
            if let value = $0.getValue(), !value.isEmpty {
                return true
            } else {
                return false
            }
        })
        if edited {
            let alertVC = UIAlertController(title: "cancel_alert".localize(), message: nil, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let edit = UIAlertAction(title: "edit".localize(), style: .default, handler: nil)
            alertVC.addAction(cancel)
            alertVC.addAction(edit)
            present(alertVC, animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

}


// MARK: -表单实现
extension AccountAdditionController { //:UITableViewDataSource, UITableViewDelegate {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return textInputCells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
