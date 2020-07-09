//
//  TimeRangeCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/6/19.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  显示时段划分的结果：水平长条柱状图，24等分，每等分为一小时

import UIKit

class TimeRangeCell: UITableViewCell {
    
    var hourViews: [UIView] = []
    
    var timeDatas: [TimeData] = [] {
        didSet{
            hourViews.forEach{ $0.backgroundColor = .systemGray }
            timeDatas.forEach{ td in
                td.hours.forEach{
                    hourViews[$0].backgroundColor = td.energyTime.getColor()
                }
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initViews(){
        for i in 0..<TimeData.hourSectionCount {
            let view = UIView()
            hourViews.append(view)
            view.backgroundColor = EnergyTime.valley.getColor()
            addSubview(view)
            view.topToSuperview(offset: edsSpace)
            view.height(edsMinSpace)
            view.widthToSuperview(multiplier: 1/CGFloat(TimeData.hourSectionCount), offset: -2*edsSpace/CGFloat(TimeData.hourSectionCount))
            if i == 0 {
                view.leadingToSuperview(offset: edsSpace)
            } else {
                view.leadingToTrailing(of: hourViews[i-1])
            }
        }
        //3段标注：0/12/24
        let label1 = UILabel()
        label1.text = "0"
        addSubview(label1)
        label1.leading(to: hourViews[0])
        label1.topToBottom(of: hourViews[0], offset: edsMinSpace)
        label1.bottomToSuperview(offset: -edsMinSpace)
        
        let label2 = UILabel()
        label2.text = "12"
        addSubview(label2)
        label2.centerXToSuperview()
        label2.centerY(to: label1)
        
        let label3 = UILabel()
        label3.text = "24"
        addSubview(label3)
        label3.trailing(to: hourViews[TimeData.hourSectionCount-1])
        label3.centerY(to: label1)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
