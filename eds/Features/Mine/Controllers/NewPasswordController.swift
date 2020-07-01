//
//  NewPasswordController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/6/23.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  修改密码弹出框

import UIKit
import RxSwift

class NewPasswordController: UIAlertController, UITextFieldDelegate {
    
    private let leastCount = 6
    private let disposeBag = DisposeBag()
    private let titleLabel = UILabel()
    private let newField = UITextField()
    private let confirmField = UITextField()
    private let alertLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initViews()
    }
    
    private func initViews(){
        title = "\n\n\n\n\n\n\n"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textAlignment = .center
        titleLabel.text = "changePassword".localize()
        view.addSubview(titleLabel)
        titleLabel.edgesToSuperview(excluding: .bottom, insets: .uniform(edsSpace))

        //AlertController整个背景有透明度0.7
        newField.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.7)
        newField.font = UIFont.preferredFont(forTextStyle: .body)
        newField.placeholder = "newPassword".localize()
        newField.becomeFirstResponder()
        newField.returnKeyType = .next
        newField.isSecureTextEntry = true
        newField.tag = 0
        newField.delegate = self
        view.addSubview(newField)
        newField.height(edsIconSize)
        newField.horizontalToSuperview(insets: .horizontal(edsSpace))
        newField.topToBottom(of: titleLabel, offset: edsSpace)
    
        let countString = String(format: "passwordCount".localize(), leastCount)
        
        confirmField.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.7)
        confirmField.font = UIFont.preferredFont(forTextStyle: .body)
        confirmField.placeholder = "confirmPassword".localize()
        confirmField.returnKeyType = .done
        confirmField.isSecureTextEntry = true
        confirmField.tag = 1
        confirmField.delegate = self
        confirmField.rx.value.bind(onNext: { value in
            guard let first = self.newField.text, first.count >= self.leastCount, let second = value else { return }
            let confirmed = first == second
            self.alertLabel.alpha = confirmed ? 0 : 1
            self.alertLabel.textColor = confirmed ? .secondaryLabel : .systemRed
            self.alertLabel.text = confirmed ? countString : "invalidConfirmPassword".localize()
            self.actions.last?.isEnabled = confirmed
        }).disposed(by: disposeBag)
        view.addSubview(confirmField)
        confirmField.height(edsIconSize)
        confirmField.horizontalToSuperview(insets: .horizontal(edsSpace))
        confirmField.topToBottom(of: newField, offset: edsSpace)
        
        alertLabel.text = countString
        alertLabel.adjustsFontSizeToFitWidth = true
        alertLabel.textColor = .secondaryLabel
        view.addSubview(alertLabel)
        alertLabel.horizontalToSuperview(insets: .horizontal(edsSpace))
        alertLabel.topToBottom(of: confirmField,offset: edsSpace)
        
        actions.last?.isEnabled = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 0 {
            confirmField.becomeFirstResponder()
        }
        return true
    }
    
    static func present(in controller: UIViewController?) {
        guard let parentVC = controller else { return }
        let psVC = NewPasswordController(title: nil, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "confirm".localize(), style: .default, handler: { _ in
            guard let first = psVC.newField.text,
                first.count >= psVC.leastCount,
                let second = psVC.confirmField.text,
                first == second else {
                    return
            }
            AccountUtility.sharedInstance.changePassword(with: first, in: parentVC)
        })
        psVC.addAction(cancel)
        psVC.addAction(confirm)
        parentVC.present(psVC, animated: true, completion: nil)
    }

}
