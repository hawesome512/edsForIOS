//
//  DevicePageItemSource.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/31.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import Foundation

/// Device Page Table View Cell统一实现此实例，生成界面
protocol DevicePageItemSource {
    func initViews(with pageItem: DevicePageItem, rx tags: [Tag], rowIndex: Int)
    func getNumerOfRows(with pageItem: DevicePageItem) -> Int
}
