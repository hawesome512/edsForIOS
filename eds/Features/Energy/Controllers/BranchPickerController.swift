//
//  BranchPickerController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/23.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol BranchPickerDelegate {
    func pick(branchDevice: Device, in parent: EnergyBranch?)
}

class BranchPickerController: BottomController {

    let branchPicker = UIPickerView()
    var devices: [Device] = []
    let disposeBag = DisposeBag()
    var delegate: BranchPickerDelegate?
    var parentBranch: EnergyBranch?

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        let deviceNames = TagUtility.sharedInstance.getEnergyDeviceList()
        devices = DeviceUtility.sharedInstance.getRalatedDevices(deviceNames: deviceNames)
        branchPicker.delegate = self
        branchPicker.dataSource = self
        contentView.addSubview(branchPicker)
        branchPicker.edgesToSuperview(excluding: .top)
        branchPicker.topToBottom(of: dismissButton)

        let confirmButton = UIButton()
        confirmButton.rx.tap.bind(onNext: {
            let selectedIndex = self.branchPicker.selectedRow(inComponent: 0)
            self.delegate?.pick(branchDevice: self.devices[selectedIndex], in: self.parentBranch)
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        confirmButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        contentView.addSubview(confirmButton)
        confirmButton.trailingToSuperview(offset: edsSpace)
        confirmButton.centerY(to: branchPicker)
        confirmButton.height(edsIconSize)
        confirmButton.width(edsIconSize)
    }
}

extension BranchPickerController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        devices.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return devices[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return edsHeight
    }
}
