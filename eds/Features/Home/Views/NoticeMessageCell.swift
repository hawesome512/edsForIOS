//
//  NoticeMessageCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/24.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class NoticeMessageCell: UITableViewCell {

    let messageLabel = UILabel()
    let clearButton = UIButton()
    var parentVC: UIViewController?
    private let disposeBag = DisposeBag()
    private var notice: Notice?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
        BasicUtility.sharedInstance.successfulBasicInfoUpdated
            .throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {result in
            self.initData()
        }).disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initData() {
        let noticeText = BasicUtility.sharedInstance.getBasic()?.notice
        notice = Notice.getNotice(with: noticeText ?? "")
        if notice == nil {
            messageLabel.text = "notice_none".localize(with: prefixHome)
            clearButton.alpha = 0
            return
        }
        messageLabel.text = notice!.message
        messageLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        clearButton.alpha = AccountUtility.sharedInstance.isOperable() ? 1 : 0
    }
    
    private func initViews() {

        clearButton.tintColor = .systemGray
        clearButton.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        clearButton.rx.tap.bind(onNext: {
            let deleteVC = ControllerUtility.generateDeletionAlertController(with: "notice_title".localize(with: prefixHome))
            let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive, handler: { _ in
                BasicUtility.sharedInstance.updateNotice(NIL)
                ActionUtility.sharedInstance.addAction(.deleteNotice)
//                self.parentVC?.navigationController?.popViewController(animated: true)
            })
            deleteVC.addAction(deleteAction)
            self.parentVC?.present(deleteVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        addSubview(clearButton)
        clearButton.width(edsSpace)
        clearButton.height(edsSpace)
        clearButton.topToSuperview(offset: edsMinSpace)
        clearButton.trailingToSuperview(offset: edsMinSpace)

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        addSubview(messageLabel)
        messageLabel.horizontalToSuperview(insets: .horizontal(edsSpace))
        messageLabel.topToBottom(of: clearButton, offset: edsMinSpace)
        messageLabel.bottomToSuperview(offset: -edsSpace)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
