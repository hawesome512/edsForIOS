//
//  DeviceListHeaderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/2/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  在设备/工单/异常/设备信息列表中添加头视图【新增记录】

import Foundation
import UIKit
import RxSwift

protocol AdditionDelegate {
    func add(inParent parent: Device?)
}

class AdditionTableHeaderView: UIView {

    private let disposeBag = DisposeBag()

    var delegate: AdditionDelegate?

    let title = UILabel()

    private func initViews() {

        backgroundColor = edsDivideColor

        let button = UIButton(type: .contactAdd)
        addSubview(button)
        button.leadingToSuperview(offset: edsSpace)
        button.verticalToSuperview(insets: .vertical(edsSpace))
        button.rx.tap.bind(onNext: {
            button.loadedWithAnimation()
            //新建配电房，无父级Device
            self.delegate?.add(inParent: nil)
        }).disposed(by: disposeBag)

//        title.text = "add_room".localize(with: prefixDevice)
        title.font = UIFont.preferredFont(forTextStyle: .title3)
        title.textColor = edsDefaultColor
        addSubview(title)
        title.centerYToSuperview()
        title.leadingToTrailing(of: button, offset: edsSpace)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
