//
//  TextField-Ext.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/2/20.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

class LooseTextField: UITextField {

    // MARK: -文本缩进
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return insetRect(rect: bounds)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return insetRect(rect: bounds)

    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return insetRect(rect: bounds)
    }

    private func insetRect(rect: CGRect) -> CGRect {
        return rect.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }

}
