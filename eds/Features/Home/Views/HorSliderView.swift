//
//  HorSliderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HorSliderView: UIView {

    static var lineWidth: CGFloat = 10
    var value: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var minValue: CGFloat = 0
    var maxValue: CGFloat = 100
    var thumbColor: UIColor = .systemYellow
    var trackColor: UIColor = .systemGray

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        
        let trackLine = UIBezierPath()
        trackLine.move(to: CGPoint.zero)
        trackLine.addLine(to: CGPoint(x: rect.width, y: 0))
        trackLine.lineWidth = HorSliderView.lineWidth
        trackColor.setStroke()
        trackLine.stroke()

        let thumbLine = UIBezierPath()
        thumbLine.move(to: CGPoint.zero)
        let ratio = (value - minValue) / (maxValue - minValue)
        let offsetX = ratio * rect.width
        thumbLine.move(to: CGPoint.zero)
        thumbLine.addLine(to: CGPoint(x: offsetX, y: 0))
        thumbLine.lineWidth = HorSliderView.lineWidth
        thumbColor.setStroke()
        thumbLine.stroke()
    }

}
