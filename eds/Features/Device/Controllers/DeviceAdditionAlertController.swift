//
//  DeviceAdditionController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/2/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  增加设备弹出框

import UIKit

class DeviceAdditionAlertController: UIAlertController, UITextFieldDelegate {

    let titleLable = UILabel()
    let nameField = LooseTextField()
    let devicePicker = UIPickerView()

    //新增设备（.fixed,.dynamic)时，可选设备列表：非通信型+通信型设备列表
    lazy var deviceList: [String] = {
        var devices = ["uncommunicate".localize()]
        devices.append(contentsOf: TagUtility.sharedInstance.getDeviceList())
        return devices
    }()

    var parentDevice: Device?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //AlertController不能依据view尺寸调整大小，根据经验设置title换行，匹配足够的高度空间。
        //新增pickerView时，controller会自动调整其尺寸以适应pickerView
        title = "\n\n\n"
//        titleLable.text = "请输入配电房名称"
        titleLable.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLable.textAlignment = .center
        view.addSubview(titleLable)
        titleLable.edgesToSuperview(excluding: .bottom, insets: .uniform(edsSpace))

        //AlertController整个背景有透明度0.7
        nameField.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.7)
        nameField.font = UIFont.preferredFont(forTextStyle: .body)
        nameField.becomeFirstResponder()
        nameField.returnKeyType = .done
        nameField.delegate = self
        view.addSubview(nameField)
        nameField.horizontalToSuperview(insets: .horizontal(edsSpace))
        nameField.topToBottom(of: titleLable, offset: edsSpace)

        devicePicker.selectRow(0, inComponent: 0, animated: false)
        if parentDevice?.level == DeviceLevel.box {
            devicePicker.dataSource = self
            devicePicker.delegate = self
            view.addSubview(devicePicker)
            //使用约束的方式设定的w和h有偏差，固定尺寸（200*100）
            devicePicker.width(200)
            devicePicker.height(100)
            devicePicker.centerXToSuperview()
            devicePicker.topToBottom(of: nameField)
            //uiaction(ok/cancel)等控件height=44
            devicePicker.bottomToSuperview(offset: -edsHeight)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.center = view.center.offset(x: 0, y: -60)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    func getAddedDeviceId() -> String {
        //level=room/box/fixed时，row=0
        let selectedRow = devicePicker.selectedRow(inComponent: 0)
        return selectedRow == 0 ? String.randomString(length: 5) : deviceList[selectedRow]
    }

    func getAddedDeviceLevel() -> DeviceLevel {
        if let parent = parentDevice {
            if parent.level == .room {
                return .box
            } else {
                //level=room/box/fixed时，row=0
                let selectedRow = devicePicker.selectedRow(inComponent: 0)
                return selectedRow == 0 ? DeviceLevel.fixed : DeviceLevel.dynamic
            }
        } else {
            return .room
        }
    }

    static func initController(device: Device?) -> DeviceAdditionAlertController {
        let controller = DeviceAdditionAlertController(title: nil, message: nil, preferredStyle: .alert)
        var title: String?
        if let device = device {
            controller.parentDevice = device
            //新增时，device不可能为fixed/dynamic
            title = ((device.level == .room) ? "box_addition" : "property_addition").localize()
        } else {
            //device为nil,新增配电房
            title = "room_addition".localize()
        }
        controller.titleLable.text = title

        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        controller.addAction(cancelAction)

        return controller
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DeviceAdditionAlertController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return deviceList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return deviceList[row]
    }
}
