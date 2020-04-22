//
//  EnergyController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import SwiftDate
import Moya
import Charts

class EnergyController: UITableViewController {

    var cells = EnergyCellType.getAllCells()
    var energyBranch: EnergyBranch? {
        didSet {
            guard let branch = self.energyBranch, let data = branch.energyData else {
                return
            }
            //如果支路没有值，请求数据
            if branch.branches.count > 0 && branch.branches[0].energyData == nil {
                pick(dateItem: data.dateItem)
                return
            }
            title = self.energyBranch?.title
            let chartCell = cells[.chart] as! DeviceTrendChartCell
            let analysisCell = cells[.analysis] as! DeviceTrendAnalysisCell
            let ratioCell = cells[.ratio] as! EnergyRatioCell
            let timeCell = cells[.time] as! EnergyTimeCell
            let branchCell = cells[.branch] as! EnergyBranchCell
            chartCell.setData(data.chartValues, dateItem: data.dateItem)
            analysisCell.setEnergyData(data.getCurrentValues(), date: data.dateItem)
            ratioCell.setData(data: data)
            timeCell.setData(data)
            branchCell.setEnergyData(branch)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        tableView.allowsSelection = false
        let branchBUtton = UIBarButtonItem(image: UIImage(named: "branch"), style: .plain, target: self, action: #selector(editBranch))
        navigationItem.rightBarButtonItem = branchBUtton
    }

    @objc func editBranch() {

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //若没有支路，则不没有支路占比cell
        let branchCount = energyBranch?.branches.count ?? 0
        return branchCount == 0 ? cells.count - 1: cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = EnergyCellType.init(rawValue: indexPath.row)!
        switch cellType {
        case .segment:
            let cell = cells[cellType]! as! EnergySegmentCell
            cell.dateItem = energyBranch?.energyData?.dateItem
            cell.delegate = self
            return cell
        case .chart:
            let cell = cells[cellType]! as! DeviceTrendChartCell
            return cell
        case .ratio:
            let cell = cells[cellType]! as! EnergyRatioCell
            return cell
        case .analysis:
            let cell = cells[cellType]! as! DeviceTrendAnalysisCell
            return cell
        case .time:
            let cell = cells[cellType]! as! EnergyTimeCell
            cell.parentVC = self
            return cell
        case .branch:
            let cell = cells[cellType]! as! EnergyBranchCell
            cell.barChartView.delegate = self
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = EnergyCellType.init(rawValue: indexPath.row)!
        switch cellType {
        case .chart:
            let screenHeight = UIScreen.main.bounds.height
            let height = (traitCollection.verticalSizeClass == .regular) ? screenHeight * 0.3 : screenHeight * 0.8
            return max(height, 240)
        case .analysis:
            return 120
        default:
            return tableView.estimatedRowHeight
        }
    }
}

extension EnergyController: DateSegmentDelegate, ChartViewDelegate {

    //选择能耗日期模式
    func pick(dateItem: EnergyDateItem) {

        guard let branch = energyBranch else {
            return
        }

        (cells[.chart] as! DeviceTrendChartCell).prepareRequestData()

        let authority = User.tempInstance.authority!
        let condition = dateItem.getLogRequestCondition(with: branch.getLogTags())
        MoyaProvider<WAService>().request(.getTagLog(authority: authority, condition: condition)) { result in
            switch result {
            case .success(let response):
                let results = JsonUtility.getTagLogValues(data: response.data) ?? []
                self.energyBranch = EnergyUtility.updateBranchData(in: branch, with: results, dateItem: dateItem)
                break
            default:
                break
            }
        }
    }

    //选择支路
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //取消高亮
        chartView.highlightValue(nil, callDelegate: false)
        let branchIndex = Int(entry.x)
        let branchVC = EnergyController()
        branchVC.energyBranch = energyBranch?.branches[branchIndex]
        navigationController?.pushViewController(branchVC, animated: true)
    }

}
