//
//  EnergyRankController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/7/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class EnergyRankController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    private let cellID = "cell"
    private var rankDataList: [RankData] = []
    private let indicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "rank".localize(with: prefixEnergy)
        tableView.addSubview(indicator)
        indicator.topToSuperview(offset: edsMinSpace)
        indicator.centerXToSuperview()
        indicator.color = .systemRed
        indicator.startAnimating()
        tableView.tableFooterView = UIView()
        tableView.register(RankCell.self, forCellReuseIdentifier: cellID)
        EnergyUtility.sharedInstance.loadAccountsEnergyData()
        EnergyUtility.sharedInstance.successfulAccountsUpdated.asObservable().bind(onNext: { updated in
            guard updated else { return }
            self.initViews()
        }).disposed(by: disposeBag)
    }
    
    func initViews() {
        indicator.alpha = 0
        rankDataList.removeAll()
        let branches = EnergyUtility.sharedInstance.accountEnergyBranchList
        let basicList = BasicUtility.sharedInstance.accountBasicList
        let energyList = EnergyUtility.sharedInstance.accountEnergyList
        branches.enumerated().forEach{ (index,item) in
            var rankData = RankData()
            rankData.account = basicList[index].user
            rankData.setScore(energy: energyList[index], data: branches[index]?.energyData)
            self.rankDataList.append(rankData)
        }
        rankDataList.sort()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rankDataList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! RankCell
        cell.initView(of: indexPath.row)
        cell.rankData = rankDataList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
