//
//  DeviceSorterController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/6/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class DeviceSorterController: UITableViewController {
    
    var parentDevice:Device? {
        didSet{
            guard let device = parentDevice else { return }
            self.deviceList = DeviceUtility.sharedInstance.getNextBranchList(device: device)
        }
    }
    private var deviceList:[Device] = []
    private let disposeBag = DisposeBag()
    private let cellID = "cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.setEditing(true, animated: false)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = PresentHeaderView()
        headerView.titleLabel.text = parentDevice?.title
        headerView.closeButton.rx.tap.bind(onNext: {
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        return headerView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deviceList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.text = deviceList[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let parentDevice = parentDevice else { return }
        let device = deviceList.remove(at: sourceIndexPath.row)
        deviceList.insert(device, at: destinationIndexPath.row)
        parentDevice.setBranches(with: deviceList)
        DeviceUtility.sharedInstance.update(parentDevice, notifyUpdated: true)
    }

}
