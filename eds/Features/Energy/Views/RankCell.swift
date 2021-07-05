//
//  RankCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/7/10.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import SwiftDate

class RankCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let rankLabel = UILabel()
    private let rankIcon = UIImageView()
    private let scoreLabel = UILabel()
    private let viewSpace: CGFloat = 2
    private var widthConstraints :[NSLayoutConstraint] = []
    private var widthRatios: [Double] = []
    private var titleLabels: [UILabel] = []
    private var valueLabels: [UILabel] = []
    private var showViews: [UIView] = []
    
    var rankData: RankData? {
        didSet{
            guard let rankData = rankData else { return }
            let account = rankData.account
            let isLocal = account == BasicUtility.sharedInstance.getBasic()?.user
            titleLabel.text = isLocal ? account : account.toHiddenString()
            scoreLabel.text = "\(rankData.score)"
            widthRatios = rankData.ratios
            setNeedsDisplay()
        }
    }
    
    private func initViews(){
        
        rankLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        contentView.addSubview(rankLabel)
        rankLabel.topToSuperview(offset: edsSpace)
        rankLabel.leadingToSuperview(offset: edsSpace)
        
        rankIcon.image = UIImage(named: "rank1")
        contentView.addSubview(rankIcon)
        rankIcon.width(edsHeight)
        rankIcon.height(edsHeight)
        rankIcon.leadingToSuperview(offset:edsMinSpace)
        rankIcon.topToSuperview(offset: edsMinSpace)

        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)
        titleLabel.leadingToTrailing(of: rankIcon, offset: edsMinSpace)
        titleLabel.topToSuperview(offset: edsSpace)
        
        scoreLabel.text = "0"
        scoreLabel.font = UIFont.italicSystemFont(ofSize: 40)
        scoreLabel.textColor = .systemOrange
        contentView.addSubview(scoreLabel)
        scoreLabel.trailingToSuperview(offset: edsSpace)
        scoreLabel.centerY(to: titleLabel)
        scoreLabel.leadingToTrailing(of: titleLabel, offset: edsSpace, relation: .equalOrGreater)

        let energyTimes = EnergyTime.allCases
        for i in 0..<EnergyTime.allCases.count {
            
            widthRatios.append(1/Double(energyTimes.count))
            
            let textAlignment: NSTextAlignment
            switch i {
            case 0:
                textAlignment = .left
            case energyTimes.count-1:
                textAlignment = .right
            default:
                textAlignment = .center
            }
            
            let valueLabel = UILabel()
            valueLabel.textAlignment = textAlignment
            valueLabel.text = "0%"
            valueLabel.textColor = .secondaryLabel
            valueLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(valueLabel)
            valueLabel.topToBottom(of: rankIcon,offset: edsMinSpace)
            if i == 0 {
                valueLabel.leadingToSuperview(offset: edsSpace)
            } else {
                valueLabel.leadingToTrailing(of: valueLabels[i-1],offset: viewSpace)
            }
            let constraint = valueLabel.widthAnchor.constraint(equalToConstant: 0)
            constraint.isActive = true
            valueLabels.append(valueLabel)
            widthConstraints.append(constraint)
            
            let showView = UIView()
            showView.alpha = 0.7
            showView.backgroundColor = energyTimes[i].getColor()
            contentView.addSubview(showView)
            showView.height(edsMinSpace)
            showView.width(to: valueLabel)
            showView.topToBottom(of: valueLabel,offset: edsMinSpace)
            showView.leading(to: valueLabel)
            
            let titleLabel = UILabel()
            titleLabel.textAlignment = textAlignment
            titleLabel.text = energyTimes[i].getText()
            titleLabel.textColor = energyTimes[i].getColor()
            titleLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(titleLabel)
            titleLabel.bottomToSuperview(offset: -edsMinSpace)
            titleLabel.topToBottom(of: showView, offset: edsMinSpace)
            titleLabel.leading(to: valueLabel)
            titleLabel.width(to: valueLabel)
            titleLabels.append(titleLabel)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView(of index: Int) {
        let index = index+1
        rankIcon.image = UIImage(named: "rank\(index)")
        rankLabel.text = "\(index)"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func draw(_ rect: CGRect) {
        let width = rect.width - 2 * edsSpace - CGFloat(widthRatios.count - 1) * viewSpace
        let balancedRatios = EnergyUtility.balancedShowRatio(with: widthRatios)
        for i in 0..<widthRatios.count {
            valueLabels[i].text = (widthRatios[i] * 100).roundToPlaces(fractions: 0).clean + "%"
            widthConstraints[i].constant = width * CGFloat(balancedRatios[i])
        }
    }

}
