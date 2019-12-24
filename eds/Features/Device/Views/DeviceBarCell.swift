//
//  DeviceBarCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/11.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device柱状图:init＞setPreferredStyle>values(setData)

import UIKit
import Charts

class DeviceBarCell: UITableViewCell {

    private let space: CGFloat = 20
    private var barChartView: BarChartView!

    //更新数据
    var values: [Double] = [] {
        didSet {
            setData()
        }
    }

    fileprivate func initViews() {
        barChartView = BarChartView()
        addSubview(barChartView)

        barChartView.translatesAutoresizingMaskIntoConstraints = false
        let superView = barChartView.superview!
        //右和底边约束为负数才表示缩进
        NSLayoutConstraint.activate([
            barChartView.topAnchor.constraint(equalTo: superView.topAnchor, constant: space),
            barChartView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -space),
            barChartView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: space),
            barChartView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -space)
        ])
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
        setDefaultStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setDefaultStyle() {

        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false
        //value绘制在柱状图里面，默认在上方
        barChartView.drawValueAboveBarEnabled = false
        barChartView.isUserInteractionEnabled = false

        //横坐标间隔尺寸granularity=1
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1
        xAxis.labelFont = UIFont.preferredFont(forTextStyle: .body)

    }

    /// 设置样式
    /// - Parameters:
    ///   - xItems: 横坐标列表
    ///   - yMax: 纵坐标最大值
    ///   - yMin: 纵坐标最小值
    ///   - yLabelCount: 纵坐标间隔数
    ///   - yUpper: 警戒线
    ///   - yLower: 警戒线
    func setPreferredStyle(xItems: [String]? = ["A", "B", "C"], yMax: Double? = 120, yMin: Double? = 0, yLabelCount: Int? = 4, yUpper: Double?, yLower: Double?) {

        barChartView.xAxis.valueFormatter = BarAxisFormatter(items: xItems!)
        barChartView.xAxis.labelCount = xItems!.count

        let leftAxis = barChartView.leftAxis
        leftAxis.labelFont = UIFont.preferredFont(forTextStyle: .caption1)
        leftAxis.labelCount = yLabelCount!
        leftAxis.axisMaximum = yMax!
        leftAxis.axisMinimum = yMin!
        leftAxis.drawLimitLinesBehindDataEnabled = true

        if let upper = yUpper {
            let upperLine = ChartLimitLine(limit: upper)
            upperLine.lineColor = UIColor.systemRed
            upperLine.lineDashLengths = [10, 10]
            leftAxis.addLimitLine(upperLine)
        }

        if let lower = yLower {
            let lowerLine = ChartLimitLine(limit: lower)
            lowerLine.lineColor = UIColor.systemYellow
            lowerLine.lineDashLengths = [10, 10]
            lowerLine.lineWidth=2
            leftAxis.addLimitLine(lowerLine)
        }
    }

    private func setData() {
        //[values]->[(index,value)]
        let entries = values.enumerated().map {
            BarChartDataEntry(x: Double($0.offset), y: $0.element)
        }
        if let set = barChartView.data?.dataSets.first as? BarChartDataSet {
            //更新
            set.replaceEntries(entries)
            barChartView.data?.notifyDataChanged()
            barChartView.notifyDataSetChanged()
        } else {
            //初次
            let set = BarChartDataSet(entries: entries)
            set.colors = ChartColorTemplates.material()
            let data = BarChartData(dataSet: set)
            data.barWidth = 0.8
            data.setValueTextColor(UIColor.white)
            data.setValueFont(UIFont.preferredFont(forTextStyle: .body))
            barChartView.data = data

        }
    }

}

class BarAxisFormatter: IAxisValueFormatter {

    var items: [String]

    init(items: [String]) {
        self.items = items
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return items[Int(value)]
    }

}
