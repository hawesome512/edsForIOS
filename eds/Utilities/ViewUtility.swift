//
//  ViewUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

class ViewUtility {


    /// 设置大标题
    /// - Parameters:
    ///   - vc: <#vc description#>
    ///   - large: <#large description#>
    static func preferLargeTitle(in vc: UIViewController, _ large: Bool) {
        vc.navigationController?.navigationBar.prefersLargeTitles = large
    }


    /// 计算顶部高度：状态栏+导航栏
    /// - Parameter vc: <#vc description#>
    static func calStatusAndNavBarHeight(in vc: UIViewController) -> CGFloat {
        let statusHeight = vc.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let navHeight = vc.navigationController?.navigationBar.frame.height ?? 0
        return statusHeight + navHeight
    }
}
