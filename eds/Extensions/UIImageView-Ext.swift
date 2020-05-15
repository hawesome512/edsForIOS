//
//  UIImageView-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/12.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {

    
    /// 缩放
    func enableZoom() {
        let pinGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinGesture)
    }

    @objc func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}
