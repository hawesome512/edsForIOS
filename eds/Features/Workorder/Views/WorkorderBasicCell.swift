//
//  WorkorderBasicCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class WorkorderBasicCell: UITableViewCell {

    private let workerIcon = UIImageView()
    private let workerLabel = UILabel()
    private let workerButton = UIButton()
    private let timeIcon = UIImageView()
    private let timeLabel = UILabel()
    private let deviceIcon = UIImageView()
    private let deviceLabel = UILabel()

    private let disposeBag = DisposeBag()

    var workorder: Workorder? {
        didSet {
            workerLabel.text = workorder?.worker
            deviceLabel.text = workorder?.location
            timeLabel.text = workorder?.getTimeRange()
        }
    }


    private func initViews() {

        tintColor = .darkGray

        workerIcon.image = UIImage(systemName: "person")
        addSubview(workerIcon)
        workerIcon.width(edsIconSize)
        workerIcon.height(edsIconSize)
        workerIcon.leadingToSuperview(offset: edsSpace)
        workerIcon.topToSuperview(offset: edsMinSpace)

        workerButton.tintColor = .systemBlue
        workerButton.setBackgroundImage(UIImage(systemName: "tray.and.arrow.up"), for: .normal)
        addSubview(workerButton)
        workerButton.width(edsIconSize)
        workerButton.height(edsIconSize)
        workerButton.centerY(to: workerIcon)
        workerButton.trailingToSuperview(offset: edsSpace)
        workerButton.rx.tap.bind(onNext: {
            self.distribute()
        }).disposed(by: disposeBag)

        addSubview(workerLabel)
        workerLabel.centerY(to: workerIcon)
        workerLabel.leadingToTrailing(of: workerIcon, offset: edsMinSpace)
        workerLabel.trailingToLeading(of: workerButton, offset: edsSpace)

        deviceIcon.image = Device.icon
        addSubview(deviceIcon)
        deviceIcon.width(edsIconSize)
        deviceIcon.height(edsIconSize)
        deviceIcon.topToBottom(of: workerIcon, offset: edsMinSpace)
        deviceIcon.leading(to: workerIcon)

        deviceLabel.numberOfLines = 0
        addSubview(deviceLabel)
        deviceLabel.centerY(to: deviceIcon)
        deviceLabel.leadingToTrailing(of: deviceIcon, offset: edsMinSpace)
        deviceLabel.trailingToSuperview(offset: edsSpace)

        timeIcon.image = UIImage(systemName: "calendar")
        addSubview(timeIcon)
        timeIcon.width(edsIconSize)
        timeIcon.height(edsIconSize)
        timeIcon.topToBottom(of: deviceIcon, offset: edsMinSpace)
        timeIcon.leading(to: deviceIcon)
        timeIcon.bottomToSuperview(offset: -edsMinSpace)

        addSubview(timeLabel)
        timeLabel.leadingToTrailing(of: timeIcon, offset: edsMinSpace)
        timeLabel.centerY(to: timeIcon)
        timeLabel.trailingToSuperview(offset: edsSpace)
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

    private func distribute() {
        let controller = UIAlertController(title: WorkorderState.distributed.getText(), message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        let phone = UIAlertAction(title: "telephone".localize(), style: .default, handler: nil)
        let sms = UIAlertAction(title: "sms".localize(), style: .default, handler: nil)
        let mail = UIAlertAction(title: "mail".localize(), style: .default, handler: nil)
        let wechat = UIAlertAction(title: "wechat".localize(), style: .default, handler: nil)
        controller.addAction(cancel)
        controller.addAction(phone)
        controller.addAction(sms)
        controller.addAction(wechat)
        controller.addAction(mail)
        if let ppc = controller.popoverPresentationController {
            ppc.sourceView = self
            ppc.sourceRect = self.bounds
        }
        window?.rootViewController?.present(controller, animated: true, completion: nil)
    }

}
