//
//  LoginController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/14.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import Moya
import SwiftDate

class LoginController: UIViewController {

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {

        let projField = UITextField()
        let numberField = UITextField()

        let button = UIButton()
        button.setTitle("登录", for: .normal)
        button.backgroundColor = .systemBlue
        button.rx.tap.bind(onNext: {

            guard let projID = projField.text, let number = numberField.text else {
                return
            }
            AccountUtility.sharedInstance.loadProjectAccount(accountID: projID, phoneNumber: number)
            AccountUtility.sharedInstance.successfulLoaded.bind(onNext: { loaded in
                if loaded {
                    let mainVC = MainController()
                    mainVC.modalPresentationStyle = .fullScreen
                    self.present(mainVC, animated: true, completion: nil)
                }
            }).disposed(by: self.disposeBag)

        }).disposed(by: disposeBag)
        view.addSubview(button)
        button.centerInSuperview()
        button.height(60)
        button.widthToSuperview(multiplier: 0.8)

        projField.text = "2/XRD"
        projField.backgroundColor = .systemGray3
        view.addSubview(projField)
        projField.height(60)
        projField.bottomToTop(of: button, offset: -edsSpace)
        projField.width(to: button)
        projField.centerX(to: button)

        numberField.text = "18759282157"
        numberField.backgroundColor = .systemGray3
        view.addSubview(numberField)
        numberField.height(60)
        numberField.bottomToTop(of: projField, offset: -edsSpace)
        numberField.centerX(to: button)
        numberField.width(to: button)
    }
}
