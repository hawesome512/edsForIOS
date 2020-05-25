//
//  ViewUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import RxSwift

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
        backView.clipsToBounds = true
        backView.backgroundColor = .systemBackground
        container.addSubview(backView)
        backView.edgesToSuperview(insets: .uniform(edsMinSpace))
        return backView
    }


    /// 增加幻彩毛玻璃效果
    /// - Parameter container: <#container description#>
    static func addColorEffect(in container: UIView) {
        let backgroundImage = UIImageView()
        backgroundImage.image = UIImage(named: "background")
        backgroundImage.contentMode = .scaleAspectFill
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        backgroundImage.addSubview(blurEffectView)
        blurEffectView.edgesToSuperview()
        container.addSubview(backgroundImage)
        backgroundImage.edgesToSuperview()
    }

    
    /// 应用高像素的APP图标（经测试，无效）
    /// - Returns: <#description#>
    static func getHighResolutionAppIcon() -> UIImage? {
        guard let infoPlist = Bundle.main.infoDictionary else { return nil }
        guard let bundleIcons = infoPlist["CFBundleIcons"] as? NSDictionary else { return nil }
        guard let bundlePrimaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? NSDictionary else { return nil }
        guard let bundleIconFiles = bundlePrimaryIcon["CFBundleIconFiles"] as? NSArray else { return nil }
        guard let appIcon = bundleIconFiles.lastObject as? String else { return nil }
        return UIImage(named: appIcon)
    }
    
    
    /// 设置网络图片（允许失败后x秒后重试y次)
    /// - Parameters:
    ///   - imageView: <#imageView description#>
    ///   - url: <#url description#>
    static func setWebImage(in imageView:UIImageView,with url:URL?,disposeBag:DisposeBag,placeholder:Placeholder?=nil){
        guard let url=url else { return }
        imageView.kf.setImage(with: url,placeholder: placeholder){result in
            switch result{
            case .failure:
                //只重试一次:3s后
                Observable.of(1).delay(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance).bind(onNext: {_ in
                    imageView.kf.setImage(with: url,placeholder: placeholder)
                }).disposed(by: disposeBag)
                break
            default:
                break
            }
        }
    }
}
