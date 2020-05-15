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
    var searchWorkorderList = [Workorder]()
    var searchVC = UISearchController()

    var deviceFilter: String?

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
        if AccountUtility.sharedInstance.isOperable() {
            navigationItem.rightBarButtonItems = [addButton, reverseButton]
        } else {
            navigationItem.rightBarButtonItems = [reverseButton]
        }

        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchVC
    }

    override func viewWillAppear(_ animated: Bool) {
        //从工单页面（已修改更新）返回时，刷新列表数据
        workorderList = WorkorderUtility.sharedInstance.workorderList.filter { workorder in
            guard let filter = deviceFilter else {
                return true
            }
            return workorder.location.contains(filter)
        }
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchVC.isActive ? searchWorkorderList.count : workorderList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Workorder.description, for: indexPath) as! WorkorderCell
        cell.workorder = searchVC.isActive ? searchWorkorderList[indexPath.row] : workorderList[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return edsCardHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let workorderVC = WorkorderViewController()
        workorderVC.workorder = searchVC.isActive ? searchWorkorderList[indexPath.row] : workorderList[indexPath.row]
        workorderVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(workorderVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }



    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard AccountUtility.sharedInstance.isOperable() else {
            return nil
        }
        let workorder = searchVC.isActive ? searchWorkorderList[indexPath.row] : workorderList[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "delete".localize()) { _, _, completionHandler in
            let deleteVC = ControllerUtility.generateDeletionAlertController(with: workorder.title)
            let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
                let title = workorder.title
                workorder.prepareDeleted()
                EDSService.getProvider().request(.updateWorkorder(workorder: workorder)) { _ in }
                self.workorderList.remove(at: indexPath.row)
                WorkorderUtility.sharedInstance.workorderList = self.workorderList
                tableView.deleteRows(at: [indexPath], with: .automatic)
                ActionUtility.sharedInstance.addAction(.deleteWorkorder, extra: title)
            }
            deleteVC.addAction(deleteAction)
            self.present(deleteVC, animated: true, completion: nil)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    @objc func addWorkorder() {
        let addVC = WorkorderAdditionViewController()
        addVC.delegate = self
        addVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addVC, animated: true)
    }

    @objc func reverseWorkorder() {
        workorderList = workorderList.reversed()
        tableView.reloadData()
    }

    func added(workorder: Workorder) {
        workorderList.insert(workorder, at: 0)
        WorkorderUtility.sharedInstance.update(with: workorder)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }

}

extension WorkorderListViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            searchWorkorderList = workorderList.filter { workorder in
                return workorder.title.contains(searchText) || workorder.worker.contains(searchText) ||
                    workorder.getShortTimeRange().contains(searchText) || workorder.location.contains(searchText)
            }
            tableView.reloadData()
        }
    }

}
