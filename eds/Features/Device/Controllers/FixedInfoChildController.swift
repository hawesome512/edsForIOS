//
//  FixedTableView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/2/28.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  此Controller用于显示Device静态Info,不会单独显示，存在于FixedDeviceViewController和DynamicDeviceViewController中
//  设备资料列表

import Foundation
import UIKit
import Moya
import RxSwift

class FixedInfoChildController: UITableViewController {

    private let countLimit = 10
    private var sortingInfo = false
    private let disposeBag = DisposeBag()
    private let sortButton = UIButton()
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
            cell.valueLabel.alpha = sortingInfo ? 0 : 1
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
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < deviceInfos.count else { return }
        guard AccountUtility.sharedInstance.isOperable() else { return }

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
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard AccountUtility.sharedInstance.isOperable() else {
            return nil
        }
        let headerView = AdditionTableHeaderView()
        sortButton.setTitle("sort_info".localize(), for: .normal)
        sortButton.setTitleColor(edsDefaultColor, for: .normal)
        sortButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {
            self.sortInfo()
        }).disposed(by: disposeBag)
        headerView.addSubview(sortButton)
        sortButton.trailingToSuperview(offset:edsSpace)
        sortButton.verticalToSuperview(insets:.vertical(edsSpace))
        headerView.title.text = "add_info".localize()
        headerView.delegate = self
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard AccountUtility.sharedInstance.isOperable() else {
            return 0
        }
        return tableView.estimatedRowHeight
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    private func showInfoController(deviceInfo: DeviceInfo?, didSelectRowAt indexPath: IndexPath?) {
        let infoAlertController = InfoAlertController(title: nil, message: nil, preferredStyle: .alert)
        infoAlertController.deviceInfo = deviceInfo
        let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "ok".localize(), style: .default) { _ in
            guard let newInfo = infoAlertController.getDeviceInfo() else { return }
            if let row = indexPath?.row {
                self.deviceInfos[row] = newInfo
            } else {
                self.deviceInfos.append(newInfo)
            }
            self.update()
            self.tableView.reloadData()
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
        guard let device = device else { return }
        device.setInfos(infos: deviceInfos)
        DeviceUtility.sharedInstance.update(device)
    }
    
    /// 重新排序
    private func sortInfo(){
        if sortingInfo {
            update()
        } else {
            ControllerUtility.presentAlertController(content: "save_alert".localize(with: prefixWorkorder), controller: self)
        }
        sortingInfo = !sortingInfo
        tableView.setEditing(sortingInfo, animated: true)
        let title = sortingInfo ? "save".localize() : "sort_info".localize()
        sortButton.setTitle(title, for: .normal)
        sortButton.loadedWithAnimation()
        //排序状态下cell右边存在排序按钮，此时设置valueLabel.alpha = 0(隐藏）
        let indexPaths = (0..<deviceInfos.count).map{IndexPath(row: $0, section: 0)}
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < deviceInfos.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < deviceInfos.count
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard sourceIndexPath.row < deviceInfos.count, proposedDestinationIndexPath.row < deviceInfos.count else {
            return sourceIndexPath
        }
        let info = deviceInfos[sourceIndexPath.row]
        deviceInfos.remove(at: sourceIndexPath.row)
        deviceInfos.insert(info, at: proposedDestinationIndexPath.row)
        return proposedDestinationIndexPath
    }
}

extension FixedInfoChildController: AdditionDelegate {
    func add(inParent parent: Device?) {
        if deviceInfos.count >= countLimit {
            let content = String(format: "info_limit".localize(), countLimit)
            ControllerUtility.presentAlertController(content: content, controller: self)
            return
        }
        showInfoController(deviceInfo: nil, didSelectRowAt: nil)
    }
}
