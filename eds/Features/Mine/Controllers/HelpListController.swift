//
//  HelpListController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/5.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import Foundation

class HelpListController: UITableViewController {

    private let disposeBag = DisposeBag()

    var helpList = [Help]()
    var searchHelpList = [Help]()
    var searchVC = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchVC.searchBar
        tableView.tableFooterView = UIView()
        tableView.register(HelpCell.self, forCellReuseIdentifier: String(describing: HelpCell.self))
        EDSResourceUtility.sharedInstance.loadHelpList()
        EDSResourceUtility.sharedInstance.successfulLoadedHelpList.bind(onNext: { loaded in
            if loaded {
                DispatchQueue.main.async {
                    self.helpList = EDSResourceUtility.sharedInstance.helpList
                    self.tableView.reloadData()
                }
            }
        }).disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchVC.isActive ? searchHelpList.count : helpList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HelpCell.self), for: indexPath) as! HelpCell
        cell.help = searchVC.isActive ? searchHelpList[indexPath.row] : helpList[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let help = searchVC.isActive ? searchHelpList[indexPath.row] : helpList[indexPath.row]
        ShareUtility.openWeb(help.name.getEDSServletHelpURL())
    }

}

extension HelpListController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            searchHelpList = helpList.filter { $0.name.contains(searchText) }
            tableView.reloadData()
        }
    }


}
