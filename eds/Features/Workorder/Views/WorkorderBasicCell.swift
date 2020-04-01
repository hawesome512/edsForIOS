//
//  WorkorderBasicCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import CallKit
import MessageUI

protocol DistributionDelegate {
    func distributed()
}

class WorkorderBasicCell: UITableViewCell {

    private let workerIcon = UIImageView()
    private let workerLabel = UILabel()
    private let workerButton = UIButton()
    private let timeIcon = UIImageView()
    private let timeLabel = UILabel()
    private let deviceIcon = UIImageView()
    private let deviceLabel = UILabel()

    //电话派发工单，监听电话接通状态
    private let callObserver = CXCallObserver()

    private let disposeBag = DisposeBag()

    var delegate: DistributionDelegate?
    var viewController: UIViewController?
    var workorder: Workorder? {
        didSet {
            workerLabel.text = workorder?.worker
            deviceLabel.text = workorder?.location
            timeLabel.text = workorder?.getTimeRange()
        }
    }


    private func initViews() {

        callObserver.setDelegate(self, queue: DispatchQueue.main)

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
        let shareVC = ShareController()
        shareVC.titleLabel.text = WorkorderState.distributed.getText()
        shareVC.delegate = self
        window?.rootViewController?.present(shareVC, animated: true, completion: nil)
    }

}

extension WorkorderBasicCell: ShareDelegate, CXCallObserverDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

    func share(with shareType: ShareType) {
        guard let workorder = workorder, let executor = AccountUtility.sharedInstance.getPhone(by: workorder.worker) else {
            return
        }
        let sentContent = String(format: "distribution".localize(with: prefixWorkorder), executor.name!, workorder.title, workorder.getShortTimeRange(), workorder.location, workorder.id)
        switch shareType {
        case .phone:
            ShareUtility.callPhone(to: executor.number!)
        case .sms:
            ShareUtility.sendSMS(to: executor.number!, with: sentContent, imageData: nil, delegate: self, in: viewController)
        case .mail:
            let imageData = QRCodeUtility.generate(with: .workorder, param: workorder.id)?.pngData()
            ShareUtility.sendMail(to: executor.email!, title: "distribution_title".localize(with: prefixWorkorder), content: sentContent, imageData: imageData, delegate: self, in: viewController)
        default:
            break
        }
    }

    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        //已经接通电话，已经结束通话，电话派发工单成功
        if call.hasConnected && call.hasEnded {
            delegate?.distributed()
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //发送短信成功
        if result == .sent {
            delegate?.distributed()
        }
        controller.dismiss(animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //发送邮件成功
        if result == .sent {
            delegate?.distributed()
        }
        controller.dismiss(animated: true, completion: nil)
    }

}
