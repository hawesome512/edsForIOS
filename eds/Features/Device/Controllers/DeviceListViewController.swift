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
    private var deviceList = [Device]()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    fileprivate func initViews() {
        //再更新一次动态设备状态点
        updateDeviceStatus()
        //设定导航栏
        title = "property".localize()
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

    override func viewWillAppear(_ animated: Bool) {
        deviceList = DeviceUtility.sharedInstance.getProjDeviceList()
        tableView.reloadData()
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
        return deviceList[indexPath.row].getCellType().getRowHeight(in: tableView)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let device = deviceList[indexPath.row]
        //不重用cell，避免折叠等显示混乱
//        let cell = tableView.dequeueReusableCell(withIdentifier: device.getCellType().rawValue)!
        //自定义的cell使用level不能自动缩进，必须手动修改约束或分割线
        if device.level == .dynamic {
            let cell = DeviceDynamicCell()
            cell.device = device
            cell.indentationLevel = device.getIndentationLevel()
            return cell
        } else {
            let cell = DeviceFixedCell()
            cell.delegate = self
            cell.indentationLevel = device.getIndentationLevel()
            cell.device = device
            cell.foldButton.rx.tap.bind(onNext: {
                device.collapsed = !device.collapsed
                self.deviceList = DeviceUtility.sharedInstance.getProjDeviceList()
                tableView.reloadData()
            }).disposed(by: disposeBag)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let device = deviceList[indexPath.row]
        if device.level == .dynamic {
            let dynamicVC = DynamicDeviceViewController()
            dynamicVC.device = device
            dynamicVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(dynamicVC, animated: true)
        } else {
            let fixedVC = FixedDeviceViewController()
            fixedVC.device = device
            fixedVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(fixedVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //设置Footer将移除tableview底部空白cell的separator line
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard AccountUtility.sharedInstance.isOperable() else {
            return nil
        }
        let headerView = AdditionTableHeaderView()
        headerView.title.text = "add_room".localize()
        headerView.delegate = self
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard AccountUtility.sharedInstance.isOperable() else {
            return 0
        }
        return tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { guard AccountUtility.sharedInstance.isOperable() else {
            return
        }
        //删除设备：弹出框确认▶️删除设备及所属设备▶️更新父级支路
        if editingStyle == .delete {
            let deleteDevice = deviceList[indexPath.row]
            let alertController = ControllerUtility.generateDeletionAlertController(with: deleteDevice.title)
            let okAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
                var modifiedDevices = [deleteDevice]
                modifiedDevices.append(contentsOf: DeviceUtility.sharedInstance.getBranceList(device: deleteDevice, visiableOnly: false))
                modifiedDevices = modifiedDevices.map { device in
                    device.prepareForDelete()
                    return device
                }
                DeviceUtility.sharedInstance.remove(devices: modifiedDevices)
                //需要修改父级支路信息
                if let parent = DeviceUtility.sharedInstance.getParent(of: deleteDevice) {
                    parent.removeBranch(with: deleteDevice.getShortID())
                    modifiedDevices.append(parent)
                }
                modifiedDevices.forEach({ device in
                    EDSService.getProvider().request(.updateDevice(device: device)) { _ in }
                })

                self.deviceList = DeviceUtility.sharedInstance.getProjDeviceList()
                tableView.reloadData()
                print("modify \(modifiedDevices.count) devices.")
                ActionUtility.sharedInstance.addAction(.deleteDevice, extra: deleteDevice.title)
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension DeviceListViewController: AdditionDelegate {

    func add(inParent: Device?) {
        
        let deviceLimit = AccountUtility.sharedInstance.account?.device ?? 0
        //不使用self.deviceList,因折叠的设备不代表所有的数量
        if DeviceUtility.sharedInstance.getDeviceList().count >= deviceLimit {
            let content = String(format: "device_limit".localize(), deviceLimit) 
            ControllerUtility.presentAlertController(content: content, controller: self)
            return
        }
        
        //自定义【新增】弹出框
        let alertController = DeviceAdditionAlertController.initController(device: inParent)
        //因需要处理ok之后到逻辑，故不在DeviceAdditionAlertController里面添加OKAction
        let okAction = UIAlertAction(title: "ok".localize(), style: .default) { _ in
            if let projID = AccountUtility.sharedInstance.account?.id, let title = alertController.nameField.text {
                //新建Device
                let id = "\(projID)-\(alertController.getAddedDeviceId())"
                let newDevice = Device(deviceID: id)
                newDevice.account = projID
                newDevice.title = title
                newDevice.level = alertController.getAddedDeviceLevel()
                EDSService.getProvider().request(.updateDevice(device: newDevice)) { response in
                    switch response {
                    case .success(_):
                        //成功新增后，更新资产列表
                        DeviceUtility.sharedInstance.appendDeviceList(newDevice)
                        self.deviceList = DeviceUtility.sharedInstance.getProjDeviceList()
                        self.tableView.reloadData()
                    default:
                        break
                    }
                }
                //更新新增Device的父级支路
                if let parent = inParent {
                    parent.addBranch(with: newDevice.getShortID())
                    EDSService.getProvider().request(.updateDevice(device: parent)) { _ in }
                }
                ActionUtility.sharedInstance.addAction(.addDevice, extra: title)
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
