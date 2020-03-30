//
//  TextInputCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/26.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  三种模式：
//      1⃣️dates.count>0,选择日期，弹出日期选择框，处理数据回调协议
//      2⃣️items.count>0,选择文本，下拉选择框，还可以设置单选or多选：multiSelected
//      3⃣️dates和items.count=0,输入文本，调出键盘

import UIKit
import RxSwift
import DropDown
import TextFieldEffects

protocol TextInputCellDelegate {
    func itemSelected(item: String)
}

class TextInputCell: UITableViewCell, UITextFieldDelegate {

    var title: String? {
        didSet {
            textField.placeholder = title
        }
    }

    //选择文本
    private let separator = ";"
    var items: [String] = [] {
        didSet {
            dropDown.dataSource = items
        }
    }
    var multiSelected: Bool = false {
        didSet {
            if multiSelected {
                dropDown.multiSelectionAction = { [unowned self] (indexs: [Int], items: [String]) in
                    //资产列表为例层级显示增加了空格，在此处删除空白
                    let text = items.map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: self.separator)
                    self.textField.text = text.isEmpty ? nil : text
                    self.textField.resignFirstResponder()
                    self.delegate?.itemSelected(item: text)
                }
            }
        }
    }
    var delegate: TextInputCellDelegate?


    //选择日期
    var dates: [String] = []
    var datePickerDelegate: PickerDelegate?

    let textField = HoshiTextField()
    private let disposeBag = DisposeBag()
    let dropDown = DropDown()
    private let textFont = UIFont.boldSystemFont(ofSize: 20)

    private func initViews() {

        textField.placeholderColor = .systemGray
        textField.placeholderFontScale = 1
        textField.borderActiveColor = edsDefaultColor
        textField.borderInactiveColor = .systemGray
        textField.borderStyle = .bezel
        textField.font = textFont
        textField.delegate = self
        addSubview(textField)
        textField.horizontalToSuperview(insets: .horizontal(edsSpace))
        textField.verticalToSuperview(insets: .vertical(edsMinSpace))
        textField.clearButtonMode = .unlessEditing
        textField.returnKeyType = .done

        let appearance = DropDown.appearance()
        appearance.selectionBackgroundColor = edsDefaultColor.withAlphaComponent(0.3)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textFont = textFont
        dropDown.anchorView = textField
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.textField.text = item
            self.textField.resignFirstResponder()
            self.delegate?.itemSelected(item: item)
        }

        textField.rx.controlEvent(.editingDidBegin).asObservable().bind(onNext: {

            if self.dropDown.dataSource.count > 0 {
                //文本下拉框
                self.dropDown.show()
                self.textField.resignFirstResponder()
            } else if self.dates.count > 0 {
                //时间选择
                self.textField.resignFirstResponder()
                let pickerVC = DatePickerController()
                pickerVC.items = self.dates
                pickerVC.delegate = self.datePickerDelegate
                self.window?.rootViewController?.present(pickerVC, animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func getValue() -> String? {
        return textField.text
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
