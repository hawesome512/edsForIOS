//
//  ActionCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/4.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class ActionCell: UITableViewCell {

    let typeImage = UIImageView()
    let actionLabel = UILabel()
    let timeLabel = UILabel()

    var action: Action? {
        didSet {
            guard let action = self.action else {
                return
            }
            let info = action.getActionInfo()
            timeLabel.text = action.time
            typeImage.image = info.type.getIcon()
            let tintColor = info.type.getColor()
            typeImage.backgroundColor = tintColor
            actionLabel.textColor = tintColor
            actionLabel.text = info.text
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
        typeImage.layer.cornerRadius = edsHeight / 2
//        typeImage.image = UIImage(systemName: "bell.circle")
        typeImage.contentMode = .scaleAspectFit
        typeImage.tintColor = .white
        typeImage.backgroundColor = .systemGray
        contentView.addSubview(typeImage)
        typeImage.width(edsHeight)
        typeImage.height(edsHeight)
        typeImage.leadingToSuperview(offset: edsSpace)
        typeImage.topToSuperview(offset: edsMinSpace)
        typeImage.bottomToSuperview(offset: -edsMinSpace, relation: .equalOrLess)

//        actionLabel.text = "执行工单 2/XRD-ABCDF"
        actionLabel.numberOfLines = 0
        actionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        actionLabel.textColor = .systemGray
        contentView.addSubview(actionLabel)
//        actionLabel.top(to: typeImage)
        actionLabel.centerY(to: typeImage)
        actionLabel.leadingToTrailing(of: typeImage, offset: edsSpace)
        actionLabel.trailingToSuperview(offset: edsSpace)

//        timeLabel.text = "2020-01-01 00:00:00"
        timeLabel.textColor = .systemGray
        timeLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        contentView.addSubview(timeLabel)
        timeLabel.topToBottom(of: actionLabel, offset: edsMinSpace)
        timeLabel.trailingToSuperview(offset: edsSpace)
        timeLabel.bottomToSuperview(offset: -edsMinSpace, relation: .equalOrLess)
    }

    override func draw(_ rect: CGRect) {
        let line = UIBezierPath()
        let start = CGPoint(x: edsSpace + edsHeight / 2, y: 0)
        let end = start.offset(x: 0, y: rect.height)
        line.move(to: start)
        line.addLine(to: end)
        line.lineWidth = 2
        UIColor.systemGray.setStroke()
        line.stroke()
    }
}
