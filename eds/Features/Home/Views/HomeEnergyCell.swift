//
//  HomeEnergyCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit


class HomeEnergyCell: UITableViewCell {

    let currentView = HomeEnergyView()
    let lastView = HomeEnergyView()
    let ratioView = HomeRatioView()
    let slider = HorSliderView()

    var energyData: EnergyData? {
        didSet {
            guard let data = self.energyData else {
                return
            }
            let currentTotal = data.getCurrentTotalValue()
            let lastPeriod = data.getLastPeriodTotalValue()
            currentView.value = currentTotal.roundToPlaces(places: 0).clean
            lastView.value = lastPeriod.roundToPlaces(places: 0).clean
            ratioView.value = data.getLinkRatio().roundToPlaces(places: 0)

            //当未设定能耗指标时，选择上期总值为指标
            let current = data.getCurrentTotalValue()
            let last = data.getLastTotalValue()
            let ratio = last == 0 ? 0 : (current / last * 100).roundToPlaces(places: 0)
            slider.value = CGFloat(ratio)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        tintColor = .white
        let contentView = ViewUtility.addCardEffect(in: self)
        ViewUtility.addColorEffect(in: contentView)

        let energyImage = UIImageView()
        energyImage.image = UIImage(systemName: "gauge")
        contentView.addSubview(energyImage)
        energyImage.width(edsIconSize)
        energyImage.height(edsIconSize)
        energyImage.leadingToSuperview(offset: edsMinSpace)
        energyImage.topToSuperview(offset: edsMinSpace)

        let energyLabel = UILabel()
        energyLabel.textColor = .white
        energyLabel.text = "energy".localize(with: prefixHome)
        energyLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        contentView.addSubview(energyLabel)
        energyLabel.centerY(to: energyImage)
        energyLabel.leadingToTrailing(of: energyImage, offset: edsMinSpace)

        contentView.addSubview(slider)
        slider.height(HorSliderView.lineWidth)
        slider.leadingToTrailing(of: energyLabel, offset: edsSpace)
        slider.trailingToSuperview(offset: edsSpace)
        slider.centerY(to: energyImage)

        let sliderLabel = UILabel()
        sliderLabel.textColor = .systemGray
        sliderLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        sliderLabel.text = "percent".localize(with: prefixHome)
        contentView.addSubview(sliderLabel)
        sliderLabel.topToBottom(of: slider)
        sliderLabel.trailing(to: slider)

        currentView.value = "0"
        currentView.nameLabel.text = "current".localize(with: prefixHome)
        contentView.addSubview(currentView)
        currentView.leadingToSuperview(offset: edsMinSpace)
        currentView.centerYToSuperview()

        lastView.value = "0"
        lastView.nameLabel.text = "last".localize(with: prefixHome)
        contentView.addSubview(lastView)
        lastView.leadingToSuperview(offset: edsMinSpace)
        lastView.bottomToSuperview(offset: -edsMinSpace)

        ratioView.value = 0
        contentView.addSubview(ratioView)
        ratioView.trailingToSuperview(offset: edsMinSpace)
        ratioView.centerY(to: lastView)

        let ratioLabel = UILabel()
        ratioLabel.text = "ratio".localize(with: prefixHome)
        ratioLabel.textColor = edsDivideColor
        contentView.addSubview(ratioLabel)
        ratioLabel.leading(to: ratioView)
        ratioLabel.centerY(to: currentView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
