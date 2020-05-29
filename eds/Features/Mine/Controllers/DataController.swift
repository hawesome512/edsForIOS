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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        return cell
    }
}
