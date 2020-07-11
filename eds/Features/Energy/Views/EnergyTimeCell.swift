//
//  EnergyTimeCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import SwiftDate

class EnergyTimeCell: UITableViewCell {
    
    private let viewSpace: CGFloat = 2
    private let energyTimes = EnergyTime.allCases
    private var widthConstraints :[NSLayoutConstraint] = []
    private var widthRatios: [Double] = []
    private var titleLabels: [UILabel] = []
    private var valueLabels: [UILabel] = []
    private var subValueLabels : [UILabel] = []
    private var showViews: [UIView] = []
    private var priceLabel = UILabel()
    
    private let disposeBag = DisposeBag()

    var parentVC: UIViewController?
    var energyData: EnergyData?{
        didSet{
            updateViews()
        }
    }
    var energy: Energy?

    func updateViews() {
        
        guard let data = energyData, let energy = energy else { return }
        
        //年模式，数值不能精细到hour,不能进行分时统计
        let yearMode = data.dateItem.dateType == .year
        let total = data.getCurrentTotalValue()
        var price: Double = 0
        widthRatios = energyTimes.map{ _ in 1/Double(energyTimes.count) }
        if yearMode {
            valueLabels.forEach { $0.text = "0%" }
            subValueLabels.forEach{ $0.text = 0.0.toCurrencyValue() }
        } else {
            let timeDatas = EnergyUtility.calTimeDatas(energy: energy, data: data)
            timeDatas.forEach{ timeData in
                let energyTime = timeData.energyTime
                let index = energyTime.rawValue
                let ratio = total == 0 ? 0 : timeData.totalValue / total
                valueLabels[index].text = NumberFormatter.localizedString(from: ratio as NSNumber, number: .percent)
                let money = timeData.totalValue * timeData.price
                price += money.roundToPlaces(fractions: 0)
                subValueLabels[index].text = money.toCurrencyValue()
                widthRatios[index] = ratio
            }
        }
        priceLabel.text = price.toCurrencyValue()
        setNeedsDisplay()
    }

    private func initViews() {

        let timeIcon = UIImageView()
        timeIcon.tintColor = .label
        timeIcon.image = UIImage(systemName: "clock")
        addSubview(timeIcon)
        timeIcon.width(edsIconSize)
        timeIcon.height(edsIconSize)
        timeIcon.leadingToSuperview(offset: edsSpace)
        timeIcon.topToSuperview(offset: edsMinSpace)

        let timeLabel = UILabel()
        let title = "time".localize(with: prefixEnergy)
        timeLabel.text = title
        timeLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        timeLabel.adjustsFontSizeToFitWidth = true
        addSubview(timeLabel)
        timeLabel.leadingToTrailing(of: timeIcon, offset: edsMinSpace)
        timeLabel.centerY(to: timeIcon)

        let tipButton = UIButton()
        tipButton.tintColor = .systemGray3
        tipButton.setBackgroundImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        tipButton.rx.tap.bind(onNext: {
            let message = "time_alert".localize(with: prefixEnergy)
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok".localize(), style: .cancel, handler: nil)
            alertVC.addAction(okAction)
            self.parentVC?.present(alertVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        addSubview(tipButton)
        tipButton.width(edsSpace)
        tipButton.height(edsSpace)
        tipButton.leadingToTrailing(of: timeLabel, offset: 2)
        tipButton.centerY(to: timeIcon, offset: -6)
        
        priceLabel.textColor = edsDefaultColor
        priceLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        priceLabel.textAlignment = .right
        priceLabel.adjustsFontSizeToFitWidth = true
        addSubview(priceLabel)
        priceLabel.trailingToSuperview(offset: edsSpace)
        priceLabel.centerY(to: timeIcon)
        priceLabel.leadingToTrailing(of: tipButton, offset: edsSpace, relation: .equalOrGreater)

        for i in 0..<energyTimes.count {
            
            let textAlignment: NSTextAlignment
            switch i {
            case 0:
                textAlignment = .left
            case energyTimes.count-1:
                textAlignment = .right
            default:
                textAlignment = .center
            }
            
            let valueLabel = UILabel()
            valueLabel.textAlignment = textAlignment
            valueLabel.text = "0%"
            valueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            valueLabel.adjustsFontSizeToFitWidth = true
            addSubview(valueLabel)
            valueLabel.topToBottom(of: priceLabel,offset: edsMinSpace)
            if i == 0 {
                valueLabel.leadingToSuperview(offset: edsSpace)
            } else {
                valueLabel.leadingToTrailing(of: valueLabels[i-1],offset: viewSpace)
            }
            let constraint = valueLabel.widthAnchor.constraint(equalToConstant: 0)
            constraint.isActive = true
            valueLabels.append(valueLabel)
            widthConstraints.append(constraint)
            
            let showView = UIView()
            showView.backgroundColor = energyTimes[i].getColor()
            addSubview(showView)
            showView.height(edsMinSpace)
            showView.width(to: valueLabel)
            showView.topToBottom(of: valueLabel,offset: edsMinSpace)
            showView.leading(to: valueLabel)
            
            let subValueLabel = UILabel()
            subValueLabel.textAlignment = textAlignment
            subValueLabel.text = "¥0"
            subValueLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
            subValueLabel.adjustsFontSizeToFitWidth = true
            addSubview(subValueLabel)
            subValueLabel.bottomToSuperview(offset: -edsMinSpace)
            subValueLabel.leading(to: valueLabel)
            subValueLabel.width(to: valueLabel)
            subValueLabels.append(subValueLabel)
            
            let titleLabel = UILabel()
            titleLabel.textAlignment = textAlignment
            titleLabel.text = energyTimes[i].getText()
            titleLabel.textColor = energyTimes[i].getColor()
            titleLabel.adjustsFontSizeToFitWidth = true
            addSubview(titleLabel)
            titleLabel.bottomToTop(of: subValueLabel, offset: -edsMinSpace)
            titleLabel.topToBottom(of: showView, offset: edsMinSpace)
            titleLabel.leading(to: valueLabel)
            titleLabel.width(to: subValueLabel)
            titleLabels.append(titleLabel)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
        EnergyUtility.sharedInstance.successfulUpdated.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: { updated in
            guard updated else { return }
            self.energy = EnergyUtility.sharedInstance.energy
            self.updateViews()
        }).disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let width = rect.width - 2 * edsSpace - CGFloat(widthRatios.count - 1) * viewSpace
        let balancedRatios = EnergyUtility.balancedShowRatio(with: widthRatios)
        for i in 0..<widthRatios.count {
            widthConstraints[i].constant = width * CGFloat(balancedRatios[i])
        }
    }
}
