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
    private var deviceList = DeviceUtility.sharedInstance.getProjDeviceList()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 1
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
            navigationController?.pushViewController(dynamicVC, animated: true)
        } else {
            let fixedVC = FixedDeviceViewController()
            fixedVC.device = device
            navigationController?.pushViewController(fixedVC, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //设置Footer将移除tableview底部空白cell的separator line
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AdditionTableHeaderView()
        headerView.title.text = "add_room".localize(with: prefixDevice)
        headerView.delegate = self
        return headerView
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
                    print(parent.toJSONString()!)
                    modifiedDevices.append(parent)
                }
                modifiedDevices.forEach({ device in
                    MoyaProvider<EDSService>().request(.updateDevice(device: device)) { _ in }
                })

                self.deviceList = DeviceUtility.sharedInstance.getProjDeviceList()
                tableView.reloadData()
                print("modify \(modifiedDevices.count) devices.")
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension DeviceListViewController: AdditionDelegate {

    func add(inParent: Device?) {
        //自定义【新增】弹出框
        let alertController = DeviceAdditionAlertController.initController(device: inParent)
        //因需要处理ok之后到逻辑，故不在DeviceAdditionAlertController里面添加OKAction
        let okAction = UIAlertAction(title: "ok".localize(), style: .default) { _ in
            if let proj = User.tempInstance.projectID, let title = alertController.nameField.text {
                //新建Device
                let id = "\(proj)-\(alertController.getAddedDeviceId())"
                let newDevice = Device(deviceID: id)
                newDevice.account = proj
                newDevice.title = title
                newDevice.level = alertController.getAddedDeviceLevel()
                MoyaProvider<EDSService>().request(.updateDevice(device: newDevice)) { response in
                    switch response {
                    case .success(_):
                        //成功新增后，更新资产列表
                        DeviceUtility.sharedInstance.deviceList.append(newDevice)
                        self.deviceList = DeviceUtility.sharedInstance.getProjDeviceList()
                        self.tableView.reloadData()
                    default:
                        break
                    }
                }
                //更新新增Device的父级支路
                if let parent = inParent {
                    parent.addBranch(with: newDevice.getShortID())
                    MoyaProvider<EDSService>().request(.updateDevice(device: parent)) { _ in }
                }
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
