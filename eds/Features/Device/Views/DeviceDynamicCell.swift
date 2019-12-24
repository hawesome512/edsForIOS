//
//  DeviceCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/19.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device设备列表页的cell,含运行状态statusView

import UIKit

class DeviceDynamicCell: UITableViewCell {

    private let space: CGFloat = 20
    private let size: CGFloat = 24

    var deviceImageView = UIImageView()
    var nameLabel = UILabel()
    var infoLabel = UILabel()
    var statusView = UIView()

    fileprivate func initViews() {

//        deviceImageView.image = UIImage(named: "device_ACB")
        deviceImageView.contentMode = .scaleAspectFit
        addSubview(deviceImageView)

        let superView = deviceImageView.superview!
        deviceImageView.translatesAutoresizingMaskIntoConstraints = false
        deviceImageView.heightAnchor.constraint(equalTo: superView.heightAnchor, constant: -space * 2).isActive = true
        deviceImageView.widthAnchor.constraint(equalTo: deviceImageView.heightAnchor).isActive = true
        deviceImageView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: space).isActive = true
        deviceImageView.topAnchor.constraint(equalTo: superView.topAnchor, constant: space).isActive = true

//        nameLabel.text = "ACB(KB#3)"
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: superView.topAnchor, constant: space).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: deviceImageView.trailingAnchor, constant: space).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: deviceImageView.heightAnchor, multiplier: 0.5).isActive = true

        infoLabel.text = NSLocalizedString("编辑资产基本信息", comment: "device_info_default")
        infoLabel.font = UIFont.preferredFont(forTextStyle: .body)
        infoLabel.textColor = .systemGray
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: space).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: deviceImageView.trailingAnchor, constant: space).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -space).isActive = true

        statusView.layer.cornerRadius = size / 2
        statusView.clipsToBounds = true
        statusView.backgroundColor = .red
        addSubview(statusView)
        statusView.translatesAutoresizingMaskIntoConstraints = false
        statusView.widthAnchor.constraint(equalToConstant: size).isActive = true
        statusView.heightAnchor.constraint(equalToConstant: size).isActive = true
        statusView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        statusView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: space).isActive = true
        statusView.trailingAnchor.constraint(lessThanOrEqualTo: superView.trailingAnchor, constant: -space).isActive = true
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
