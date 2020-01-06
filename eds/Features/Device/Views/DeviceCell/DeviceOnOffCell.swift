//
//  DeviceOnOffCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/17.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device功能保护开关onoff样式:init>change ui

import UIKit
import RxSwift
import Moya

class DeviceOnOffCell: UITableViewCell {

    private let space: CGFloat = 20

    private var nameLabel = UILabel()
    private var valueSwitch = UISwitch()
    private let disposeBag = DisposeBag()

    fileprivate func initViews() {
        // Initialization code
//        nameLabel.text = "短路保护"
        nameLabel.textColor = UIColor.systemBlue
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        addSubview(nameLabel)
        nameLabel.centerYToSuperview()
        nameLabel.leadingToSuperview(offset: space)

        valueSwitch.isOn = false
        addSubview(valueSwitch)
        valueSwitch.centerYToSuperview()
        valueSwitch.trailingToSuperview(offset: space)
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

extension DeviceOnOffCell: DevicePageItemSource {
    func initViews(with pageItem: DevicePageItem, rx tags: [Tag], rowIndex: Int) {
        if let tag = tags.first {
            nameLabel.text = pageItem.name.localize(with: prefixDevice)

            tag.showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
                self.valueSwitch.isOn = TagValueConverter.getSwitch(value: $0, items: pageItem.items)
            }).disposed(by: disposeBag)

            valueSwitch.rx.controlEvent(.valueChanged).throttle(.seconds(1), scheduler: MainScheduler.instance).withLatestFrom(valueSwitch.rx.value).subscribe(onNext: {
                if let newValue = TagValueConverter.setSwitch(tagValue: tag.Value, isOn: $0, items: pageItem.items) {
                    tag.Value = newValue
                    MoyaProvider<WAService>().request(.setTagValues(authority: TagUtility.sharedInstance.tempAuthority, tagList: [tag])) { result in
                        switch result {
                        case .success(let response):
                            print(JsonUtility.didSettedValues(data: response.data))
                        default:
                            break
                        }
                    }
                }

            }).disposed(by: disposeBag)
        }
    }

    func getNumerOfRows(with pageItem: DevicePageItem) -> Int {
        return 1
    }


}
