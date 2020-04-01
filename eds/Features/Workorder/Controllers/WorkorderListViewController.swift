//
//  WorkorderListViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya

class WorkorderListViewController: UITableViewController, WorkorderAdditionDelegate {


    var workorderList: [Workorder] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {

        title = Workorder.description
        navigationController?.navigationBar.prefersLargeTitles = false
        tableView.separatorStyle = .none
        tableView.register(WorkorderCell.self, forCellReuseIdentifier: Workorder.description)
        let reverseButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(reverseWorkorder))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWorkorder))
        navigationItem.rightBarButtonItems = [addButton, reverseButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        //从工单页面（已修改更新）返回时，刷新列表数据
        workorderList = WorkorderUtility.sharedInstance.workorderList
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return workorderList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Workorder.description, for: indexPath) as! WorkorderCell
        cell.workorder = workorderList[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workorderVC = WorkorderViewController()
        workorderVC.workorder = workorderList[indexPath.row]
        navigationController?.pushViewController(workorderVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let workorder = workorderList[indexPath.row]
            let deleteVC = ControllerUtility.generateDeletionAlertController(with: workorder.title)
            let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
                workorder.prepareDeleted()
                MoyaProvider<EDSService>().request(.updateWorkorder(workorder: workorder)) { _ in }
                self.workorderList.remove(at: indexPath.row)
                WorkorderUtility.sharedInstance.workorderList = self.workorderList
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            deleteVC.addAction(deleteAction)
            present(deleteVC, animated: true, completion: nil)
        }
    }

    @objc func addWorkorder() {
        let addVC = WorkorderAdditionViewController()
        addVC.delegate = self
        navigationController?.pushViewController(addVC, animated: true)
    }

    @objc func reverseWorkorder() {
        workorderList = workorderList.reversed()
        tableView.reloadData()
    }

    func added(workorder: Workorder) {
        workorderList.insert(workorder, at: 0)
        WorkorderUtility.sharedInstance.workorderList = workorderList
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }

}
