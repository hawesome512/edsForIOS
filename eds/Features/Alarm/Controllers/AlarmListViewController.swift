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

    private var alarmList = AlarmUtility.sharedInstance.alarmList
    private let disposeBag = DisposeBag()

    //从设备页调整过来，只显示此设备记录
    func filter(with device: String) {
        alarmList = alarmList.filter { $0.device == device }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        navigationController?.navigationBar.subviews.first?.alpha = 1
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return alarmList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
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

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AdditionTableHeaderView()
        headerView.title.text = "add_alarm".localize(with: prefixAlarm)
        headerView.delegate = self
        return headerView
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension AlarmListViewController: AdditionDelegate {

    func add(inParent parent: Device?) {
        //新增报警记录

    }

}

