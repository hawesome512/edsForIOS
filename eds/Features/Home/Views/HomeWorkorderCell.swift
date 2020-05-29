//
//  HomeWorkorderCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/13.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class HomeWorkorderCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let slider = HorSliderView()
    private let stateImage = UIImageView()
    private var items: Dictionary<FlowTimeLine, CardItemButton> = [:]
    private let disposeBag = DisposeBag()
    private var workorder:Workorder?
    private var classfiedWorkorders: Dictionary<FlowTimeLine, [Workorder]> = [:]
    
    var parentVC:UIViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
        initData()
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
        
        let state = FlowTimeLine.planing.getState()
        stateImage.tintColor = state.color
        stateImage.image = state.icon
        contentView.addSubview(stateImage)
        stateImage.width(edsIconSize)
        stateImage.height(edsIconSize)
        stateImage.centerYToSuperview()
        stateImage.trailingToSuperview(offset: edsSpace)
        
        //text:配电房巡检（派发）
        titleLabel.text = "none".localize(with: prefixHome)
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)
        titleLabel.leading(to: workorderImage)
        titleLabel.trailingToLeading(of: stateImage, offset: -edsSpace, relation: .equalOrLess)
        titleLabel.centerYToSuperview()
        
        slider.value = 0
        contentView.addSubview(slider)
        slider.height(HorSliderView.lineWidth)
        slider.centerY(to: workorderImage)
        slider.leadingToTrailing(of: workorderLabel,offset: edsSpace)
        slider.trailingToSuperview(offset: edsSpace)
        
        var index = 0
        FlowTimeLine.allCases.enumerated().forEach({ (offset,flow) in
            let state = flow.getState()
            let itemButton = CardItemButton()
            itemButton.tintColor = state.color
            itemButton.iconImage.image = state.icon
            itemButton.valueLabel.text = "0"
            itemButton.rx.tap.bind(onNext: {
                let wolistVC = WorkorderListViewController()
                wolistVC.flowFilter = flow
                wolistVC.hidesBottomBarWhenPushed = true
                self.parentVC?.navigationController?.pushViewController(wolistVC, animated: true)
            }).disposed(by: disposeBag)
            contentView.addSubview(itemButton)
            itemButton.widthToSuperview(multiplier: 1/3)
            itemButton.height(edsIconSize+edsSpace)
            itemButton.bottomToSuperview()
            if index == 0 {
                itemButton.leadingToSuperview()
            } else {
                let lastItem = FlowTimeLine.init(rawValue: offset - 1)!
                itemButton.leadingToTrailing(of: items[lastItem]!)
            }
            items[flow]=itemButton
            index = index+1
        })
        
    }
    
    private func initData(){
        WorkorderUtility.sharedInstance.successfulUpdated.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: { updated in
            guard updated == true, let workorder = WorkorderUtility.sharedInstance.getMyWorkorder() else { return }
            self.workorder = workorder
            self.titleLabel.text = "\(workorder.title)(\(workorder.state.getText()))"
            let state = workorder.getFlowTimeLine().getState()
            self.stateImage.tintColor = state.color
            self.stateImage.image = state.icon
            //步进100/4=25
            let step = self.slider.maxValue / CGFloat(WorkorderState.allCases.count)
            self.slider.value = (CGFloat(workorder.state.rawValue) + 1) * step
            
            self.classfiedWorkorders = WorkorderUtility.sharedInstance.getClassifiedWorkorders()
            self.classfiedWorkorders.forEach{(flow,workorders) in
                self.items[flow]?.valueLabel.text = "\(workorders.count)"
            }
        }).disposed(by: disposeBag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        guard selected == true, let workorder = workorder else { return }
        let workorderVC = WorkorderViewController()
        workorderVC.workorder = workorder
        workorderVC.hidesBottomBarWhenPushed = true
        parentVC?.navigationController?.pushViewController(workorderVC, animated: true)
        
    }
    
}
