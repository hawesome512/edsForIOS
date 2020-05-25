//
//  DeviceRangeCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/11.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device水平范围指示条:init>items(addLabels)>value(updateMarker)

import UIKit
import RxSwift

class DeviceRangeCell: UITableViewCell {

    // MARK: 尺寸信息
    private let lineWidth: CGFloat = 4
    private let horSpace: CGFloat = 20
    private let verSpace: CGFloat = 10
    private let disposeBag = DisposeBag()
    private var labelSize = CGSize(width: 50, height: 20)

    // MARK: 外部设置
    //items格式：["0","green","10","yellow","20","red","30"]
    //cell在滚动时会频繁实例cell，判断count!=0时，不新增Label
    private var items: [String] = [] {
        didSet {
            if rangeLabels.count == 0 {
                addRangeLabels()
            }
        }
    }

    private var value: Float = 0 {
        didSet {
            valueRangeMaker.valueLabel.text = String(value)
            updateMarker()
        }
    }

    //items里坐标值：0，10，20，30……
    private var rangeLabels: [UILabel] = []
    private var nameLabel = UILabel()

    private var valueRangeMaker: RangeMakerView = RangeMakerView()

    fileprivate func updateMarker() {
        //根据value属性水平偏移游标
        valueRangeMaker.frame.origin.x = calStep(start: Float(items[0])!, end: value)
    }

    fileprivate func initViews() {
        //设置width为2*horSpace将方便游标▶️顶点与value重合，减少换算和偏移处理
        let size = CGSize(width: horSpace * 2, height: horSpace * 3)
        valueRangeMaker = RangeMakerView()
        valueRangeMaker.frame.size = size
        //游标置于范围条上方，间隔verSpace
        valueRangeMaker.frame.origin = CGPoint(x: 0, y: verSpace * 2)
        addSubview(valueRangeMaker)

        nameLabel.textColor = edsDefaultColor
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        addSubview(nameLabel)
        nameLabel.leadingToSuperview(offset: horSpace)
        nameLabel.topToSuperview(offset: verSpace)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
//        addSubview(marker)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        //最少是一段（无意义）：start-color-end
        guard items.count >= 3 else {
            return
        }
        //绘制多段范围条直线和更新坐标值位置
        let steps = (items.count - 1) / 2
        var start = CGPoint(x: horSpace, y: rect.height * 0.75)
        rangeLabels.first?.frame = CGRect(origin: start.offset(x: -labelSize.width / 2, y: verSpace), size: labelSize)
        for index in 1...steps {
            //n的终点为n+1的起点
            start = addLine(start: start, step: getStep(in: index))
            rangeLabels[index].frame = CGRect(origin: start.offset(x: -labelSize.width / 2, y: verSpace), size: labelSize)
        }
        updateMarker()
    }

    func addLine(start: CGPoint, step: (CGFloat, UIColor)) -> CGPoint {
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.move(to: start)
        let end = start.offset(x: step.0, y: 0)
        path.addLine(to: end)
        step.1.setStroke()
        path.stroke()
        return end
    }

    func addRangeLabels() {
        items.enumerated().filter { $0.offset % 2 == 0 }.forEach {
            let label = UILabel()
            label.text = $0.element
            label.textAlignment = .center
            addSubview(label)
            rangeLabels.append(label)
        }
    }

    //获取分段长度和颜色
    func getStep(in step: Int) -> (CGFloat, UIColor) {
        var length: CGFloat = 1
        if let start = Float(items[step * 2 - 2]), let end = Float(items[step * 2]) {
            length = calStep(start: start, end: end)
        }

        let color = UIColor(colorName: items[step * 2 - 1])
        return (length, color)
    }

    //计算两点之间的距离
    func calStep(start: Float, end: Float) -> CGFloat {
        if let first = Float(items.first!), let last = Float(items.last!) {
            var percent = (end - start) / (last - first)
            //0~1
            percent = max(0, min(1, percent))
            return CGFloat(percent) * (bounds.width - horSpace * 2)
        }
        return 1
    }

}

extension DeviceRangeCell: DevicePageItemSource {
    func initViews(with pageItem: DevicePageItem, rx tags: [Tag], rowIndex: Int) {
        nameLabel.attributedText = pageItem.name.localize().formatNameAndUnit()
        if let items = pageItem.items {
            self.items = items
            tags[0].showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
                self.value = Float($0)
            }).disposed(by: disposeBag)
        }
    }

    func getNumerOfRows(with pageItem: DevicePageItem) -> Int {
        return 1
    }


}

class RangeMakerView: UIView {

    private let color = UIColor.label
    private let verSpace: CGFloat = 10

    var valueLabel = UILabel()

    fileprivate func initViews() {
        valueLabel.textAlignment = .center
        valueLabel.textColor = color
        valueLabel.text = "0"
        addSubview(valueLabel)
        valueLabel.topToSuperview(offset: verSpace)
        valueLabel.widthToSuperview()
        //默认背景全黑不透明，清除背景色
        backgroundColor = UIColor.clear
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        //添加三角形于视图中下方位
        let triangle = UIBezierPath()
        let start = CGPoint(x: rect.width / 2, y: rect.height)
        triangle.move(to: start)
        triangle.addLine(to: start.offset(x: -rect.width / 3, y: -rect.height / 3))
        triangle.addLine(to: start.offset(x: rect.width / 3, y: -rect.height / 3))
        triangle.close()
        color.setFill()
        triangle.fill()
    }

}
