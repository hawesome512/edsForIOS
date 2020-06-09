//
//  UIView-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

private var SwViewCaptureKey_IsCapturing: String = "SwViewCapture_AssoKey_isCapturing"

extension UIView {
    
    var snapshot: UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    
    /// 用于滚动截屏
    var isCapturing:Bool! {
        get {
            let num =  objc_getAssociatedObject(self, &SwViewCaptureKey_IsCapturing)
            if num == nil {
                return false
            }
            
            //            num as AnyObject .boolValue
            return false
            
            //            return num.boolValue
        }
        set(newValue) {
            let num = NSNumber(value: newValue as Bool)
            objc_setAssociatedObject(self, &SwViewCaptureKey_IsCapturing, num, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 加载动画
    func loadedWithAnimation(){
        let scaleTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.transform = scaleTransform
        self.alpha = 0
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: [], animations: {
            self.transform = .identity
            self.alpha = 1
        }, completion: nil)
    }
}
