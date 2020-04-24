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
    private let disposeBag = DisposeBag()
    private var notice: Notice?
    var noticeText: String? {
        didSet {
            notice = Notice.getNotice(with: self.noticeText ?? "")
            if notice == nil {
                messageLabel.text = "notice_none".localize(with: prefixHome)
                clearButton.alpha = 0
                return
            }
            messageLabel.text = notice!.message
            messageLabel.textColor = .darkText
            messageLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            clearButton.alpha = 1
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        clearButton.tintColor = .systemGray
        clearButton.setBackgroundImage(UIImage(systemName: "xmark"), for: .normal)
        clearButton.rx.tap.bind(onNext: {

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
