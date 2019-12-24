//
//  DeviceListViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/24.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class DeviceListViewController: UIViewController {

    private let tableView = UITableView()
    private let deviceNames = TagUtility.sharedInstance.getDeviceList()
    private let cellType = DeviceCellType.DeviceDynamicCell

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    fileprivate func initViews() {

        title = NSLocalizedString("资产", comment: "Device List Title")
        navigationController?.navigationBar.prefersLargeTitles = false

        tableView.register(DeviceDynamicCell.self, forCellReuseIdentifier: cellType.rawValue)
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    }



}

extension DeviceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceNames.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let config = cellType.getRowHeight()
        return max(config.ratio * tableView.frame.height, config.min)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.rawValue) as! DeviceDynamicCell
        let name = deviceNames[indexPath.row]
        cell.nameLabel.text = name
        cell.deviceImageView.image = TagUtility.getDeviceIcon(with: name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //设置Footer将移除tableview底部空白cell的separator line
        return UIView()
    }

}
