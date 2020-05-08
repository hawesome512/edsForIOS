//
//  HomeWorkorderCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/13.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class HomeWorkorderCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let slider = HorSliderView()
    private let stateImage = UIImageView()

    var workorder: Workorder? {
        didSet {
            guard let workorder = workorder else {
                return
            }
            titleLabel.text = "\(workorder.title)(\(workorder.state.getText()))"
            let state = workorder.getTimeState()
            stateImage.tintColor = state.color
            stateImage.image = state.icon
            //步进100/4=25
            let step = slider.maxValue / CGFloat(WorkorderState.allCases.count)
            slider.value = (CGFloat(workorder.state.rawValue) + 1) * step
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        tintColor = .white
        let contentView = ViewUtility.addCardEffect(in: self)
        ViewUtility.addColorEffect(in: contentView)

        let workorderImage = UIImageView()
        workorderImage.image = Workorder.icon
        contentView.addSubview(workorderImage)
        workorderImage.width(edsIconSize)
        workorderImage.height(edsIconSize)
        workorderImage.leadingToSuperview(offset: edsMinSpace)
        workorderImage.topToSuperview(offset: edsMinSpace)

        let workorderLabel = UILabel()
        workorderLabel.textColor = .white
        workorderLabel.text = "workorder".localize(with: prefixHome)
        workorderLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        contentView.addSubview(workorderLabel)
        workorderLabel.centerY(to: workorderImage)
        workorderLabel.leadingToTrailing(of: workorderImage, offset: edsMinSpace)

        let state = Workorder().getTimeState()
        stateImage.tintColor = state.color
        stateImage.image = state.icon
        contentView.addSubview(stateImage)
        stateImage.width(edsIconSize)
        stateImage.height(edsIconSize)
        stateImage.centerYToSuperview()
        stateImage.trailingToSuperview(offset: edsMinSpace)

        //text:配电房巡检（派发）
        titleLabel.text = "none".localize(with: prefixHome)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)
        titleLabel.leading(to: workorderImage)
        titleLabel.trailingToLeading(of: stateImage, offset: -edsSpace, relation: .equalOrLess)
        titleLabel.centerYToSuperview()

        slider.value = 0
        contentView.addSubview(slider)
        slider.horizontalToSuperview(insets: .horizontal(edsMinSpace))
        slider.height(HorSliderView.lineWidth)
        slider.bottomToSuperview(offset: -edsSpace)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
