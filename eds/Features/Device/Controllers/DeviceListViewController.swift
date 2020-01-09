//
//  DeviceListViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/24.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  设备列表：静态设备，动态设备，可折叠，增删调整，自定义

import UIKit
import Moya

class DeviceListViewController: UIViewController {

    private let tableView = UITableView()
    private let deviceNames = TagUtility.sharedInstance.getDeviceList()
    private let cellType = DeviceCellType.dynamic

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    fileprivate func initViews() {
        //再更新一次动态设备状态点
        updateDeviceStatus()
        //设定导航栏
        title = "property".localize(with: prefixDevice)
        navigationController?.navigationBar.prefersLargeTitles = false
        //TableView
        tableView.register(DeviceDynamicCell.self, forCellReuseIdentifier: cellType.rawValue)
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.edgesToSuperview()

    }

    //MARK:更新状态位数据
    private func updateDeviceStatus() {
        var statusTagList = [Tag]()
        deviceNames.forEach { deviceName in
            if let statusTagName = DeviceModel.sharedInstance?.types.first(where: {
                $0.type == TagUtility.getDeviceType(with: deviceName)
            })?.status.tag {
                statusTagList.append(Tag(name: deviceName + Tag.nameSeparator + statusTagName))
            }
        }
        TagUtility.sharedInstance.updateTagList(with: statusTagList)
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
        cell.deviceName = name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceViewController = DeviceViewController()
        deviceViewController.deviceName = deviceNames[indexPath.row]
        navigationController?.pushViewController(deviceViewController, animated: true)

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //设置Footer将移除tableview底部空白cell的separator line
        return UIView()
    }
}
