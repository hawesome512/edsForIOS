//
//  DeviceButtonCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/16.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device的按键控制，一行建议最多3个按键，超出时用多行row处理：init>items(addButtons)

import UIKit
import RxSwift
import Moya

class DeviceButtonCell: UITableViewCell {

    private let space: CGFloat = 20
    private var buttons = [UIButton]()
    private let disposeBag = DisposeBag()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension DeviceButtonCell: DevicePageItemSource {
    func getNumerOfRows(with pageItem: DevicePageItem) -> Int {
        return 1
    }

    func initViews(with pageItem: DevicePageItem, rx tags: [Tag], rowIndex: Int) {
        //Add buttons by items
        if let items = pageItem.items {
            items.forEach { item in
                let infos = item.components(separatedBy: DeviceModel.itemInfoSeparator)
                if infos.count == 3 {
                    let button = UIButton()
                    button.backgroundColor = UIColor.init(colorName: infos[2])
                    button.tintColor = UIColor.white
                    button.setTitle(infos[0], for: .normal)
                    button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
                    button.rx.tap.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe({ _ in
                        //发送指令：0xAAAA/0x5555,json中已配置为十进制
                        tags[0].Value = infos[1]
                        MoyaProvider<WAService>().request(.setTagValues(authority: TagUtility.sharedInstance.tempAuthority, tagList: tags)) { result in
                            switch result {
                            case .success(let response):
                                print(String(format: "Update %s value: %b", tags[0].Name, JsonUtility.didSettedValues(data: response.data)))
                            default:
                                break
                            }
                        }
                    }).disposed(by: disposeBag)
                    addSubview(button)
                    buttons.append(button)
                }
            }
            //Add Constraints
            //CGFloat方便下面的“宽”的计算公式
            let count = CGFloat( buttons.count)
            for index in 0..<buttons.count {
                let button = buttons[index]
                //垂直缩进space
                button.verticalToSuperview(insets: .uniform(space))
                //宽：[width-space*(n+1)]/n,均分屏宽
                let ratio = 1 / count
                let widthOffset = (count + 1) / count * space
                button.widthToSuperview(multiplier: ratio, offset: -widthOffset)
                if index == 0 {
                    button.leadingToSuperview(offset: space)
                } else {
                    button.leadingToTrailing(of: buttons[index - 1], offset: space)
                }
            }
        }
    }

}
