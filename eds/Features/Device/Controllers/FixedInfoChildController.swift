//
//  FixedTableView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/2/28.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  此Controller用于显示Device静态Info,不会单独显示，存在于FixedDeviceViewController和DynamicDeviceViewController中

import Foundation
import UIKit
import Moya

class FixedInfoChildController: UITableViewController {
    //↕️滚动，设备头图伸缩
    var scrollDelegate: DevicePageScrollDelegate?

    var device: Device? {
        didSet {
            if let device = device {
                deviceInfos = device.getInfos()
            }
        }
    }
    var deviceInfos: [DeviceInfo] = []

    //因为FixedChild不是独立Controller，不建议直接present弹出框，获取父Controller
    var parentVC: UIViewController?

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Device Page Scroll Delegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //触发父级header view上下偏移
        scrollDelegate?.scrollViewDidScroll(tableView)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //➕二维码，跳转指令
        return deviceInfos.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case deviceInfos.count:
            let cell = DeviceCellType.goto.getTableCell(parentVC: parentVC) as! FixedGotoCell
            cell.device = device
            cell.parentVC = parentVC
            return cell
        case deviceInfos.count + 1:
            let cell = DeviceCellType.qrcode.getTableCell(parentVC: parentVC) as! FixedQRCodeCell
            cell.qrImageView.image = QRCodeUtility.generate(with: .device, param: device!.getShortID())
            return cell
        default:
            let cell = DeviceCellType.info.getTableCell(parentVC: parentVC) as! FixedInfoCell
            cell.nameLabel.attributedText = deviceInfos[indexPath.row].title.formatNameAndUnit()
            cell.valueLabel.text = deviceInfos[indexPath.row].value
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case deviceInfos.count:
            return DeviceCellType.goto.getRowHeight(in: tableView)
        case deviceInfos.count + 1:
            return DeviceCellType.qrcode.getRowHeight(in: tableView)
        default:
            return DeviceCellType.info.getRowHeight(in: tableView)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let menuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "edit".localize(), style: .default) { _ in
            self.showInfoController(deviceInfo: self.deviceInfos[indexPath.row], didSelectRowAt: indexPath)
        }
        let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
            self.showDeleteController(didSelectRowAt: indexPath)
        }
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        menuController.addAction(editAction)
        menuController.addAction(deleteAction)
        menuController.addAction(cancelAction)

        if let ppc = menuController.popoverPresentationController {
            let cell = tableView.cellForRow(at: indexPath)!
            ppc.sourceView = cell
            ppc.sourceRect = cell.bounds
        }

        parentVC?.navigationController?.present(menuController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AdditionTableHeaderView()
        headerView.title.text = "add_info".localize()
        headerView.delegate = self
        return headerView
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    private func showInfoController(deviceInfo: DeviceInfo?, didSelectRowAt indexPath: IndexPath?) {
        let infoAlertController = InfoAlertController(title: nil, message: nil, preferredStyle: .alert)
        infoAlertController.deviceInfo = deviceInfo
        let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "ok".localize(), style: .default) { _ in
            if let newInfo = infoAlertController.getDeviceInfo() {
                if let row = indexPath?.row {
                    self.deviceInfos[row] = newInfo
                } else {
                    self.deviceInfos.append(newInfo)
                }
                self.update()
                self.tableView.reloadData()
            }
        }
        infoAlertController.addAction(cancel)
        infoAlertController.addAction(ok)
        parentVC?.navigationController?.present(infoAlertController, animated: true, completion: nil)
    }

    private func showDeleteController(didSelectRowAt indexPath: IndexPath) {
        let deleteInfo = deviceInfos[indexPath.row]
        let name = deleteInfo.title.separateNameAndUnit().name
        let title = String(format: "delete_title".localize(), arguments: [name])
        let alertController = UIAlertController(title: title, message: "delete_info".localize(), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
            self.deviceInfos.remove(at: indexPath.row)
            self.update()
            self.tableView.reloadData()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        parentVC?.navigationController?.present(alertController, animated: true, completion: nil)
    }

    private func update() {
        if let device = device {
            device.setInfos(infos: deviceInfos)
            MoyaProvider<EDSService>().request(.updateDevice(device: device)) { _ in }
        }
    }
}

extension FixedInfoChildController: AdditionDelegate {
    func add(inParent parent: Device?) {
        showInfoController(deviceInfo: nil, didSelectRowAt: nil)
    }
}
