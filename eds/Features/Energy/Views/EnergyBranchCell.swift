//
//  EnergyBranchCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Charts
import RxSwift

class EnergyBranchCell: UITableViewCell {
    private let disposeBag=DisposeBag()

    var barChartView: BarChartView = BarChartView()
    
    var parentVC:UIViewController?

    func setEnergyData(_ branch: EnergyBranch) {
        var xItems = [String]()
        var values = [Double]()
        guard let total = branch.energyData?.getCurrentTotalValue(), total > 0 else {
            return
        }
        for element in branch.branches {
            xItems.append(element.title)
            let value = element.energyData?.getCurrentTotalValue() ?? 0
            values.append(Double(value / total * 100).roundToPlaces(fractions: 0))
        }
        barChartView.xAxis.valueFormatter = BarAxisFormatter(items: xItems)
        barChartView.xAxis.labelCount = xItems.count
        setData(values: values)
    }

    private func setData(values: [Double]) {
        guard values.count > 0 else {
            return
        }
        //[values]->[(index,value)]
        let entries = values.enumerated().map {
            BarChartDataEntry(x: Double($0.offset), y: $0.element)
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        let branchIcon = UIImageView()
        branchIcon.tintColor = .label
        branchIcon.image = UIImage(named: "branch")?.withRenderingMode(.alwaysTemplate)
        addSubview(branchIcon)
        branchIcon.width(edsIconSize)
        branchIcon.height(edsIconSize)
        branchIcon.leadingToSuperview(offset: edsSpace)
        branchIcon.topToSuperview(offset: edsMinSpace)

        let branchLabel = UILabel()
        let title = "branch".localize(with: prefixEnergy)
        branchLabel.text = title
        branchLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        addSubview(branchLabel)
        branchLabel.leadingToTrailing(of: branchIcon, offset: edsMinSpace)
        branchLabel.centerY(to: branchIcon)
        
        let tipButton = UIButton()
        tipButton.tintColor = .systemGray3
        tipButton.setBackgroundImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        tipButton.rx.tap.bind(onNext: {
            let message = "branch_alert".localize(with: prefixEnergy)
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok".localize(), style: .cancel, handler: nil)
            alertVC.addAction(okAction)
            self.parentVC?.present(alertVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        addSubview(tipButton)
        tipButton.width(edsSpace)
        tipButton.height(edsSpace)
        tipButton.leadingToTrailing(of: branchLabel, offset: 2)
        tipButton.centerY(to: branchIcon, offset: -6)

        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false
        //value绘制在柱状图里面，默认在上方
        barChartView.drawValueAboveBarEnabled = false
        barChartView.isUserInteractionEnabled = true
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = 100
        barChartView.leftAxis.labelTextColor = .label
        barChartView.xAxis.labelTextColor = .label
        //横坐标间隔尺寸granularity=1
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.granularity = 1
        xAxis.labelFont = UIFont.preferredFont(forTextStyle: .body)
        addSubview(barChartView)
        barChartView.edgesToSuperview(excluding: .top, insets: .uniform(edsMinSpace))
        barChartView.height(180)
        barChartView.topToBottom(of: branchIcon, offset: edsMinSpace)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
