//
//  DeviceListEvaluationCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  运行趋势评估模型：三种评估结果（≧80优/≧60良/差）
//  1⃣️波动（30%）：avg±10%方位内数值占比
//  2⃣️通讯（30%）：通讯无效点数占比
//  3⃣️超值（40%）：只要存在一个超值点就置0，只有40%/0两个选择，只要有一个超值点，整体评估就将为差

import UIKit
import TinyConstraints

class DeviceTrendEvaluationCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let stableLabel = RoundLabel()
    private let communicationLabel = RoundLabel()
    private let overflowLabel = RoundLabel()
    private let evaluationLabel = UILabel()

    func setData(_ logTags: [(name: String, values: [Double])]) {

        //将所有的值合并一个数值
        var totalValues: [Double] = []
        logTags.forEach {
            totalValues.append(contentsOf: $0.values)
        }
        //计算平均值，忽略所有通讯无效点
        let validValues = totalValues.filter { $0 != Tag.nilValue }

        //有效点值笔数/所有点的笔数
        let communicationRatio = Double(validValues.count) / Double(totalValues.count)
        let communication = TrendFactor.communication(ratio: communicationRatio)
        communicationLabel.backgroundColor = TrendEvaluation.initWith(value: communicationRatio).getItemColor()

        //正常合理值
        let overflowRatio = 1.0
        let overflow = TrendFactor.overflow(ratio: overflowRatio)
        overflowLabel.backgroundColor = TrendEvaluation.initWith(value: overflowRatio).getItemColor()

        //avgs±10%范围内的笔数
        let avg = validValues.reduce(0, +) / Double(validValues.count)
        let rangeValues = validValues.filter { $0 >= avg * 0.9 && $0 <= avg * 1.1 }
        let stableRatio = Double(rangeValues.count) / Double(validValues.count)
        let stable = TrendFactor.stable(ratio: stableRatio)
        stableLabel.backgroundColor = TrendEvaluation.initWith(value: stableRatio).getItemColor()

        //综合评估
        let total = communication.evaluate() + overflow.evaluate() + stable.evaluate()
        let totalTrend = TrendEvaluation.initWith(value: total)
        evaluationLabel.text = "\(totalTrend)".localize(with: prefixTrend)
        evaluationLabel.textColor = totalTrend.getTotalColor()
    }

    private func initViews() {

        titleLabel.text = "evaluation".localize(with: prefixTrend)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        addSubview(titleLabel)
        titleLabel.topToSuperview(offset: edsSpace)
        titleLabel.leadingToSuperview(offset: edsSpace)

        addItem(with: stableLabel, text: "stable", leading: nil)

        addItem(with: communicationLabel, text: "communication", leading: stableLabel)

        addItem(with: overflowLabel, text: "overflow", leading: communicationLabel)

        evaluationLabel.textColor = .systemGreen
        evaluationLabel.font = UIFont.boldSystemFont(ofSize: 50)
        addSubview(evaluationLabel)
        evaluationLabel.centerY(to: titleLabel)
        evaluationLabel.trailingToSuperview(offset: edsSpace)
    }

    private func addItem(with label: RoundLabel, text: String, leading: Constrainable?) {
        label.innerText = text.localize(with: prefixTrend)
        label.textColor = .white
        //子项，设置透明度，在显示红色背景时不至于太显眼
        label.alpha = 0.7
//        label.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        addSubview(label)
        label.topToBottom(of: titleLabel, offset: edsSpace)
        if let leading = leading {
            label.leadingToTrailing(of: leading, offset: edsSpace / 2)
        } else {
            label.leadingToSuperview(offset: edsSpace)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
