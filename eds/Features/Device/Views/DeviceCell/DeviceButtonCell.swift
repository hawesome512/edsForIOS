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
    private var buttonTag = Tag()

    var parentVC: UIViewController?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension DeviceButtonCell: DevicePageItemSource, PasswordVerifyDelegate {

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
                    addSubview(button)
                    buttons.append(button)
                    button.rx.tap.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe({ _ in
                        button.loadedWithAnimation()
                        DangerousAlertController.present(in: self.parentVC, handler: {_ in
                            //------------特殊处理-----------------
                            //XS遗留的问题，原先远程控制位0x5000只写，网关采集失败造成farCtrl点通讯无效，后来一些设备修改0x5000为可读可写
                            //但还是存在某些设备0x5000只写，为保证其通讯流程性，在云平台+网关设备点列表中移除farCtrl点，以至于在TagList中找不到控制点
                            var authorityResult: AuthorityResult = .localLocked
                            if tags.count != 0 {
                                //发送指令：0xAAAA/0x5555,json中已配置为十进制
                                self.buttonTag = Tag(name: tags[0].Name, value: infos[1])
                                authorityResult = VerifyUtility.verify(tag: tags[0], delegate: self, parentVC: self.parentVC)
                            }
                            self.showVerifiedMessage(authority: authorityResult)
                        })
                        
                    }).disposed(by: disposeBag)
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

    //远程控制，每次都必须验证
    func passwordVerified() {
        guard let authority = AccountUtility.sharedInstance.account?.authority else {
            return
        }
        WAService.getProvider().request(.setTagValues(authority: authority, tagList: [buttonTag])) { result in
            switch result {
            case .success(let response):
                if JsonUtility.didSettedValues(data: response.data) {
                    print(String(format: "Update %s value: true", self.buttonTag.Name))
                    let device = DeviceUtility.sharedInstance.getDevice(of: self.buttonTag.getDeviceName())?.title ?? ""
                    ActionUtility.sharedInstance.addAction(.ctrlDevice, extra: device)
                }
            default:
                break
            }
        }
    }

    func showVerifiedMessage(authority: AuthorityResult) {
        switch authority {
        case .localLocked, .userLocked:
            let alertController = UIAlertController(title: "denied".localize(), message: authority.rawValue.localize(), preferredStyle: .alert)
            let cancel = UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil)
            alertController.addAction(cancel)
            parentVC?.navigationController?.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }

}
