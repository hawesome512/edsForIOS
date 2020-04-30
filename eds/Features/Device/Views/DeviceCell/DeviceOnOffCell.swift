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
    private var extraLabel = UILabel()
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

        extraLabel.textColor = .systemGray
        addSubview(extraLabel)
        extraLabel.trailingToLeading(of: valueSwitch, offset: -space)
        extraLabel.verticalToSuperview()
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
            nameLabel.text = pageItem.name.localize()

            tag.showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
                let isOn = TagValueConverter.getSwitch(value: $0, items: pageItem.items)
                self.valueSwitch.isOn = isOn
                if let item = pageItem.items?.first, item.contains(DeviceModel.itemInfoSeparator) {
                    let infos = item.components(separatedBy: DeviceModel.itemInfoSeparator)
                    //["1/false/true"]
                    if infos.count == 3 {
                        self.extraLabel.text = "\(pageItem.name)_\(isOn ? infos[2] : infos[1])".localize()
                        return
                    }
                }
                self.extraLabel.text = nil
            }).disposed(by: disposeBag)

            valueSwitch.rx.controlEvent(.valueChanged).throttle(.seconds(1), scheduler: MainScheduler.instance).withLatestFrom(valueSwitch.rx.value).subscribe(onNext: {
                if let newValue = TagValueConverter.setSwitch(tagValue: tag.Value, isOn: $0, items: pageItem.items) {
                    self.extraLabel.text = "updating".localize()
                    //tag.Value = newValue,直接赋值，value将直接显示在extraLabel中不表示真实的后台修改值
                    let newTag = Tag(name: tag.Name, value: newValue)
                    guard let authority = AccountUtility.sharedInstance.account?.authority else {
                        return
                    }
                    MoyaProvider<WAService>().request(.setTagValues(authority: authority, tagList: [newTag])) { result in
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
