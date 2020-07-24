//
//  DeviceBarCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/11.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device柱状图:init＞setPreferredStyle>values(setData)
//  为简化显示效果，不显示数值小数部分

import UIKit
import Charts
import RxSwift

class DeviceBarCell: UITableViewCell {

    private var barChartView: BarChartView!
    private let disposeBag = DisposeBag()
    //传递给DeviceTrendViewController，标题和记录点
    private var barTags: [Tag] = []
    private var isAccumulated = false

    var parentVC: UIViewController?

    fileprivate func initViews() {
        barChartView = BarChartView()
        addSubview(barChartView)
        barChartView.edgesToSuperview(insets: .uniform(edsSpace))
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
        barChartView.leftAxis.labelTextColor = .label
        barChartView.xAxis.labelTextColor = .label

        //横坐标间隔尺寸granularity=1
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1
        xAxis.labelFont = UIFont.preferredFont(forTextStyle: .body)

    }

    /// 设置样式
    /// - Parameters:
    ///   - xItems: 横坐标列表
    ///   - yItems: e.g.:["0","green","50","red","100"]
    private func setPreferredStyle(_ pageItem: DevicePageItem) {
        let xItems = pageItem.tags
        let yItems = pageItem.items

        barChartView.xAxis.valueFormatter = BarAxisFormatter(items: xItems)
        barChartView.xAxis.labelCount = xItems.count

        let leftAxis = barChartView.leftAxis
        leftAxis.labelFont = UIFont.preferredFont(forTextStyle: .caption1)
        leftAxis.drawLimitLinesBehindDataEnabled = true
        leftAxis.labelCount = 4
        //三种：直接显示（无unit和items),设定最大值（有unit,无items),百分比（有unit,有items)
        if let yItems = yItems, yItems.count > 0 {
            leftAxis.axisMaximum = Double(yItems.last!) ?? 100
            leftAxis.axisMinimum = Double(yItems.first!) ?? 0
            for index in stride(from: 2, to: yItems.count - 1, by: 2) {
                let line = ChartLimitLine(limit: Double(yItems[index]) ?? 0)
                line.lineColor = UIColor(colorName: yItems[index + 1])
                line.lineDashLengths = [10, 10]
                leftAxis.addLimitLine(line)
            }
        } else if let unit = pageItem.unit {
            let unitTag = TagUtility.sharedInstance.getRelatedTag(with: unit, related: barTags[0])
            leftAxis.axisMaximum = Double(unitTag?.Value ?? "1") ?? 100
            leftAxis.axisMinimum = 0
        } else {
            //若未设置，y起始值将随着valus变动
            leftAxis.axisMinimum = 0
        }
    }


    /// 更新数据
    /// - Parameter values: <#values description#>
    private func setData(values: [Double]) {
        guard values.count > 0 else {
            return
        }
        //[values]->[(index,value)],暂定不显示小数，取整
        let entries = values.enumerated().map {
            BarChartDataEntry(x: Double($0.offset), y: $0.element.autoRounded())
        }
        //values太小时，若在柱状图下面绘制将遮挡xAxis的Labels
        let drawValueAbove = values.max()! <= barChartView.leftAxis.axisMaximum * 0.15
        barChartView.drawValueAboveBarEnabled = drawValueAbove
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard selected else {
            return
        }
        let trendViewController = DeviceTrendController()
        trendViewController.trend(with: barTags, condition: nil, isAccumulated: isAccumulated)
        parentVC?.navigationController?.pushViewController(trendViewController, animated: true)

    }

}

extension DeviceBarCell: DevicePageItemSource {
    func getNumerOfRows(with pageItem: DevicePageItem) -> Int {
        return 1
    }

    func initViews(with pageItem: DevicePageItem, rx tags: [Tag], rowIndex: Int) {
        barTags = tags
        if pageItem.items?.first == DeviceModel.itemsAccumulation {
            isAccumulated = true
        }
        setPreferredStyle(pageItem)
        Observable.combineLatest(tags.map { $0.showValue.asObservable() }).throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
            guard let unit = pageItem.unit, tags.count > 0, let items = pageItem.items, items.count > 0 else {
                self.setData(values: $0)
                return
            }
            //需换算，用百分比表示
            let unitTag = TagUtility.sharedInstance.getRelatedTag(with: unit, related: tags[0])
            let ratio = Double(unitTag?.Value ?? "1") ?? 1
            self.setData(values: $0.map { value in
                return value / ratio * 100
            })
        }).disposed(by: disposeBag)
    }
}

class BarAxisFormatter: IAxisValueFormatter {

    var items: [String]

    init(items: [String]) {
        self.items = items
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return items[Int(value)].localize()
    }
}

