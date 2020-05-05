//
//  ActionListController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/4.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class ActionListController: UITableViewController {

    var actionList = [Action]()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        tableView.register(ActionCell.self, forCellReuseIdentifier: String(describing: ActionCell.self))
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return actionList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ActionCell.self), for: indexPath) as! ActionCell
        cell.action = actionList[indexPath.row]
        return cell
    }

}
