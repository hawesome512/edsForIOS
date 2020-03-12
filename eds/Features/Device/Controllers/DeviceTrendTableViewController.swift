//
//  DeviceListTrendTableViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya

class DeviceTrendTableViewController: UITableViewController {


    /// 趋势设置
    /// - Parameters:
    ///   - tags: 需要查询的数据点
    ///   - condition: 查询条件
    ///   - isAccumulated: 是否是累加值，累加值递减处理相邻数据点
    ///   - upperLimit: 安全上限
    ///   - lowerLimit: 安全下限
    func trend(with tags: [Tag], condition: WATagLogRequestCondition?, isAccumulated: Bool, upperLimit: Double? = nil, lowerLimit: Double? = nil) {

        let logCondition = condition ?? WATagLogRequestCondition.defaultCondition(with: tags, isAccumulated: isAccumulated)
        MoyaProvider<WAService>().request(.getTagLog(authority: User.tempInstance.authority!, condition: logCondition)) { result in
            switch result {
            case .success(let response):
                let logs = JsonUtility.getTagLogValues(data: response.data)
                guard let validLogs = logs, validLogs.count > 0 else {
                    return
                }
                let tranformLogs = self.tranformData(sources: logs, isAccumulation: isAccumulated)
                self.chartCell.setData(tranformLogs, condition: logCondition, upper: upperLimit, lower: lowerLimit)
                self.analysisCell.setData(tranformLogs, condition: logCondition)
                self.evaluationCell.setData(tranformLogs, upper: upperLimit, lower: lowerLimit)
            default:
                break
            }
        }
    }

    private let chartCell = DeviceTrendChartCell(style: .default, reuseIdentifier: nil)
    private let analysisCell = DeviceTrendAnalysisCell(style: .default, reuseIdentifier: nil)
    private let evaluationCell = DeviceTrendEvaluationCell(style: .default, reuseIdentifier: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        //空行隐藏分割线
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // chart,analysis,evaluation
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return chartCell
        case 1:
            return analysisCell
        default:
            return evaluationCell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //竖屏为标准尺寸时：chart 布满剩余屏幕，analysis和evaluetion各占120
        let height = tableView.bounds.height - ViewUtility.calStatusAndNavBarHeight(in: self)
        let heightRegular = traitCollection.verticalSizeClass == .regular
        switch indexPath.row {
        case 0:
            return heightRegular ? height - 120 * 2: height
        default:
            return 120
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func tranformData(sources: [LogTag?]?, isAccumulation: Bool) -> [(name: String, values: [Double])] {
        guard let sources = sources else {
            return []
        }
        var result: [(name: String, values: [Double])] = []
        sources.forEach {
            guard let source = $0, let values = source.Values else {
                return
            }
            //处理通讯无效点
            let doubleValues = values.map { Double($0) ?? Tag.nilValue }

            if isAccumulation {
                //处理累加的情况，重点处理通讯无效点
                var tranValues: [Double] = []
                var tempValid = doubleValues[0]
                //处理累加，从第1个开始[1]-[0]
                for index in 1..<doubleValues.count {
                    let now = doubleValues[index]
                    if tempValid == Tag.nilValue || now == Tag.nilValue {
                        tranValues.append(Tag.nilValue)
                    } else {
                        tranValues.append(now - tempValid)
                        tempValid = now
                    }
                }
                //返回累加值被处理后的值
                return result.append((source.getTagShortName(), tranValues))
            } else {
                return result.append((source.getTagShortName(), doubleValues))
            }
        }
        return result
    }

}
