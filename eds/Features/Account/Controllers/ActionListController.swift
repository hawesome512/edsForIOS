//
//  ActionListController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/4.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class ActionListController: UITableViewController {

    private let disposeBag = DisposeBag()

    var actionList = [Action]()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        tableView.register(ActionCell.self, forCellReuseIdentifier: String(describing: ActionCell.self))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = PresentHeaderView()
        headerView.titleLabel.text = title
        headerView.closeButton.rx.tap.bind(onNext: {
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        return headerView
    }

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
