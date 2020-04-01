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


    /// 卡片风格的View
    /// - Parameter container: 先添加卡片风格，然后在容器上添加其他控件
    static func addCardEffect(in container: UIView) -> UIView {
        container.backgroundColor = edsDivideColor
        let backView = UIView()
        backView.layer.shadowColor = UIColor.systemGray.cgColor
        backView.layer.shadowOpacity = 0.5
        backView.layer.cornerRadius = 5
        backView.backgroundColor = .white
        container.addSubview(backView)
        backView.edgesToSuperview(insets: .uniform(edsMinSpace))
        return backView
    }

}
