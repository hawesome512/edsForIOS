//
//  DeviceLineChartCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Charts

class DeviceTrendChartCell: UITableViewCell {

    let lineChartView = LineChartView()
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    //横坐标基于时间选择条件
    private var condition: WATagLogRequestCondition?
    private var dateItem: EnergyDateItem?

    private func initViews() {

        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = true
        lineChartView.xAxis.gridLineDashLengths = [10, 10]
        lineChartView.xAxis.gridLineDashPhase = 0
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = .label
        lineChartView.leftAxis.labelTextColor = .label
        lineChartView.legend.textColor = .label

        let leftAxis = lineChartView.leftAxis
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true

        lineChartView.rightAxis.enabled = false

        let marker = BalloonMarker(color: .systemRed,
                                   font: .preferredFont(forTextStyle: .title3),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = lineChartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        lineChartView.marker = marker

        lineChartView.legend.form = .circle

        lineChartView.animate(xAxisDuration: 2.5)

        lineChartView.alpha = 0
        addSubview(lineChartView)
        lineChartView.edgesToSuperview()

        activityIndicatorView.startAnimating()
        addSubview(activityIndicatorView)
        activityIndicatorView.centerInSuperview()

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

    func setData(_ logTags: [(name: String, values: [Double])], condition: WATagLogRequestCondition?, upper: Double?, lower: Double?) {
        lineChartView.leftAxis.removeAllLimitLines()
        if let upper = upper {
            let upperLimit = ChartLimitLine(limit: upper)
            upperLimit.lineColor = .systemRed
            upperLimit.lineDashLengths = [10, 10]
            lineChartView.leftAxis.addLimitLine(upperLimit)
        }
        if let lower = lower {
            let lowerLimit = ChartLimitLine(limit: lower)
            lowerLimit.lineColor = .systemYellow
            lowerLimit.lineDashLengths = [10, 10]
            lineChartView.leftAxis.addLimitLine(lowerLimit)
        }
        self.condition = condition
        lineChartView.xAxis.valueFormatter = self
        setData(logTags)
    }

    func setData(_ logTags: [(name: String, values: [Double])], condition: WATagLogRequestCondition?) {
        //横坐标时间格式
        self.condition = condition
        lineChartView.xAxis.valueFormatter = self
        setData(logTags)
    }

    func setData(_ logTags: [(name: String, values: [Double])], dateItem: EnergyDateItem) {
        self.dateItem = dateItem
        lineChartView.xAxis.valueFormatter = self
        setData(logTags)
    }

    func setData(_ logTags: [(name: String, values: [Double])]) {
        lineChartView.highlightValue(nil, callDelegate: false)
        UIView.animate(withDuration: 0.5, animations: {
            self.activityIndicatorView.alpha = 0
            self.lineChartView.alpha = 1
        })

        lineChartView.data?.clearValues()
        var datas: [LineChartDataSet] = []
        //调色板
        let colors = ChartColorTemplates.material()
        logTags.forEach { logTag in

            let chartValues = logTag.values.enumerated().map {
                //离线点置-1处理,取至多1位精度
                return ChartDataEntry(x: Double($0.offset), y: $0.element.roundToPlaces(places: 1))
            }
            let set = LineChartDataSet(entries: chartValues, label: logTag.name)
            set.drawValuesEnabled = false
            set.drawCirclesEnabled = false
            //顺序取出调色板颜色
            let color = colors[datas.count % colors.count]
            set.setColor(color)
            set.lineWidth = 2
            //线段太多，不再绘制小圆点
            set.drawCirclesEnabled = logTags.count == 1 ? true : false
            set.circleColors = [color]
            set.circleRadius = 4
            datas.append(set)
        }
        //只有一条线时，填充渐变色块
        if datas.count == 1 {
            let gradientColors = [colors[0].withAlphaComponent(0).cgColor,
                colors[0].withAlphaComponent(1).cgColor]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

            datas[0].fillAlpha = 1
            datas[0].fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
            datas[0].drawFilledEnabled = true
        }

        let data = LineChartData(dataSets: datas)
        lineChartView.data = data
    }


    func prepareRequestData() {
        UIView.animate(withDuration: 0.5, animations: {
            self.activityIndicatorView.alpha = 1
            self.lineChartView.alpha = 0
        })
    }

}

extension DeviceTrendChartCell: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        if let dateItem = dateItem {
            return dateItem.getShortTimeString(with: index)
        }
        if let condition = condition {
            return condition.getShortTimeString(with: index)
        }
        return value.clean
    }


}
