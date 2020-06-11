//
//  WorkorderListViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya
import RxSwift

class WorkorderListController: UITableViewController, WorkorderAdditionDelegate {
    
    private let disposeBag = DisposeBag()
    var workorderList: [Workorder] = []
    var searchWorkorderList = [Workorder]()
    var searchVC = UISearchController()
    
    //从设备页导航过来查看相应设备的工单
    var deviceFilter: String?
    //从首页导航过来查看相应状态（逾期、计划、完成）的工单
    var flowFilter: FlowTimeLine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    private func initViews() {
        
        title = Workorder.description
        navigationController?.navigationBar.prefersLargeTitles = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = edsDivideColor
        tableView.register(WorkorderCell.self, forCellReuseIdentifier: Workorder.description)
        let reverseButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(reverseWorkorder))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWorkorder))
        let updateButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWorkorder))
        if AccountUtility.sharedInstance.isOperable() {
            navigationItem.rightBarButtonItems = [addButton, updateButton, reverseButton]
        } else {
            navigationItem.rightBarButtonItems = [updateButton, reverseButton]
        }
        
        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchVC
        
        WorkorderUtility.sharedInstance.successfulUpdated.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {result in
            self.updateWorkorderList()
        }).disposed(by: disposeBag)
    }
    
    func updateWorkorderList(){
        let tempList = WorkorderUtility.sharedInstance.getWorkorderList().filter { workorder in
            if let filter = deviceFilter {
                return workorder.location.contains(filter)
            } else if let filter = flowFilter {
                return workorder.getFlowTimeLine() == filter
            } else {
                return true
            }
        }
        workorderList=tempList
        tableView.reloadData()
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
        let workorderVC = WorkorderController()
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
                WorkorderUtility.sharedInstance.removeWorkorder(workorder)
            }
            deleteVC.addAction(deleteAction)
            self.present(deleteVC, animated: true, completion: nil)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    @objc func addWorkorder() {
        let addVC = NewWorkorderController()
        addVC.delegate = self
        addVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addVC, animated: true)
    }
    
    @objc func reverseWorkorder(_ sender: UIBarButtonItem) {
        workorderList = workorderList.reversed()
        tableView.reloadData()
        sender.plainView.loadedWithAnimation()
    }
    
    @objc func refreshWorkorder(_ sender: UIBarButtonItem){
        WorkorderUtility.sharedInstance.loadProjectWorkerorderList()
        sender.plainView.loadedWithAnimation()
    }
    
    func added(workorder: Workorder) {
        workorderList.insert(workorder, at: 0)
        WorkorderUtility.sharedInstance.update(with: workorder)
    }
    
}

extension WorkorderListController: UISearchResultsUpdating {
    
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
