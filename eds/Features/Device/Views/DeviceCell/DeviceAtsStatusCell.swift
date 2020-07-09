//
//  DeviceATSStatusCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/13.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device/ATS的工作状态指示:init>value(待完善）

import UIKit
import RxSwift

class DeviceATSStatusCell: UITableViewCell {

    // MARK:外观样式
    //左右对称部分占superView宽比例
    private let leftRatio: CGFloat = 0.1
    private let rightRatio: CGFloat = 0.9
    private let space: CGFloat = 10
    private let lineWidth: CGFloat = 2
    private let lineColor: UIColor = UIColor.label//.withAlphaComponent(0.8)
    private let disposeBag = DisposeBag()

    //5个状态指示灯，用字典存储，避免顺序混乱
    private lazy var statusValueViews: [ATSStatusViewType: UIView] = {
        var views = [ATSStatusViewType: UIView]()
        ATSStatusViewType.values.forEach {
            views[$0] = addStatusView()
        }
        return views
    }()

    // MARK:绘图
    //静态线段+动态指示灯
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let wid = rect.width
        let hei = rect.height
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        lineColor.setStroke()

        //左右两边距：wid*0.1,完全对称
        addVerItems(path, x: wid * leftRatio, hei: hei)
        addVerItems(path, x: wid * rightRatio, hei: hei)

        //底部
        path.move(to: CGPoint(x: wid * leftRatio, y: hei * 0.80))
        path.addLine(to: CGPoint(x: wid * rightRatio, y: hei * 0.80))
        path.move(to: CGPoint(x: wid * 0.5, y: hei * 0.8))
        path.addLine(to: CGPoint(x: wid * 0.5, y: hei * 0.95))
        path.stroke()
        let triangle = UIBezierPath()
        triangle.move(to: CGPoint(x: wid * 0.5, y: hei * 0.95))
        triangle.addLine(to: CGPoint(x: wid * 0.5 - space, y: hei * 0.95 - space * 2))
        triangle.addLine(to: CGPoint(x: wid * 0.5 + space, y: hei * 0.95 - space * 2))
        lineColor.setFill()
        triangle.fill()

        //中间连接线，线颜色稍浅
        let connect = UIBezierPath()
        connect.move(to: CGPoint(x: wid * leftRatio, y: hei * 0.5))
        connect.addLine(to: CGPoint(x: wid * rightRatio - space, y: hei * 0.5))
        UIColor.darkGray.setStroke()
        connect.stroke()

        //状态指示灯位置
        statusValueViews[.source1]?.center = CGPoint(x: wid * leftRatio, y: hei * 0.35)
        statusValueViews[.source2]?.center = CGPoint(x: wid * rightRatio, y: hei * 0.35)
        statusValueViews[.to1]?.center = CGPoint(x: wid * leftRatio, y: hei * 0.7)
        statusValueViews[.to2]?.center = CGPoint(x: wid * rightRatio, y: hei * 0.7)
        statusValueViews[.toOFF]?.center = CGPoint(x: wid * 0.5, y: hei * 0.5)
    }

    fileprivate func addVerItems(_ path: UIBezierPath, x: CGFloat, hei: CGFloat) {
        let start = CGPoint(x: x, y: hei * 0.1)
        path.move(to: start.offset(x: space, y: space))
        addCircle(path: path, withCenter: start.offset(x: 0, y: space))
        path.move(to: start.offset(x: space, y: space * 2))
        addCircle(path: path, withCenter: start.offset(x: 0, y: space * 2))
        path.move(to: start.offset(x: 0, y: space * 3))
        path.addLine(to: start.offset(x: 0, y: hei * 0.35))
        path.move(to: start.offset(x: -space, y: hei * 0.35))
        path.addLine(to: start.offset(x: space, y: hei * 0.35))
        path.move(to: start.offset(x: -space, y: hei * 0.35 + space))
        path.addLine(to: start.offset(x: 0, y: hei * 0.50))
        path.addLine(to: start.offset(x: 0, y: hei * 0.70))
    }

    func addCircle(path: UIBezierPath, withCenter center: CGPoint) {
        path.addArc(withCenter: center, radius: space, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
    }

    func addStatusView() -> UIView {
        let view = UIView()
        let size = CGSize(width: space * 2, height: space * 2)
        let origin = CGPoint(x: 0, y: 0)
        view.frame = CGRect(origin: origin, size: size)
        view.layer.cornerRadius = space
        view.layer.borderColor = lineColor.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        view.backgroundColor = .systemGreen
        addSubview(view)
        return view
    }

}

extension DeviceATSStatusCell: DevicePageItemSource {
    func initViews(with pageItem: DevicePageItem, rx tags: [Tag], rowIndex: Int) {
        tags[0].showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
            //e.g.:"1off(1on)/1normal(1fault)/2off(2on)/2normal(2fault)
            let status = TagValueConverter.getText(value: $0, items: pageItem.items).text
            let source1Fault = status.contains("1fault")
            self.statusValueViews[.source1]?.backgroundColor = source1Fault ? edsAlarm : edsON
            let source2Fault = status.contains("2fault")
            self.statusValueViews[.source2]?.backgroundColor = source2Fault ? edsAlarm : edsON
            if status.contains("1on") {
                self.statusValueViews[.to1]?.backgroundColor = edsON
                self.statusValueViews[.to2]?.backgroundColor = edsOFF
                self.statusValueViews[.toOFF]?.backgroundColor = edsOFF
            } else if status.contains("2on") {
                self.statusValueViews[.to1]?.backgroundColor = edsOFF
                self.statusValueViews[.to2]?.backgroundColor = edsON
                self.statusValueViews[.toOFF]?.backgroundColor = edsOFF
            } else {
                self.statusValueViews[.to1]?.backgroundColor = edsOFF
                self.statusValueViews[.to2]?.backgroundColor = edsOFF
                self.statusValueViews[.toOFF]?.backgroundColor = edsON
            }
        }).disposed(by: disposeBag)
    }

    func getNumerOfRows(with pageItem: DevicePageItem) -> Int {
        return 1
    }


}


/// ATS面板的5个指示灯，1电/2电（显示电源侧状态），投常/投备/双分
enum ATSStatusViewType {
    case source1
    case source2
    case to1
    case to2
    case toOFF

    static let values = [source1, source2, to1, to2, toOFF]
}
