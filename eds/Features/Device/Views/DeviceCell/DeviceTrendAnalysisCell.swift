//
//  DeviceListAnalysisCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.

import UIKit

class DeviceTrendAnalysisCell: UITableViewCell {

    private let minLabel = UILabel()
    private let avgLabel = UILabel()
    private let maxLabel = UILabel()
    private let minTimeLabel = UILabel()
    private let maxTimeLabel = UILabel()
    private let minValueLabel = UILabel()
    private let maxValueLabel = UILabel()
    private let avgValueLabel = UILabel()

    func setData(_ logTags: [(name: String, values: [Double])], condition: WATagLogRequestCondition) {
        //每种点的数据笔数相同，计算数据长度，用于推导最大/小值所处的位置（时间）
        guard let dataCount = logTags.first?.values.count else {
            return
        }

        //将所有的值合并一个数值
        var totalValues: [Double] = []
        logTags.forEach {
            totalValues.append(contentsOf: $0.values)
        }
        //通讯失败点置-1，不能删除，需占位，方便推导最大/小值的index，进而算出时间
        let validValues = totalValues.filter { $0 != Tag.nilValue }

        //在validValues查找最大/最小值，在values查找最大/小值所处的位置
        if let max = validValues.max() {
            maxValueLabel.text = max.roundToPlaces().clean
            //因数据已合并，且保留所有点，可用求余得出位置
            let maxIndex = totalValues.firstIndex(of: max)! % dataCount
            maxTimeLabel.text = condition.getLongTimeString(with: maxIndex)
        }
        if let min = validValues.min() {
            minValueLabel.text = min.roundToPlaces().clean
            let minIndex = totalValues.firstIndex(of: min)! % dataCount
            minTimeLabel.text = condition.getLongTimeString(with: minIndex)
        }
        //计算平均值，忽略所有通讯无效点
        let avg = validValues.reduce(0, +) / Double(validValues.count)
        avgValueLabel.text = avg.roundToPlaces().clean
    }

    private func initViews() {

        minLabel.text = "min".localize(with: prefixTrend)
        minLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addSubview(minLabel)
        minLabel.leadingToSuperview(offset: edsSpace)
        minLabel.centerYToSuperview(offset: edsMinSpace)

        minValueLabel.text = "0"
        minValueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(minValueLabel)
        minValueLabel.leadingToSuperview(offset: edsSpace)
        minValueLabel.topToSuperview(offset: edsMinSpace)

        minTimeLabel.text = Date().toDateTimeString()
        minTimeLabel.textColor = edsGrayColor
        minTimeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        addSubview(minTimeLabel)
        minTimeLabel.topToBottom(of: minLabel, offset: 10)
        minTimeLabel.leadingToSuperview(offset: edsSpace)

        maxLabel.text = "max".localize(with: prefixTrend)
        maxLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addSubview(maxLabel)
        maxLabel.trailingToSuperview(offset: edsSpace)
        maxLabel.centerYToSuperview(offset: edsMinSpace)

        maxValueLabel.text = "100"
        maxValueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(maxValueLabel)
        maxValueLabel.trailingToSuperview(offset: edsSpace)
        maxValueLabel.topToSuperview(offset: edsMinSpace)

        maxTimeLabel.text = Date().toDateTimeString()
        maxTimeLabel.textColor = edsGrayColor
        maxTimeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        addSubview(maxTimeLabel)
        maxTimeLabel.topToBottom(of: minLabel, offset: 10)
        maxTimeLabel.trailingToSuperview(offset: edsSpace)

        avgLabel.text = "avg".localize(with: prefixTrend)
        avgLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        addSubview(avgLabel)
        avgLabel.centerXToSuperview()
        avgLabel.centerYToSuperview(offset: edsMinSpace)

        avgValueLabel.text = "50"
        avgValueLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        addSubview(avgValueLabel)
        avgValueLabel.centerXToSuperview()
        avgValueLabel.topToSuperview(offset: edsMinSpace)
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

        // Configure the view for the selected state
    }

    override func draw(_ rect: CGRect) {
        //绘黑线,在居中偏上的位置
        let yRatio: CGFloat = 0.4
        let radius: CGFloat = 6
        let start = CGPoint(x: edsSpace + radius, y: rect.height * yRatio)
        let end = CGPoint(x: rect.width - edsSpace, y: rect.height * yRatio)
        let center = CGPoint(x: rect.width / 2, y: rect.height * yRatio)

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


