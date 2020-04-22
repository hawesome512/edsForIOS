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

class AlarmListViewController: UITableViewController {

    private var alarmList = [Alarm]()
    private let disposeBag = DisposeBag()
    private var workorderAlarm: Alarm?

    //从设备页调整过来，只显示此设备记录
    var deviceFilter: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        alarmList = AlarmUtility.sharedInstance.alarmList

        title = Alarm.description
        tableView.separatorStyle = .none
        //记录排序切换：默认（未排查，已排查）
        let reverseButton = UIBarButtonItem()
        reverseButton.image = UIImage(systemName: "arrow.up.arrow.down")
        reverseButton.rx.tap.bind(onNext: {
            self.alarmList.reverse()
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = reverseButton
    }

    override func viewWillAppear(_ animated: Bool) {
        alarmList = AlarmUtility.sharedInstance.alarmList.filter { alarm in
            guard let filter = deviceFilter else {
                return true
            }
            return alarm.device == filter
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return alarmList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return edsCardHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AlarmCell()
        cell.alarm = alarmList[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let alarm = alarmList[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "delete".localize()) { _, _, completionHandler in
            self.delete(alarm, at: indexPath)
            completionHandler(true)
        }
        let checkAction = UIContextualAction(style: .normal, title: "check".localize(with: prefixAlarm)) { _, _, completionHandler in
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

        //已排查Alarm不再需要二次排查
        var actions = [deleteAction, workorderAction]
        if alarm.confirm == .unchecked {
            actions.insert(checkAction, at: 1)
        }
        return UISwipeActionsConfiguration(actions: actions)
    }

    private func delete(_ alarm: Alarm, at indexPath: IndexPath) {
        let deleteController = ControllerUtility.generateDeletionAlertController(with: Alarm.description)
        let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
            //更新3处：本页，单例，后台
            self.alarmList.removeAll(where: { $0.id == alarm.id })
            AlarmUtility.sharedInstance.remove(with: alarm.id)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            alarm.prepareForDelete()
            MoyaProvider<EDSService>().request(.updateAlarm(alarm: alarm)) { _ in }
        }
        deleteController.addAction(deleteAction)
        present(deleteController, animated: true, completion: nil)
    }

    private func check(_ alarm: Alarm, at indexPath: IndexPath) {
        alarm.confirm = .checked
        AlarmUtility.sharedInstance.check(with: alarm.id)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        MoyaProvider<EDSService>().request(.updateAlarm(alarm: alarm)) { _ in }
    }

    private func workorder(_ alarm: Alarm, at indexPath: IndexPath) {
        let id = alarm.report
        //已存在工单，直接打开
        if !id.isEmpty, let workorder = WorkorderUtility.sharedInstance.get(by: id) {
            let workorderVC = WorkorderViewController()
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
            let additionVC = WorkorderAdditionViewController()
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
        alarmVC.alarm = alarmList[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? AlarmCell {
            alarmVC.title = (cell.deviceLabel.text ?? "") + " " + (cell.titleLabel.text ?? "")
        }
        alarmVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(alarmVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: - 新增工单
extension AlarmListViewController: WorkorderAdditionDelegate {
    func added(workorder: Workorder) {
        workorderAlarm!.report = workorder.id
        WorkorderUtility.sharedInstance.update(with: workorder)
        AlarmUtility.sharedInstance.workorder(workorderAlarm!.id, workorderID: workorder.id)
        alarmList = AlarmUtility.sharedInstance.alarmList
        MoyaProvider<EDSService>().request(.updateAlarm(alarm: workorderAlarm!)) { _ in }
    }


}

