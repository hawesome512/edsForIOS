//
//  WorkorderListViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class WorkorderListViewController: UITableViewController {

    var workorderList = WorkorderUtility.sharedInstance.workorderList

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        tableView.separatorStyle = .none
        tableView.register(WorkorderCell.self, forCellReuseIdentifier: Workorder.description)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return workorderList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Workorder.description, for: indexPath) as! WorkorderCell
        cell.workorder = workorderList[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AdditionTableHeaderView()
        headerView.title.text = "add_workorder".localize(with: prefixWorkorder)
        headerView.delegate = self
        return headerView
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workorderVC = WorkorderViewController()
        workorderVC.workorder = workorderList[indexPath.row]
        navigationController?.pushViewController(workorderVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension WorkorderListViewController: AdditionDelegate {

    func add(inParent parent: Device?) {
        //新增报警记录

    }

}
