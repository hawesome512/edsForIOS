//
//  InfoAlertController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/2.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class InfoAlertController: UIAlertController, UITextFieldDelegate {

    private let titleLable = UILabel()
    private let nameField = LooseTextField()
    private let valueField = LooseTextField()
    private let unitField = LooseTextField()

    var deviceInfo: DeviceInfo? {
        didSet {
            if let deviceInfo = deviceInfo {
                let nameAndUnit = deviceInfo.title.separateNameAndUnit()
                nameField.text = nameAndUnit.name
                valueField.text = deviceInfo.value
                unitField.text = nameAndUnit.unit
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        //AlertController不能依据view尺寸调整大小，根据经验设置title换行，匹配足够的高度空间。
        //新增pickerView时，controller会自动调整其尺寸以适应pickerView
        title = "\n\n\n\n\n\n\n\n"
        titleLable.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLable.textAlignment = .center
        titleLable.text = "info".localize()
        view.addSubview(titleLable)
        titleLable.edgesToSuperview(excluding: .bottom, insets: .uniform(edsSpace))

        //AlertController整个背景有透明度0.7
        nameField.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.7)
        nameField.font = UIFont.preferredFont(forTextStyle: .body)
        nameField.placeholder = "title".localize()
        nameField.becomeFirstResponder()
        nameField.returnKeyType = .next
        nameField.delegate = self
        nameField.tag = 0
        nameField.clearButtonMode = .whileEditing
        view.addSubview(nameField)
        nameField.horizontalToSuperview(insets: .horizontal(edsSpace))
        nameField.topToBottom(of: titleLable, offset: edsSpace)

        valueField.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.7)
        valueField.font = UIFont.preferredFont(forTextStyle: .body)
        valueField.placeholder = "value".localize()
        valueField.returnKeyType = .next
        valueField.delegate = self
        valueField.tag = 1
        valueField.clearButtonMode = .whileEditing
        view.addSubview(valueField)
        valueField.horizontalToSuperview(insets: .horizontal(edsSpace))
        valueField.topToBottom(of: nameField, offset: edsSpace)

        unitField.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.7)
        unitField.font = UIFont.preferredFont(forTextStyle: .body)
        unitField.placeholder = "unit".localize()
        unitField.returnKeyType = .done
        unitField.delegate = self
        valueField.clearButtonMode = .whileEditing
        unitField.tag = 2
        view.addSubview(unitField)
        unitField.horizontalToSuperview(insets: .horizontal(edsSpace))
        unitField.topToBottom(of: valueField, offset: edsSpace)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.center = view.center.offset(x: 0, y: -60)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let newTag = textField.tag + 1
        if let nextField = view.viewWithTag(newTag) as? UITextField {
            nextField.becomeFirstResponder()
        }
        return textField.resignFirstResponder()
    }

    func getDeviceInfo() -> DeviceInfo? {
        //输入有效时才处理
        if let name = nameField.text, !name.isEmpty, let value = valueField.text, !value.isEmpty {
            var info = name
            if let unit = unitField.text, !unit.isEmpty {
                info.append(contentsOf: "(\(unit))")
            }
            //新建or编辑现有
            if var deviceInfo = deviceInfo {
                deviceInfo.title = info
                deviceInfo.value = value
                return deviceInfo
            } else {
                info.append(contentsOf: DeviceInfo.infoSeparator + value)
                return DeviceInfo.initInfo(with: info)
            }
        }
        return nil
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
