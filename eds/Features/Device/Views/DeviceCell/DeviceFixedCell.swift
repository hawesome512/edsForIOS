//
//  DeviceStaticCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/20.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device静态（非通信型），资产管理的一部分

import UIKit
import TinyConstraints
import RxSwift

class DeviceFixedCell: UITableViewCell {
    
    private let fontSize:CGFloat=20

    var foldButton = UIButton()
    var deviceImageView = UIImageView()
    var nameLabel = UILabel()
    var levelLabel = RoundLabel()
    private var leading: Constraint?
    private let disposeBag = DisposeBag()
    var delegate: AdditionDelegate?

    var device: Device? {
        didSet {
            guard let device = device else { return }
            //不同类型的Device缩进不同，实现层级分支
            let constant = CGFloat(indentationLevel) * edsSpace
            leading?.constant = constant
            //自定义cell控件约束不受layoutMargin影响，它只影响分割线
            layoutMargins.left = constant
            
            if let image = device.getCollapsedImage() {
                foldButton.setImage(image, for: .normal)
            } else {
                foldButton.setImage(nil, for: .normal)
                //静态设备无>符号（20),且其与deviceImageView的水平间隙（10）也将取消，故左移1.5*space
                leading?.constant -= 1.5 * edsSpace
            }
            nameLabel.text = device.title
            if device.level == .room {
                nameLabel.font=UIFont.boldSystemFont(ofSize: fontSize)
            }
            nameLabel.textColor = device.getTintColor()
            levelLabel.alpha = (device.level == DeviceLevel.fixed) ? 1 : 0
            deviceImageView.image = device.getIcon()
            
            if AccountUtility.sharedInstance.isOperable() {
                let accessoryButton = device.getAccessoryView()
                accessoryButton?.rx.tap.bind(onNext: {
                    accessoryButton?.loadedWithAnimation()
                    self.delegate?.add(inParent: device)
                }).disposed(by: disposeBag)
                accessoryView = accessoryButton
            }
        }
    }

    private func initViews() {
        tintColor = .systemGray
        foldButton.size(CGSize(width: edsSpace, height: edsSpace))
        addSubview(foldButton)
        leading = foldButton.leadingToSuperview(offset: edsSpace)
        foldButton.centerYToSuperview()

        deviceImageView.contentMode = .scaleAspectFit
        addSubview(deviceImageView)
        deviceImageView.heightToSuperview(offset: -edsSpace)
        deviceImageView.widthToHeight(of: deviceImageView)
        deviceImageView.leadingToTrailing(of: foldButton, offset: edsSpace / 2)
        deviceImageView.centerYToSuperview()

        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        nameLabel.centerYToSuperview()
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        nameLabel.leadingToTrailing(of: deviceImageView, offset: edsSpace / 2)

        levelLabel.textColor = .systemGray
        levelLabel.layer.borderColor = UIColor.systemGray3.cgColor
        levelLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        levelLabel.innerText = "uncommunicate".localize()
        addSubview(levelLabel)
        levelLabel.top(to: nameLabel)
        levelLabel.height(24)
        levelLabel.leadingToTrailing(of: nameLabel, offset: edsSpace / 2)
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
