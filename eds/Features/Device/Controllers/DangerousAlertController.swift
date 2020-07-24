//
//  DangerousAlertController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/7/22.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  危险操作提示框

import UIKit

class DangerousAlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "\n\n\n"
        let topView = UIView()
        topView.backgroundColor = .systemRed
        topView.layer.borderColor = UIColor.label.cgColor
        topView.layer.borderWidth = 2
        view.addSubview(topView)
        topView.edgesToSuperview(excluding: .bottom, insets: .uniform(edsSpace))
        
        let titleView = UIView()
        topView.addSubview(titleView)
        titleView.verticalToSuperview()
        titleView.centerXToSuperview()
        
        let elecIcon = UIImageView(image: UIImage(named: "dangerous"))
        titleView.addSubview(elecIcon)
        elecIcon.width(edsIconSize)
        elecIcon.height(edsIconSize)
        elecIcon.verticalToSuperview(insets: .vertical(edsMinSpace))
        elecIcon.leadingToSuperview(offset: edsSpace)
        
        let riskIcon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        riskIcon.tintColor = .white
        titleView.addSubview(riskIcon)
        riskIcon.width(edsIconSize)
        riskIcon.height(edsIconSize)
        riskIcon.centerY(to: elecIcon)
        riskIcon.leadingToTrailing(of: elecIcon)
        
        let titleLabel = UILabel()
        titleLabel.text = "dangerous".localize()
        titleLabel.textColor = .white
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleView.addSubview(titleLabel)
        titleLabel.leadingToTrailing(of: riskIcon)
        titleLabel.trailingToSuperview(offset: edsSpace)
        titleLabel.centerY(to: elecIcon)
    }
    
    static func present(in container: UIViewController?, handler: ((UIAlertAction) -> Void)?){
        guard let container = container else { return }
        let alertVC = DangerousAlertController(title: nil, message: "dangerous_content".localize(), preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "continue".localize(), style: .default, handler: handler)
        alertVC.addAction(cancel)
        alertVC.addAction(confirm)
        container.present(alertVC, animated: true, completion: nil)
    }

}
