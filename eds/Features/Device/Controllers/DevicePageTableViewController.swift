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
    var pageModel: DevicePage? {
        didSet {
            //添加标题，在父级Parment page controller的tab中显示
            title = pageModel?.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }


    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //触发父级header view上下偏移
        scrollDelegate?.scrollViewDidScroll(tableView)
    }

}
