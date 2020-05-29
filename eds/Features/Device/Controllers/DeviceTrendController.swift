//
//  DeviceListTrendTableViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya
import SwiftDate

class DeviceTrendController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    private let chartCell = DeviceTrendChartCell(style: .default, reuseIdentifier: nil)
    private let analysisCell = DeviceTrendAnalysisCell(style: .default, reuseIdentifier: nil)
    private let evaluationCell = DeviceTrendEvaluationCell(style: .default, reuseIdentifier: nil)
    private let tableView=UITableView()
    private var tags:[Tag]=[]
    private var isAccumulated=false
    private let timeItems=["start_time".localize(with: prefixWorkorder),"end_time".localize(with: prefixWorkorder)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //空行隐藏分割线
        title="title".localize(with: prefixTrend)
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.dataSource=self
        tableView.delegate=self
        view=tableView
        navigationItem.rightBarButtonItem=UIBarButtonItem(image: UIImage(systemName: "clock"), style: .plain, target: self, action: #selector(setCondition))
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // chart,analysis,evaluation
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return chartCell
        case 1:
            return analysisCell
        default:
            return evaluationCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            
            if isAccumulation {
                //返回累加值被处理后的值
                let tranValues = BasicUtility.filterAccumulatedValues(values: values)
                return result.append((source.getTagShortName(), tranValues))
            } else {
                let doubleValues = values.map { Double($0) ?? Tag.nilValue }
                return result.append((source.getTagShortName(), doubleValues))
            }
        }
        return result
    }
    
}

extension DeviceTrendController:PickerDelegate{
    
    
    /// 趋势设置
    /// - Parameters:
    ///   - tags: 需要查询的数据点
    ///   - condition: 查询条件
    ///   - isAccumulated: 是否是累加值，累加值递减处理相邻数据点
    ///   - upperLimit: 安全上限
    ///   - lowerLimit: 安全下限
    func trend(with tags: [Tag], condition: WATagLogRequestCondition?, isAccumulated: Bool, upperLimit: Double? = nil, lowerLimit: Double? = nil) {
        self.tags=tags
        self.isAccumulated=isAccumulated
        let logCondition = condition ?? WATagLogRequestCondition.defaultCondition(with: tags, isAccumulated: isAccumulated)
        requestData(condition: logCondition, upperLimit: upperLimit, lowerLimit: lowerLimit)
    }
    
    func requestData(condition:WATagLogRequestCondition,upperLimit: Double? = nil, lowerLimit: Double? = nil){
        guard let authority = AccountUtility.sharedInstance.account?.authority else {
            return
        }
        WAService.getProvider().request(.getTagLog(authority: authority, condition: condition)) { result in
            switch result {
            case .success(let response):
                let logs = JsonUtility.getTagLogValues(data: response.data)
                guard let validLogs = logs, validLogs.count > 0 else {
                    return
                }
                let tranformLogs = self.tranformData(sources: logs, isAccumulation: self.isAccumulated)
                self.chartCell.setData(tranformLogs, condition: condition, upper: upperLimit, lower: lowerLimit)
                self.analysisCell.setData(tranformLogs, condition: condition)
                self.evaluationCell.setData(tranformLogs, upper: upperLimit, lower: lowerLimit)
            default:
                break
            }
        }
    }
    
    func picked(results: [Date]) {
        let start=DateInRegion(results[0], region: .current)
        let end=DateInRegion(results[1], region: .current)
        guard let delta=(end-start).toUnit(.second),delta>0 else {
            let startText="\(timeItems[0]):\(results[0].toDateTimeString())"
            let endText="\(timeItems[1]):\(results[1].toDateTimeString())"
            let content=String(format: "time_alert".localize(with: prefixTrend), startText,endText)
            ControllerUtility.presentAlertController(content: content, controller: self)
            return
        }
        var intervalType=LogIntervalType.S
        var interval=1
        var records=1
        switch delta {
        case 0...60:
            //1minute
            intervalType = LogIntervalType.S
            interval=1
            records=delta
        case 61...300:
            //5minute
            intervalType = LogIntervalType.S
            interval=5
            records=delta/5
        case 301...600:
            //10minute
            intervalType = LogIntervalType.S
            interval=10
            records=delta/10
        case 601...3600:
            //1hour
            intervalType = LogIntervalType.M
            interval=1
            records=delta/60
        case 3601...18000:
            //5hour
            intervalType = LogIntervalType.M
            interval=5
            records=delta/60/5
        case 18001...36000:
            //10hour
            intervalType = LogIntervalType.M
            interval=10
            records=delta/60/10
        case 36001...86400:
            //1day
            intervalType = LogIntervalType.H
            interval=1
            records=delta/60/60
        default:
            //>1day
            intervalType = LogIntervalType.D
            interval=1
            //限制查询的资料笔数
            records=max(delta/60/60/24,60)
        }
        let dataType: LogDataType = isAccumulated ? .Last : .Avg
        let logTags = tags.map { LogTag(name: $0.Name, logDataType: dataType) }
        let startTime=results[0].toDateTimeString()
        let condition=WATagLogRequestCondition(startTime: startTime, intervalType: intervalType, interval: interval, records: records, tags: logTags)
        
        chartCell.prepareRequestData()
        requestData(condition: condition)
    }
    
    func pickerCanceled() {
        
    }
    
    
    @objc func setCondition(){
        let pickerVC=DatePickerController()
        pickerVC.picker.datePickerMode = .dateAndTime
        pickerVC.delegate=self
        pickerVC.dateLimit = .before
        pickerVC.items=timeItems
        present(pickerVC, animated: true, completion: nil)
    }
    
}
