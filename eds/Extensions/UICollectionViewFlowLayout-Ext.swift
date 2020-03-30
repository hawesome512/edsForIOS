//
//  UICollectionViewFlowLayout-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/24.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionViewFlowLayout {

    //在横向滑动的过程中始终保持图片居中显示
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        guard layout?.scrollDirection == .horizontal else {
            return proposedContentOffset
        }
        let spacing = layout?.minimumLineSpacing ?? 0
        let width = layout?.itemSize.width ?? 0
        let index = round(proposedContentOffset.x / width)
        let offsetX = index * (width + spacing)
        return CGPoint(x: offsetX, y: proposedContentOffset.y)
    }
}
