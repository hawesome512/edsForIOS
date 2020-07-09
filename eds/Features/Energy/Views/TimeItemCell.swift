//
//  TimeItemCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/6/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  时段显示：标题，电价，时段

import UIKit
import RxSwift
import DropDown

protocol TimeItemDelegate {
    func changeItem(_ changedItem: TimeData)
}

class TimeItemCell: UITableViewCell, UITextFieldDelegate {
    
    private let disposeBag = DisposeBag()
    private let dropDown = DropDown()
    private let titleLabel = UILabel()
    private let priceButton = UIButton()
    private let hoursButton = UIButton()
    private let totalLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    var timeData: TimeData? {
        didSet{
            guard let timeData = timeData else { return }
            titleLabel.text = timeData.energyTime.getText()
            gradientLayer.setHorRightGradientLayer(centerColor: timeData.energyTime.getColor())
            timeData.hours.forEach{ dropDown.selectRow($0) }
            self.setPrice()
            self.setHours()
        }
    }
    var parentVC: UIViewController?
    var delegate: TimeItemDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        //渐变层需要约束frame
        gradientLayer.frame = bounds
    }
    
    private func initViews(){
        
        //添加渐变层
        gradientLayer.setCornerGradientLayer(endColor: edsDefaultColor)
        layer.insertSublayer(gradientLayer, at: 0)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        titleLabel.text = EnergyTime.valley.getText()
        addSubview(titleLabel)
        titleLabel.topToSuperview(offset: edsMinSpace)
        titleLabel.leadingToSuperview(offset: edsSpace)
        
        priceButton.tintColor = .label
        priceButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        priceButton.setTitleColor(.label, for: .normal)
        priceButton.contentHorizontalAlignment = .fill
        priceButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {
            let title = "price".localize(with: prefixEnergy)
            let value = "\(self.timeData?.price ?? 0)"
            let alertVC = ControllerUtility.generateInputAlertController(title: title, placeholder: value, delegate: self)
            alertVC.textFields?.first?.keyboardType = .decimalPad
            let confirmAction = UIAlertAction(title: "confirm".localize(), style: .default){ _ in
                guard let newValue = alertVC.textFields?.first?.text, let validValue = Double(newValue) else { return }
                self.timeData?.price = validValue
                self.setPrice()
            }
            alertVC.addAction(confirmAction)
            self.parentVC?.present(alertVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        addSubview(priceButton)
        priceButton.centerY(to: titleLabel)
        priceButton.trailingToSuperview(offset: edsSpace)
        priceButton.height(edsIconSize)
        
        hoursButton.tintColor = .label
        hoursButton.setImage(UIImage(systemName: "clock"), for: .normal)
        hoursButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: edsMinSpace, bottom: 0, right: 0)
        hoursButton.setTitleColor(.label, for: .normal)
        hoursButton.contentHorizontalAlignment = .left
        hoursButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {
            self.dropDown.show()
        }).disposed(by: disposeBag)
        hoursButton.titleLabel?.adjustsFontSizeToFitWidth = true
        addSubview(hoursButton)
        hoursButton.topToBottom(of: titleLabel,offset: edsMinSpace)
        hoursButton.bottomToSuperview(offset: -edsMinSpace)
        hoursButton.leadingToSuperview(offset: edsSpace)
//        hoursButton.trailingToSuperview(offset: edsSpace, relation: .equalOrGreater)
        
//        totalLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        addSubview(totalLabel)
        totalLabel.trailingToSuperview(offset: edsSpace)
        totalLabel.centerY(to: hoursButton)
        hoursButton.trailingToLeading(of: totalLabel, offset: -edsSpace)
        
        let appearance = DropDown.appearance()
        appearance.selectionBackgroundColor = edsDefaultColor.withAlphaComponent(0.3)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textFont = UIFont.preferredFont(forTextStyle: .title3)
        
        dropDown.dataSource = Array(0..<TimeData.hourSectionCount).map{
            if $0 % 2 == 0 {
                return String(format: "   %02d:00   ---   %02d:30   ", $0/2, $0/2)
            } else {
                return String(format: "   %02d:30   ---   %02d:00   ", $0/2, $0/2+1)
            }
        }
        dropDown.anchorView = hoursButton
        dropDown.multiSelectionAction = { [unowned self] (indexs: [Int], items: [String]) in
            guard let timeData = self.timeData else { return }
            timeData.hours = indexs.sorted()
            self.setHours()
            //每次选择都提交，不合理，浪费资源
            self.delegate?.changeItem(timeData)
        }
    }
    
    private func setPrice() {
        guard let timeData = timeData else { return }
        let price = "price".localize(with: prefixEnergy) + " : " + "\(timeData.price)"
        priceButton.setTitle(price, for: .normal)
    }
    
    private func setHours() {
        guard let timeData = timeData else { return }
        let hours = timeData.toHourRangeString()//.hours.map{ "\($0)" }.joined(separator: " / ")
        hoursButton.setTitle(hours, for: .normal)
        totalLabel.text = "\(timeData.hours.count/2)h"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            dropDown.show()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

}
