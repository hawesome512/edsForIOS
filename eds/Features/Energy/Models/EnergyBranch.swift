//
//  EnergyBranch.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/21.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  用电支路：
//  默认最顶级为系统工程级，无绑定监控节点
//  若只有一个支路，用支路代替当前级

import Foundation

class EnergyBranch: Equatable {

    static let tagName = "EP"
    static let itemSeparator = ";"
    static let branchSeparator = "/"
    static let branchLimit = 10
    //为避免系统复杂，支路不应超过3级，即id.count≦limit，公司、厂区、部门
    static let levelLimit = 3

    //e.g.: 第1⃣️级:0，第2⃣️级：00/01，第3⃣️级：000/001/002 or 010/011/012
    var id: String = ""
    var tagName: String = ""
    var title: String = ""
    var energyData: EnergyData?
    //支路太多不利于分析、显示即一次性数据请求，限制支路最多为10（0～9），后续有需求在更新（0～9a~zA~Z)
    var branches = [EnergyBranch]()

    func getLogTags() -> [LogTag] {
        var tags = [LogTag]()
        if isValidTag() {
            tags.append(LogTag(name: tagName, logDataType: .Last))
        }
        tags.append(contentsOf: branches.map { LogTag(name: $0.tagName, logDataType: .Last) })
        return tags
    }

    func getAllBranches() -> [EnergyBranch] {
        var childBranches = [EnergyBranch]()
        branches.forEach { element in
            childBranches.append(element)
            childBranches.append(contentsOf: element.getAllBranches())
        }
        return childBranches
    }

    func isValidTag() -> Bool {
        //除了最顶级（工程）支路外，其他支路tagName应为有效值
        return !tagName.isEmpty
    }

    func copy() -> EnergyBranch {
        let branch = EnergyBranch()
        branch.id = id
        branch.tagName = tagName
        branch.title = title
        branch.energyData = energyData
        branch.branches = branches.map { $0.copy() }
        return branch
    }

    // MARK: - 静态方法

    /// 从服务后台接收点数据转换为层级支路
    /// - Parameter message: <#message description#>
    static func getLevelBranches(_ message: String) -> [EnergyBranch] {
        let items = message.components(separatedBy: EnergyBranch.itemSeparator).map { element -> EnergyBranch in
            let infos = element.components(separatedBy: EnergyBranch.branchSeparator)
            let branch = EnergyBranch()
            if infos.count == 3 {
                branch.id = infos[0]
                branch.tagName = infos[1]
                branch.title = infos[2]
            }
            return branch
        }
        return getChildBranches(in: items)
    }

    private static func getChildBranches(with id: String = "", in branches: [EnergyBranch]) -> [EnergyBranch] {
        var children = [EnergyBranch]()
        let pattern = "^\(id)\\d$"
        let regex = try? NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        for index in 0..<branches.count {
            let branch = branches[index]
            let range = NSRange(location: 0, length: branch.id.count)
            if let _ = regex?.firstMatch(in: branch.id, options: [], range: range) {
                branch.branches = getChildBranches(with: branch.id, in: branches)
                children.append(branch)
            }
        }
        return children
    }


    /// 将支路转化为服务后台可接收点文本格式
    /// - Parameter branches: <#branches description#>
    static func getBranchMessage(_ branches: [EnergyBranch]) -> String {
        return branches.map {
            //防止人为输入的名称存在分隔符
            $0.title.removeCharacters(chars: "/;")
            return $0.id + EnergyBranch.branchSeparator + $0.tagName + EnergyBranch.branchSeparator + $0.title
        }.joined(separator: EnergyBranch.itemSeparator)
    }

    static func == (lhs: EnergyBranch, rhs: EnergyBranch) -> Bool {
        return lhs.id == rhs.id && lhs.tagName == rhs.tagName && lhs.title == rhs.title
    }
}
