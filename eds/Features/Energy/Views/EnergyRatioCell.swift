//
//  EnergyRatioCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class EnergyRatioCell: UITableViewCell {
    
    private let disposeBag = DisposeBag()

    private let slider = HorSliderView()
    private let ratioLabel = UILabel()
    private let currentView = HomeEnergyView()
    private let lastView = HomeEnergyView()
    private let linkRatioView = HomeRatioView()
    
    var parentVC: UIViewController?

    func setData(data: EnergyData) {
        let currentTotal = data.getCurrentTotalValue()
        let lastPeriod = data.getLastPeriodTotalValue()
        let lastTotal = data.getLastTotalValue()
        currentView.value = currentTotal.roundToPlaces(places: 0).clean
        lastView.value = lastPeriod.roundToPlaces(places: 0).clean
        linkRatioView.value = data.getLinkRatio().roundToPlaces(places: 0)

        //当未设定能耗指标时，选择上期总值为指标
        let ratio = lastTotal == 0 ? 0 : Double(currentTotal / lastTotal * 100).roundToPlaces(places: 0)
        slider.value = CGFloat(ratio)
        ratioLabel.text = ratio.clean + "%"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        let valueFont = UIFont.boldSystemFont(ofSize: 20)
        let timeIcon = UIImageView()
        timeIcon.tintColor = .label
        timeIcon.image = UIImage(systemName: "gauge")
        addSubview(timeIcon)
        timeIcon.width(edsIconSize)
        timeIcon.height(edsIconSize)
        timeIcon.leadingToSuperview(offset: edsSpace)
        timeIcon.topToSuperview(offset: edsMinSpace)

        let sliderLabel = UILabel()
        sliderLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        let title = "percent".localize(with: prefixEnergy)
        sliderLabel.text = title
        addSubview(sliderLabel)
        sliderLabel.centerY(to: timeIcon)
        sliderLabel.leadingToTrailing(of: timeIcon, offset: edsMinSpace)
        
        let tipButton = UIButton()
        tipButton.tintColor = .systemGray3
        tipButton.setBackgroundImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        tipButton.rx.tap.bind(onNext: {
            let message = "percent_alert".localize(with: prefixEnergy)
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok".localize(), style: .cancel, handler: nil)
            alertVC.addAction(okAction)
            self.parentVC?.present(alertVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        addSubview(tipButton)
        tipButton.width(edsSpace)
        tipButton.height(edsSpace)
        tipButton.leadingToTrailing(of: sliderLabel, offset: 2)
        tipButton.centerY(to: timeIcon, offset: -6)

        ratioLabel.text = "0%"
        ratioLabel.textColor = edsDefaultColor
        ratioLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        addSubview(ratioLabel)
        ratioLabel.centerY(to: sliderLabel)
        ratioLabel.trailingToSuperview(offset: edsSpace)

        slider.trackColor = .lightGray
        slider.thumbColor = edsDefaultColor
        addSubview(slider)
        slider.height(HorSliderView.lineWidth)
        slider.horizontalToSuperview(insets: .horizontal(edsSpace))
        slider.topToBottom(of: timeIcon, offset: edsSpace)

        currentView.tintColor = .label
        currentView.valueFont = valueFont
        currentView.value = "0"
        currentView.nameLabel.textColor = .darkGray
        currentView.nameLabel.text = "current".localize(with: prefixEnergy)
        addSubview(currentView)
        currentView.leadingToSuperview(offset: edsSpace)
        currentView.topToBottom(of: slider, offset: edsMinSpace)

        lastView.tintColor = .label
        lastView.valueFont = valueFont
        lastView.value = "0"
        lastView.nameLabel.textColor = .darkGray
        lastView.nameLabel.text = "last".localize(with: prefixEnergy)
        addSubview(lastView)
        lastView.leadingToSuperview(offset: edsSpace)
        lastView.topToBottom(of: currentView, offset: edsMinSpace)
        lastView.bottomToSuperview(offset: -edsMinSpace)

        linkRatioView.value = 0
        linkRatioView.valueLabel.textColor = .label
        linkRatioView.valueLabel.font = valueFont
        addSubview(linkRatioView)
        linkRatioView.trailingToSuperview(offset: edsMinSpace)
        linkRatioView.centerY(to: lastView)

        let linkRatioLabel = UILabel()
        linkRatioLabel.textColor = .darkGray
        linkRatioLabel.text = "ratio".localize(with: prefixHome)
        addSubview(linkRatioLabel)
        linkRatioLabel.leading(to: linkRatioView)
        linkRatioLabel.centerY(to: currentView)
    }
}
