//
//  WorkorderStateCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class WorkorderStateCell: UITableViewCell {

    var flows: [WorkorderFlow]? {
        didSet {
            guard let flows = flows else { return }
            for (index, flow) in flows.enumerated() {
                let state = flow.timeLine.getState()
                stepImages[index].image = state.icon
                stepImages[index].tintColor = state.color
                stepTimes[index].text = flow.date
            }
        }
    }

    private var stepImages = [UIImageView]()
    private var stepTitles = [UILabel]()
    private var stepTimes = [UILabel]()

    private func initViews() {
        backgroundColor = .systemBackground
        //因Images/Title/Time控件位置需在draw定位，用户点击会laySubviews,在draw中的定位将失效
        //禁止用户点击此单元格
        isUserInteractionEnabled = false
        for (index, state) in WorkorderState.allCases.enumerated() {
            addImage()
            addTitle(with: state.getText(), index)
            addTime(index)
        }
    }

    private func addImage() {
        let imageView = UIImageView()
        imageView.width(edsHeight)
        imageView.height(edsHeight)
        //设置背景色可以遮挡底部进度线，因图片有透明，
        imageView.backgroundColor = .systemBackground
        stepImages.append(imageView)
        contentView.addSubview(imageView)
        imageView.centerYToSuperview()
    }

    private func addTitle(with title: String, _ index: Int) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        stepTitles.append(titleLabel)
        contentView.addSubview(titleLabel)
        //此处使用centerX经调试没有效果，因x方向上位置不固定，需在draw()中确定
        titleLabel.topToSuperview(offset: edsHeight + edsMinSpace * 2)
    }

    private func addTime(_ index: Int) {
        let timeLabel = UILabel()
        timeLabel.textColor = .systemGray
        timeLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        stepTimes.append(timeLabel)
        contentView.addSubview(timeLabel)
        timeLabel.topToBottom(of: stepTitles[index], offset: edsMinSpace)
        timeLabel.bottomToSuperview(offset: -edsMinSpace)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state

    }

    override func draw(_ rect: CGRect) {
        let startX = edsSpace + edsHeight / 2
        let step = (rect.width - startX * 2) / CGFloat(stepImages.count - 1)
        let centerY = edsMinSpace + edsHeight / 2

        for index in 0..<stepImages.count {
            let centerX = startX + step * CGFloat(index)
            stepImages[index].center = CGPoint(x: centerX, y: centerY)
            stepTitles[index].center.x = centerX
            stepTimes[index].center.x = centerX
        }

        //进度线
        let done = CGFloat(flows?.lastIndex(where: { $0.timeLine == .done }) ?? 0)
        let start = CGPoint(x: startX, y: centerY)
        let middle = start.offset(x: step * done, y: 0)
        let end = CGPoint(x: rect.width - startX, y: centerY)
        addLine(start: start, end: middle, color: .systemGreen)
        addLine(start: middle, end: end, color: .systemGray3)
    }

    private func addLine(start: CGPoint, end: CGPoint, color: UIColor) {
        let line = UIBezierPath()
        line.lineWidth = 2
        color.setStroke()
        line.move(to: start)
        line.addLine(to: end)
        line.stroke()
    }

}
