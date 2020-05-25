//
//  NoticeController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/24.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class NoticeController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "notice_title".localize(with: prefixHome)
        tableView.register(NoticeMessageCell.self, forCellReuseIdentifier: String(describing: NoticeMessageCell.self))
        tableView.register(NoticeAdditionCell.self, forCellReuseIdentifier: String(describing: NoticeAdditionCell.self))
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return AccountUtility.sharedInstance.isOperable() ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NoticeMessageCell.self), for: indexPath) as! NoticeMessageCell
            cell.noticeText = BasicUtility.sharedInstance.getBasic()?.notice
            cell.parentVC = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NoticeAdditionCell.self), for: indexPath) as! NoticeAdditionCell
            cell.parentVC = self
            return cell
        }
    }

}
