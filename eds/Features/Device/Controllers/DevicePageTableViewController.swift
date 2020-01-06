//
//  DevicePageTableViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/27.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  设备的每一个子页面，都是tableview controller：纵览，实时，参数，控制，关于……

import UIKit


/// TableView实现UIScrollViewDelegate，滚动时触发父级DeviceVC.headerView上下偏移
protocol DevicePageScrollDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class DevicePageTableViewController: UITableViewController {

    var scrollDelegate: DevicePageScrollDelegate?

    //设备子页面配置模型
    func set(with pageModel: DevicePage, in deviceName: String) {
        self.pageModel = pageModel
        self.deviceName = deviceName
        title = pageModel.title
    }

    private var pageModel: DevicePage?
    private var deviceName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        //设置FooterView,tableView中空行不显示分割线
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return pageModel?.content.count ?? 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let pageItem = pageModel!.content[section]
        if let section = pageItem.section {
            return section.localize(with: prefixDevice)
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let pageItem = pageModel!.content[section]
        //默认使用list
        let cellType = DeviceCellType(rawValue: pageItem.display) ?? DeviceCellType.list
        return (cellType.getTableCell() as! DevicePageItemSource).getNumerOfRows(with: pageItem)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pageItem = pageModel!.content[indexPath.section]
        //默认使用list
        let cellType = DeviceCellType(rawValue: pageItem.display) ?? DeviceCellType.list
        //不使用tableview.deusea...,rxswift订阅容易出现混乱,如A cell的pageItem被N cell使用了
        let cell = cellType.getTableCell()
        let tags = TagUtility.sharedInstance.getTagList(by: pageItem.tags, in: deviceName)
        (cell as? DevicePageItemSource)?.initViews(with: pageItem, rx: tags, rowIndex: indexPath.row)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //根据DeviceCellType设定行高
        let pageItem = pageModel!.content[indexPath.section]
        //默认使用list
        let cellType = DeviceCellType(rawValue: pageItem.display) ?? DeviceCellType.list
        let heights = cellType.getRowHeight()
        return max(heights.ratio * tableView.frame.height, heights.min)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


        tableView.deselectRow(at: indexPath, animated: false)
    }


    // MARK: - Device Page Scroll Delegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //触发父级header view上下偏移
        scrollDelegate?.scrollViewDidScroll(tableView)
    }

}
