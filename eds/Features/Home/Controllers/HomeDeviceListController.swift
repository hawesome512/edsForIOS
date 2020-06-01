//
//  HomeDeviceListController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/13.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  不与DeviceListVC公用：因为此列表比较简单：无层级缩进关系，无新增，无折叠

import UIKit
import RxSwift

class HomeDeviceListController: UITableViewController {

    var deviceList = [Device]()
    var parentVC: UIViewController?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(DeviceDynamicCell.self, forCellReuseIdentifier: DeviceCellType.dynamic.rawValue)
        tableView.register(DeviceFixedCell.self, forCellReuseIdentifier: DeviceCellType.fixed.rawValue)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return deviceList[indexPath.row].getCellType().getRowHeight(in: tableView)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = deviceList[indexPath.row]
        if device.level == .dynamic {
            let cell = DeviceDynamicCell()
            cell.device = device
            return cell
        } else {
            let cell = DeviceFixedCell()
            cell.indentationLevel = device.getIndentationLevel()
            cell.device = device
            //不折叠，全展开,这可能是.room,.box,.fixed(无展开图标）
            if device.level != .fixed {
                cell.foldButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            }
            //无新增
            //cell.delegate=self
            cell.accessoryView = nil
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = deviceList[indexPath.row]
        if device.level == .dynamic {
            let dynamicVC = DynamicDeviceController()
            dynamicVC.device = device
            dynamicVC.hidesBottomBarWhenPushed = true
            parentVC?.navigationController?.pushViewController(dynamicVC, animated: true)
        } else {
            let fixedVC = FixedDeviceController()
            fixedVC.device = device
            fixedVC.hidesBottomBarWhenPushed = true
            parentVC?.navigationController?.pushViewController(fixedVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: false)
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = PresentHeaderView()
        headerView.titleLabel.text = title
        headerView.closeButton.rx.tap.bind(onNext: {
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.estimatedRowHeight
    }

}
