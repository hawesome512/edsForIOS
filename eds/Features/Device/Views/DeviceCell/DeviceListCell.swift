//
//  DeviceDefaultCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/17.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device默认显示样式：实时之item,参数之list:init>value

import UIKit
import RxSwift

class DeviceListCell: UITableViewCell, PasswordVerifyDelegate {

    private let preferredFont = UIFont.preferredFont(forTextStyle: .title3)
    private let disposeBag = DisposeBag()

    private var nameLabel = UILabel()
    private var valueLabel = UILabel()
    //计算行数时需要使用到pageItem
    private var pageItem: DevicePageItem?
    private var listTag: Tag?
    //是否累加值，在DeviceTrendViewController使用
    private var isAccumulated = false
    private var device: Device?
    private var cellType: DeviceCellType = .list

    var parentVC: UIViewController?

    fileprivate func initViews() {
        //cell右边icon样式“>"
        accessoryType = .disclosureIndicator

//        nameLabel.text = "短路短延时(s)"
        nameLabel.textColor = edsDefaultColor
        nameLabel.font = preferredFont
        contentView.addSubview(nameLabel)
        nameLabel.centerYToSuperview()
        nameLabel.leadingToSuperview(offset: edsSpace)
        valueLabel.text = String(format: "%d", Tag.nilValue)
        valueLabel.font = preferredFont
        contentView.addSubview(valueLabel)
        valueLabel.centerYToSuperview()
        //因cell右边存在accessoryType，space*2,避免其被覆盖
        valueLabel.trailingToSuperview(offset: edsMinSpace)
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
        guard selected else {
            return
        }
        //参数修改页面or趋势评估页面
        if cellType == .list {
            let trendViewController = DeviceTrendController()
            trendViewController.title = nameLabel.text
            trendViewController.trend(with: [listTag!], condition: nil, isAccumulated: isAccumulated)
            parentVC?.navigationController?.pushViewController(trendViewController, animated: true)
        } else {
            if let verified = device?.verified, verified {
                presentMeterViewController(authority: .granted)
                return
            }
            let authorityResult = VerifyUtility.verify(tag: listTag!, delegate: self, parentVC: parentVC)
            presentMeterViewController(authority: authorityResult)
        }
    }

    //修改参数时，密码验证成功，打开参数表盘界面
    func passwordVerified() {
        device?.verified = true
        presentMeterViewController(authority: .granted)
    }

    //打开参数表盘界面，本地模式/权限限制只能查看
    private func presentMeterViewController(authority: AuthorityResult) {
        //正在验证中，等待返回结果
        if authority == .verifying { return }
        
        //等差数列,["*","0","0.1","10"]
        if cellType == .slider {
            let sliderVC = ParamSliderController()
            sliderVC.initViews(with: pageItem!, tag: listTag!, authority: authority)
            parentVC?.navigationController?.pushViewController(sliderVC, animated: true)
        } else {
            let itemMeterViewController = UIStoryboard(name: "Device", bundle: nil).instantiateViewController(withIdentifier: String(describing: ParamMeterController.self)) as! ParamMeterController
            itemMeterViewController.initViews(with: pageItem!, tag: listTag!, authority: authority)
            parentVC?.navigationController?.pushViewController(itemMeterViewController, animated: true)
        }
    }
}

extension DeviceListCell: DevicePageItemSource {

    func getNumerOfRows(with pageItem: DevicePageItem) -> Int {
        return pageItem.tags.count
    }

    func initViews(with pageItem: DevicePageItem, rx tags: [Tag], rowIndex: Int) {
        let tag = tags[rowIndex]
        self.pageItem = pageItem
        cellType = DeviceCellType(rawValue: pageItem.display) ?? .list
        self.device = DeviceUtility.sharedInstance.getDevice(of: tag.getDeviceName())
        listTag = tag
        if pageItem.items?.first == DeviceModel.itemsAccumulation {
            isAccumulated = true
        }
        //默认使用pageItem.name(更方便自定义，如ACB的Ir(A)与MCCB的Ir(In)显示不同
        let tagTitle = tags.count == 1 ? pageItem.name : tag.getTagShortName()
        nameLabel.attributedText = tagTitle.localize().formatNameAndUnit()
        tag.showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
            var value = $0.clean
            //List模式时：items有值时，显示固定转换值，items里包含转换信息(排除累加值的情况）
            if let items = pageItem.items, items.first != DeviceModel.itemsAccumulation, DeviceCellType(rawValue: pageItem.display) == .list {
                value = TagValueConverter.getFixedText(value: $0, items: items).localize()
            }
            if let converter = pageItem.converter, let cov = ValueConverter(rawValue: converter) {
                value = TagValueConverter.convert(with: value, of: cov)
            }
            self.valueLabel.text = value.toLocalNumber()
        }).disposed(by: disposeBag)

    }


}
