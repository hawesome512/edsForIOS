//
//  AlarmListViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya
import RxSwift

class AlarmListController: UITableViewController {

    private var alarmList = [Alarm]()
    private let disposeBag = DisposeBag()
    private var workorderAlarm: Alarm?

    private let searchVC = UISearchController(searchResultsController: nil)
    private var searchAlarmList = [Alarm]()

    //从设备页跳转过来，只显示此设备记录
    var deviceFilter: String?
    //从首页跳转过来，只显示已排查/未排查的记录
    var confirmFilter: AlarmConfirm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initData()
    }
    
    private func initViews(){
        title = Alarm.description
        tableView.backgroundColor = edsDivideColor
        tableView.separatorStyle = .none
        //记录排序切换：默认（未排查，已排查）
        let reverseButton = UIBarButtonItem()
        reverseButton.image = UIImage(systemName: "arrow.up.arrow.down")
        reverseButton.rx.tap.bind(onNext: {
            self.alarmList.reverse()
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = reverseButton

        searchVC.obscuresBackgroundDuringPresentation = false
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
    
    private func initData(){
        let deviceUpdated = DeviceUtility.sharedInstance.successfulUpdated
        let alarmUpdated = AlarmUtility.sharedInstance.successfulUpdated
        //报警针对的是设备，先确认设备已载入
        Observable.combineLatest(deviceUpdated,alarmUpdated).throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {(deviceResult,alarmResult) in
            guard deviceResult,alarmResult else { return }
            
            self.alarmList = AlarmUtility.sharedInstance.getAlarmList().filter { alarm in
                //设备已经被从资产列表中删除，报警记录不再显示
                guard let _ = DeviceUtility.sharedInstance.getDevice(of: alarm.device) else {
                    return false
                }
                if let filter = self.confirmFilter {
                    return alarm.confirm == filter
                } else if let filter = self.deviceFilter {
                    return alarm.device == filter
                } else {
                    return true
                }
            }
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchVC.isActive ? searchAlarmList.count : alarmList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return edsCardHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AlarmCell()
        cell.alarm = searchVC.isActive ? searchAlarmList[indexPath.row] : alarmList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard AccountUtility.sharedInstance.isOperable() else {
            return nil
        }
        let alarm = searchVC.isActive ? searchAlarmList[indexPath.row] : alarmList[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "delete".localize()) { _, _, completionHandler in
            self.delete(alarm, at: indexPath)
            completionHandler(true)
        }
        let checkAction = UIContextualAction(style: .normal, title: alarm.confirm.getToggleText()) { _, _, completionHandler in
            self.check(alarm, at: indexPath)
            completionHandler(true)
        }
        let workorderAction = UIContextualAction(style: .normal, title: Workorder.description) { _, _, completionHandler in
            self.workorder(alarm, at: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        checkAction.backgroundColor = .systemGreen
        checkAction.image = UIImage(systemName: "checkmark.shield")
        workorderAction.backgroundColor = .systemBlue
        workorderAction.image = Workorder.icon

        let actions = [deleteAction, checkAction, workorderAction]
        return UISwipeActionsConfiguration(actions: actions)
    }

    private func delete(_ alarm: Alarm, at indexPath: IndexPath) {
        let deleteController = ControllerUtility.generateDeletionAlertController(with: Alarm.description)
        let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
            AlarmUtility.sharedInstance.remove(alarm)
        }
        deleteController.addAction(deleteAction)
        present(deleteController, animated: true, completion: nil)
    }

    private func check(_ alarm: Alarm, at indexPath: IndexPath) {
        AlarmUtility.sharedInstance.check(alarm)
    }

    private func workorder(_ alarm: Alarm, at indexPath: IndexPath) {
        let id = alarm.report
        //已存在工单，直接打开
        if !id.isEmpty, let workorder = WorkorderUtility.sharedInstance.get(by: id) {
            let workorderVC = WorkorderController()
            workorderVC.workorder = workorder
            workorderVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(workorderVC, animated: true)
        } else {
            workorderAlarm = alarm
            let workorder = Workorder()
            let cell = tableView.cellForRow(at: indexPath) as! AlarmCell
            workorder.title = cell.titleLabel.text ?? ""
            workorder.type = .alarm
            if let device = DeviceUtility.sharedInstance.getDevice(of: alarm.device) {
                workorder.location = device.title
            }
            let message = WorkorderMessage.encode(with: alarm.id)
            workorder.setMessage([message])
            let additionVC = NewWorkorderController()
            additionVC.workorder = workorder
            additionVC.delegate = self
            additionVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(additionVC, animated: true)
        }

    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alarmVC = AlarmViewController()
        alarmVC.alarm = searchVC.isActive ? searchAlarmList[indexPath.row] : alarmList[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? AlarmCell {
            //直接传递，较少重复转化计算
            alarmVC.title = (cell.deviceLabel.text!) + "(\(cell.titleLabel.text!))"
        }
        alarmVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(alarmVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: - 新增工单,搜索结果
extension AlarmListController: WorkorderAdditionDelegate, UISearchResultsUpdating {

    /// 从异常类型和设备名称中筛选
    /// - Parameter searchController: <#searchController description#>
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            searchAlarmList = alarmList.filter { alarm in
                if let device = DeviceUtility.sharedInstance.getDevice(of: alarm.device) {
                    let alarmText = TagValueConverter.getAlarmText(with: alarm.alarm, device: device)
                    return alarmText.contains(searchText) || device.title.contains(searchText)
                } else {
                    return false
                }
            }
            tableView.reloadData()
        }
    }

    func added(workorder: Workorder) {
        workorderAlarm!.report = workorder.id
        WorkorderUtility.sharedInstance.update(with: workorder)
        AlarmUtility.sharedInstance.update(workorderAlarm!)
    }


}


