//
//  WorkorderInfoCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class WorkorderInfoCell: UITableViewCell {

    var info: WorkorderInfo? {
        didSet {
            textLabel?.text = info?.title
            detailTextLabel?.text = info?.value
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
