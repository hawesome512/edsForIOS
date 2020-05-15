//
//  PasswordView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  密码输入框View，方案来源：Github/SPayPassWordView

import UIKit

@objc protocol PasswordViewDelegate: NSObjectProtocol {
    func entryComplete(password: String)

    @objc optional func inputting()
    @objc optional func entryFault()
}

@IBDesignable class PasswordView: UIView {

    @IBInspectable var lenght: Int = 4 {
        didSet {
//            updataUI()
        }
    }

    @IBInspectable var star: String = "●"

    @IBInspectable var starColor: UIColor = UIColor.systemBlue {
        didSet {
            squareArray.forEach { (label) in
                label.textColor = starColor
            }
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.systemGray {
        didSet {
            squareArray.forEach { (label) in
                label.layer.borderColor = borderColor.cgColor
            }
        }
    }

    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            squareArray.forEach { (label) in
                label.layer.borderWidth = borderWidth
                label.layer.masksToBounds = borderWidth > 0
            }

        }
    }

    @IBInspectable var borderRadius: CGFloat = 0 {
        didSet {
            squareArray.forEach { (label) in
                label.layer.cornerRadius = borderRadius
            }
        }
    }

    var side: CGFloat!

    var password: String = ""

    var squareArray = [UILabel]()

    var space: CGFloat!

    var textField: UITextField = UITextField()

    var validValue: String?

    var tempArrat = [String]()

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        updataUI()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        updataUI()
//    }

    weak var delegate: PasswordViewDelegate?

    func updataUI() {

        for view in self.subviews {
            view.removeFromSuperview()
        }

        side = self.frame.height
        space = (self.frame.width - (CGFloat(lenght) * side)) / CGFloat(lenght - 1)
        for index in 0..<lenght {
            let label = UILabel(frame: CGRect(x: (space + side) * CGFloat(index), y: 0, width: side, height: side))
            label.layer.masksToBounds = true
            label.textAlignment = .center
            label.layer.borderColor = UIColor.gray.cgColor
            label.layer.borderWidth = 1
            squareArray.append(label)
        }
        for square in squareArray {
            self.addSubview(square)
        }

        textField.keyboardType = .numberPad
        textField.delegate = self
        self.addSubview(textField)
    }

    func input() {
        textField.becomeFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.becomeFirstResponder()
    }

    deinit {
        self.delegate = nil
    }

    override func draw(_ rect: CGRect) {
        print(frame)
        updataUI()
    }
}

extension PasswordView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        password = ""
        squareArray.forEach { (label) in
            restore(label: label)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        /// 处理删除逻辑
        if string == "" {
            if password == "" { /// 密码已经为空
                return true
            } else if password.count == 1 {
                password = ""
            } else {
                password = String(password[..<password.index(password.endIndex, offsetBy: -1)])
            }
        } else {
            password += string
        }

        /// 填充密码框
        for index in 0..<squareArray.count {

            if index < password.count {
                squareArray[index].text = star
                squareArray[index].layer.borderColor = edsDefaultColor.cgColor
                squareArray[index].layer.borderWidth = borderWidth * 2
            } else {
                restore(label: squareArray[index])
            }

        }
        /// 完成输入
        if password.count >= lenght {
            textField.text = password
            if let validValue = validValue, validValue != password {
                self.delegate?.entryFault?()
                return false
            }
            textField.resignFirstResponder()
            self.delegate?.entryComplete(password: password)
            self.endEditing(true)
            return false
        }
        /// 正在输入
        self.delegate?.inputting?()

        return true
    }

    private func restore(label: UILabel) {
        label.text = ""
        label.layer.borderColor = borderColor.cgColor
        label.layer.borderWidth = borderWidth
    }
}
