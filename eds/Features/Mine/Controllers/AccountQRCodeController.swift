//
//  AccountQRCodeController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/4.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class AccountQRCodeController: UIViewController {

    let imageView = UIImageView()
    let helpLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        view.backgroundColor = .systemBackground
        title = "accountQRCode".localize()
        imageView.image = UIImage(systemName: "qrcode")
        imageView.tintColor = .systemGray
        view.addSubview(imageView)
        imageView.centerInSuperview()
        imageView.width(edsLargeImageSize)
        imageView.height(edsLargeImageSize)

        helpLabel.textColor = .systemGray
        helpLabel.textAlignment = .center
        helpLabel.numberOfLines = 0
        view.addSubview(helpLabel)
        helpLabel.topToBottom(of: imageView, offset: edsSpace)
        helpLabel.horizontalToSuperview(insets: .horizontal(edsSpace))

        generateQRCode()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(generateQRCode))
    }

    @objc func generateQRCode() {
        guard let phone = AccountUtility.sharedInstance.loginedPhone, phone.level.rawValue <= UserLevel.phoneObserver.rawValue else {
            return
        }
        let validTime = Date().add(by: .minute, value: 5)
        helpLabel.text = String(format: "QRCodeHelp".localize(), validTime.toDateTimeString())
        imageView.image = QRCodeUtility.generate(with: .login, param: validTime.toIDString().toBase64())
        imageView.tintColor = edsDefaultColor
    }

}
