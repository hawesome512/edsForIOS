//
//  WorkorderTaskCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class WorkorderTaskCell: UITableViewCell {

    var task: WorkorderTask? {
        didSet {
            if let task = task {
                titleLabel.text = task.title
                checkBox.isSelected = (task.state == WorkorderTaskState.checked)
            }
        }
    }

    private let titleLabel = UILabel()
    let checkBox = CheckBox()

    private func initViews() {

//        checkBox.isSelected = false
        contentView.addSubview(checkBox)
        checkBox.width(edsIconSize)
        checkBox.height(edsIconSize)
        checkBox.centerYToSuperview()
        checkBox.trailingToSuperview(offset: edsSpace)

        contentView.addSubview(titleLabel)
        titleLabel.centerYToSuperview()
        titleLabel.leadingToSuperview(offset: edsSpace)
        titleLabel.trailingToLeading(of: checkBox, offset: edsSpace, relation: .equalOrGreater)
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

}
