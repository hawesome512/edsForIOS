//
//  DataController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/27.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  我的数据页面，后续评估是否有必要实现

import UIKit

class DataController: UITableViewController {
    
    private let cellID="cell"
    private let dataModels = DataModel.allCases.map{(model:$0,items:$0.getItems())}

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "accountData".localize()
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataModels.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SectionHeaderView()
        headerView.title = dataModels[section].model.getTitle()
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataModels[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .value1, reuseIdentifier: cellID)
        let item = dataModels[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        let account = AccountUtility.sharedInstance.account
        if indexPath.section == 2 && indexPath.row == 0, let limit = account?.number, let number = account?.getPhones().count {
            cell.detailTextLabel?.text = "\(number) / \(limit)"
            cell.detailTextLabel?.textColor = .systemRed
        } else if indexPath.section == 2 && indexPath.row == 1, let limit = account?.device {
            let number = DeviceUtility.sharedInstance.getDeviceList().count
            cell.detailTextLabel?.text = "\(number) / \(limit)"
            cell.detailTextLabel?.textColor = .systemRed
        } else {
            cell.detailTextLabel?.text = item.value
            cell.detailTextLabel?.textColor = edsDefaultColor
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
