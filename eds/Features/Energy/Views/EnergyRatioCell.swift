//
//  EnergyRatioCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class EnergyRatioCell: UITableViewCell {

    let slider = HorSliderView()
    let ratioLabel = UILabel()
    let currentView = HomeEnergyView()
    let lastView = HomeEnergyView()
    let linkRatioView = HomeRatioView()

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
        timeIcon.tintColor = .black
        timeIcon.image = UIImage(systemName: "gauge")
        addSubview(timeIcon)
        timeIcon.width(edsIconSize)
        timeIcon.height(edsIconSize)
        timeIcon.leadingToSuperview(offset: edsSpace)
        timeIcon.topToSuperview(offset: edsMinSpace)

        let sliderLabel = UILabel()
        sliderLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        sliderLabel.text = "percent".localize(with: prefixEnergy)
        addSubview(sliderLabel)
        sliderLabel.centerY(to: timeIcon)
        sliderLabel.leadingToTrailing(of: timeIcon, offset: edsMinSpace)

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

        currentView.tintColor = .darkText
        currentView.valueFont = valueFont
        currentView.value = "0"
        currentView.nameLabel.textColor = .darkGray
        currentView.nameLabel.text = "current".localize(with: prefixEnergy)
        addSubview(currentView)
        currentView.leadingToSuperview(offset: edsSpace)
        currentView.topToBottom(of: slider, offset: edsMinSpace)

        lastView.tintColor = .darkText
        lastView.valueFont = valueFont
        lastView.value = "0"
        lastView.nameLabel.textColor = .darkGray
        lastView.nameLabel.text = "last".localize(with: prefixEnergy)
        addSubview(lastView)
        lastView.leadingToSuperview(offset: edsSpace)
        lastView.topToBottom(of: currentView, offset: edsMinSpace)
        lastView.bottomToSuperview(offset: -edsMinSpace)

        linkRatioView.value = 0
        linkRatioView.valueLabel.textColor = .darkText
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
