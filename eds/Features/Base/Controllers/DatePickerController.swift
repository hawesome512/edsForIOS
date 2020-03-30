//
//  PickerController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/29.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  日期选择器，从底部弹出半屏Controller
//  items:设置需要选择的日期项目，可选择多个日期
//  delegate:选择所有日期后调用返回数据

import Foundation
import UIKit
import RxCocoa
import RxSwift

class DatePickerController: BottomViewController {

    var items: [String] = []
    //默认时间先后有顺序，下一个时间不早于前一个时间，暂不处理无序时间
    var timeSequence = true
    private var dates: [Date] = []

    private let picker = UIDatePicker()
    private let preButton = UIButton()
    private let nextButton = UIButton()
    private let disposeBag = DisposeBag()

    //当前日期选择器
    private var index = 0 {
        didSet {
            showIndex.accept(index)
        }
    }
    // index数值变化时，发布数据给其他控件订阅
    private var showIndex = BehaviorRelay<Int>(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        //初始化日期容器
        dates = items.map { _ in Date() }
        picker.datePickerMode = .date
        contentView.addSubview(picker)
        picker.centerInSuperview()

        //重选上一个日期
        preButton.setBackgroundImage(UIImage(systemName: "chevron.compact.left"), for: .normal)
        preButton.rx.tap.bind(onNext: {
            self.index = (self.index == 0) ? self.index : self.index - 1
        }).disposed(by: disposeBag)
        contentView.addSubview(preButton)
        preButton.width(edsIconSize)
        preButton.height(edsIconSize)
        preButton.centerYToSuperview()
        preButton.leadingToSuperview(offset: edsSpace)

        //下一个，当为最后一个时就返回数据
        nextButton.rx.tap.bind(onNext: {
            self.dates[self.index] = self.picker.date
            if self.index == self.items.count - 1 {
                self.delegate?.picked(results: self.dates)
                self.dismiss(animated: true, completion: nil)
            }
            self.index = (self.index == self.items.count - 1) ? self.index : self.index + 1
        }).disposed(by: disposeBag)
        contentView.addSubview(nextButton)
        nextButton.width(edsIconSize)
        nextButton.height(edsIconSize)
        nextButton.centerYToSuperview()
        nextButton.trailingToSuperview(offset: edsSpace)

        showIndex.asObservable().subscribe(onNext: { value in
            self.preButton.alpha = (value == 0) ? 0 : 1
            let next = (value == self.items.count - 1) ? "checkmark.circle.fill" : "chevron.compact.right"
            self.nextButton.setBackgroundImage(UIImage(systemName: next), for: .normal)
            self.titleLabel.text = self.items[value]
            //最小时间：当前起，后一个时间不能早于前一个时间
            self.picker.minimumDate = (value == 0) ? Date() : self.dates[value-1]
        }).disposed(by: disposeBag)

        //需要设置默认值，才能出发首次发布订阅，实现初始化界面
        index = 0
    }

}
