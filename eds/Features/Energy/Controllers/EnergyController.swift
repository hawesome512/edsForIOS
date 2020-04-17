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

class EnergyController: UITableViewController {

    var cells = EnergyCellType.getAllCells()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = EnergyCellType.init(rawValue: indexPath.row)!
        switch cellType {
        case .segment:
            let cell = cells[cellType]! as! EnergySegmentCell
            cell.delegate = self
            cell.selectRecentDate()
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
            return cell
        case .branch:
            let cell = cells[cellType]! as! DeviceBarCell
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
        case .branch:
            return 160
        default:
            return tableView.estimatedRowHeight
        }
    }
}

extension EnergyController: DateSegmentDelegate {

    //选择能耗日期模式
    func pick(dateItem: EnergyDateItem) {

        let chartCell = cells[.chart] as! DeviceTrendChartCell
        chartCell.prepareRequestData()
        let analysisCell = cells[.analysis] as! DeviceTrendAnalysisCell
        let ratioCell = cells[.ratio] as! EnergyRatioCell

        let authority = User.tempInstance.authority!
        let tag = LogTag(name: "XS_A3_1:EP", logDataType: .Last)
        let condition = dateItem.getLogRequestCondition(with: [tag])
        MoyaProvider<WAService>().request(.getTagLog(authority: authority, condition: condition)) { result in
            switch result {
            case .success(let response):
                let results = JsonUtility.getTagLogValues(data: response.data) ?? []
                guard let values = results.first??.Values else {
                    return
                }
                let energyData = EnergyUtility.getEnergyData(with: values, dateItem: dateItem)
                chartCell.setData(energyData.chartValues, dateItem: dateItem)
                analysisCell.setEnergyData(energyData.getCurrentValues(), date: dateItem)
                ratioCell.setData(data: energyData)
                break
            default:
                break
            }
        }
    }


}
