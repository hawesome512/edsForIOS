//
//  DeviceListViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/24.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  设备列表：静态设备，动态设备，可折叠，增删调整，自定义

import UIKit
import Moya
import RxSwift

class DeviceListViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private var deviceList = DeviceUtility.sharedInstance.getVisibleDeviceList()

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

        //TableView初始化配置
        tableView.register(DeviceDynamicCell.self, forCellReuseIdentifier: DeviceCellType.dynamic.rawValue)
        tableView.register(DeviceFixedCell.self, forCellReuseIdentifier: DeviceCellType.fixed.rawValue)
//        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.edgesToSuperview()

    }

    //MARK:可通讯设备更新状态位数据
    private func updateDeviceStatus() {
        var statusTagList = [Tag]()
        deviceList.filter { $0.level == .dynamic }.forEach { device in
            //e.g.:CY_A2_2
            let deviceName = device.getShortID()
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
        return deviceList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let config = deviceList[indexPath.row].getCellType().getRowHeight()
        return max(config.ratio * tableView.frame.height, config.min)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = deviceList[indexPath.row]
        //不重用cell，避免折叠等显示混乱
//        let cell = tableView.dequeueReusableCell(withIdentifier: device.getCellType().rawValue)!
        //自定义的cell使用level不能自动缩进，必须手动修改约束或分割线
        if device.level == .dynamic {
            let cell = DeviceDynamicCell()
            cell.deviceName = device.getShortID()
            cell.indentationLevel = device.getIndentationLevel()
            return cell
        } else {
            let cell = DeviceFixedCell()
            cell.indentationLevel = device.getIndentationLevel()
            cell.device = device
            cell.foldButton.rx.tap.bind(onNext: {
                device.collapsed = !device.collapsed
                self.deviceList = DeviceUtility.sharedInstance.getVisibleDeviceList()
                tableView.reloadData()
            }).disposed(by: disposeBag)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let device = deviceList[indexPath.row]
        if device.level == .dynamic {
            let deviceViewController = DeviceViewController()
            deviceViewController.deviceName = device.getShortID()
            navigationController?.pushViewController(deviceViewController, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //设置Footer将移除tableview底部空白cell的separator line
        return UIView()
    }
}
