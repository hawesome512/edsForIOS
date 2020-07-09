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


protocol PickerDelegate {
    func picked(results: [Date])
    func pickerCanceled()
}

/// 时间限制
enum DateLimit {
    //选择过去的时间
    case before
    //选择将来的时间
    case after
    case none
}

class DatePickerController: BottomController {

    var delegate: PickerDelegate?
    var items: [String] = []
    //默认时间先后有顺序，下一个时间不早于前一个时间，暂不处理无序时间
    var timeSequence = true
    private var dates: [Date] = []

    let picker = UIDatePicker()
    var dateLimit:DateLimit = .after
    private let preButton = UIButton()
    private let nextButton = UIButton()
    private let preLabel=UILabel()
    private let disposeBag = DisposeBag()

    //当前日期选择器
    private var index = 0 {
        didSet {
            showIndex.accept(index)
        }
    }
    // index数值变化时，发布数据给其他控件订阅
    private var showIndex = BehaviorRelay<Int>(value: 0)
    
    override init(){
        super.init()
        //在查询历史记录时，需要更改datePickerMode,picker如果放在initViews()更改日期模式将无效
        dates = items.map { _ in Date() }
        picker.datePickerMode = .date
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        contentView.addSubview(picker)
        picker.centerInSuperview()
        //重选上一个日期
        preButton.setBackgroundImage(UIImage(systemName: "chevron.compact.left"), for: .normal)
        preButton.rx.tap.bind(onNext: {
            self.preButton.loadedWithAnimation()
            self.index = (self.index == 0) ? self.index : self.index - 1
            self.pickerChanged()
        }).disposed(by: disposeBag)
        contentView.addSubview(preButton)
        preButton.width(edsIconSize)
        preButton.height(edsIconSize)
        preButton.centerYToSuperview()
        preButton.leadingToSuperview(offset: edsSpace)

        //下一个，当为最后一个时就返回数据
        nextButton.rx.tap.bind(onNext: {
            self.nextButton.loadedWithAnimation()
            if self.index<self.dates.count {
                self.dates[self.index] = self.picker.date
            }else{
                self.dates.append(self.picker.date)
            }
            if self.index == self.items.count - 1 {
                self.dismiss(animated: true, completion: nil)
                self.delegate?.picked(results: self.dates)
            }
            self.index = (self.index == self.items.count - 1) ? self.index : self.index + 1
            self.pickerChanged()
        }).disposed(by: disposeBag)
        contentView.addSubview(nextButton)
        nextButton.width(edsIconSize)
        nextButton.height(edsIconSize)
        nextButton.centerYToSuperview()
        nextButton.trailingToSuperview(offset: edsSpace)
        
        preLabel.font=UIFont.preferredFont(forTextStyle: .footnote)
        preLabel.textAlignment = .center
        preLabel.alpha=0
        contentView.addSubview(preLabel)
        preLabel.bottomToSuperview(usingSafeArea:true)
        preLabel.horizontalToSuperview()
        
        switch dateLimit {
        case .before:
            picker.maximumDate=Date()
        case .after:
            picker.minimumDate=Date()
        default:
            break
        }

        showIndex.asObservable().subscribe(onNext: { value in
            self.preButton.alpha = (value == 0) ? 0 : 1
            let next = (value == self.items.count - 1) ? "checkmark.circle.fill" : "chevron.compact.right"
            self.nextButton.setBackgroundImage(UIImage(systemName: next), for: .normal)
            self.titleLabel.text = self.items[value]
            //最小时间：当前起，后一个时间不能早于前一个时间
            if value>0 {
                let preDate = self.dates[value-1]
                self.picker.minimumDate = preDate
                self.preLabel.alpha=1
                let preText = (self.picker.datePickerMode == .dateAndTime) ? preDate.toDateTimeString() : preDate.toDateString()
                self.preLabel.text="\(self.items[value-1]):\(preText)"
            } else {
                self.preLabel.alpha=0
            }
        }).disposed(by: disposeBag)

        //需要设置默认值，才能出发首次发布订阅，实现初始化界面
        index = 0
    }

    private func pickerChanged() {
        //增加动画效果，避免页面在切换过程中过于死板好像没有变化
        picker.alpha = 0
        UIView.animate(withDuration: 1) {
            self.picker.alpha = 1
        }
    }

}
