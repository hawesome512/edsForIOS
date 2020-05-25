//
//  EnergyTimeCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class EnergyTimeCell: UITableViewCell {

    private let minLabel = UILabel()
    private let avgLabel = UILabel()
    private let maxLabel = UILabel()
    private let minValueLabel = UILabel()
    private let maxValueLabel = UILabel()
    private let avgValueLabel = UILabel()
    private let minMoneyLabel = UILabel()
    private let maxMoneyLabel = UILabel()
    private let avgMoneyLabel = UILabel()
    private let disposeBag = DisposeBag()

    var parentVC: UIViewController?

    func setData(_ data: EnergyData) {
        let total = data.getCurrentTotalValue()
        if total == 0 {
            minValueLabel.text = "0%"
            avgValueLabel.text = "0%"
            maxValueLabel.text = "0%"
            minMoneyLabel.text = "¥ 0"
            avgMoneyLabel.text = "¥ 0"
            maxMoneyLabel.text = "¥ 0"
        }

        let timeData = data.calTimePrice()
        let minTotal = timeData[.valley]!
        let minRatio = total == 0 ? 0 : minTotal / total * 100
        minValueLabel.text = minRatio.roundToPlaces(places: 0).clean + "%"
        let minMoney = Double(minTotal) * EnergyPrice.valley.getPrice()
        minMoneyLabel.text = "¥ \(minMoney.roundToPlaces(places: 0).clean)"

        let avgTotal = timeData[.plain]!
        let avgRatio =  total == 0 ? 0 : avgTotal / total * 100
        avgValueLabel.text = avgRatio.roundToPlaces(places: 0).clean + "%"
        let avgMoney = Double(avgTotal) * EnergyPrice.plain.getPrice()
        avgMoneyLabel.text = "¥ \(avgMoney.roundToPlaces(places: 0).clean)"

        let maxTotal = timeData[.peek]!
        let maxRatio =  total == 0 ? 0 : maxTotal / total * 100
        maxValueLabel.text = maxRatio.roundToPlaces(places: 0).clean + "%"
        let maxMoney = Double(maxTotal) * EnergyPrice.peek.getPrice()
        maxMoneyLabel.text = "¥ \(maxMoney.roundToPlaces(places: 0).clean)"
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

        //低谷
        minValueLabel.text = "0%"
        minValueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(minValueLabel)
        minValueLabel.leadingToSuperview(offset: edsSpace)
        minValueLabel.topToBottom(of: timeLabel, offset: edsMinSpace)

        minMoneyLabel.text = "¥ 0"
        minMoneyLabel.textColor = .systemYellow
        addSubview(minMoneyLabel)
        minMoneyLabel.leadingToSuperview(offset: edsSpace)
        minMoneyLabel.bottomToSuperview(offset: -edsMinSpace)

        minLabel.text = "valley".localize(with: prefixEnergy)
        minLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addSubview(minLabel)
        minLabel.leadingToSuperview(offset: edsSpace)
        minLabel.bottomToTop(of: minMoneyLabel, offset: -edsMinSpace)
        minLabel.topToBottom(of: minValueLabel, offset: 2 * edsSpace)

        //平段
        avgValueLabel.text = "0%"
        avgValueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(avgValueLabel)
        avgValueLabel.centerXToSuperview()
        avgValueLabel.topToBottom(of: timeLabel, offset: edsMinSpace)

        avgMoneyLabel.text = "¥ 0"
        avgMoneyLabel.textColor = .systemYellow
        addSubview(avgMoneyLabel)
        avgMoneyLabel.centerXToSuperview()
        avgMoneyLabel.bottomToSuperview(offset: -edsMinSpace)

        avgLabel.text = "plain".localize(with: prefixEnergy)
        avgLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addSubview(avgLabel)
        avgLabel.centerXToSuperview()
        avgLabel.bottomToTop(of: avgMoneyLabel, offset: -edsMinSpace)

        //高峰
        maxValueLabel.text = "0%"
        maxValueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(maxValueLabel)
        maxValueLabel.trailingToSuperview(offset: edsSpace)
        maxValueLabel.topToBottom(of: timeLabel, offset: edsMinSpace)

        maxMoneyLabel.text = "¥ 0"
        maxMoneyLabel.textColor = .systemYellow
        addSubview(maxMoneyLabel)
        maxMoneyLabel.trailingToSuperview(offset: edsSpace)
        maxMoneyLabel.bottomToSuperview(offset: -edsMinSpace)

        maxLabel.text = "peak".localize(with: prefixEnergy)
        maxLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addSubview(maxLabel)
        maxLabel.trailingToSuperview(offset: edsSpace)
        maxLabel.bottomToTop(of: maxMoneyLabel, offset: -edsMinSpace)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        //绘黑线,在居中偏下（+4）的位置
        let centerY: CGFloat = rect.height * 0.5 + 4
        let radius: CGFloat = 6
        let start = CGPoint(x: edsSpace + radius, y: centerY)
        let end = CGPoint(x: rect.width - edsSpace, y: centerY)
        let center = CGPoint(x: rect.width / 2, y: centerY)

        let path = UIBezierPath()
        path.lineWidth = 2
        UIColor.lightGray.setStroke()
        path.move(to: start)
        path.addLine(to: end)
        path.stroke()

        let circle1 = UIBezierPath()
        circle1.addArc(withCenter: start, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        UIColor.systemGreen.setFill()
        circle1.fill()

        let circle2 = UIBezierPath()
        circle2.addArc(withCenter: end, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        UIColor.systemRed.setFill()
        circle2.fill()

        let circle3 = UIBezierPath()
        circle3.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        UIColor.systemBlue.setFill()
        circle3.fill()
    }
}
