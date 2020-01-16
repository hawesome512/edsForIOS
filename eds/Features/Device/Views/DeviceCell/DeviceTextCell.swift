//
//  DeviceTextCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/18.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Deviced文字显示（状态背景渐变）：init>backgroundGradientColor>valueLabel

import UIKit
import RxCocoa
import RxSwift

class DeviceTextCell: UITableViewCell {

    private let space: CGFloat = 20
    private let disposeBag = DisposeBag()
    private var valueLabel = UILabel()
    //横向渐变背景，需在draw(_:)设定frame
    private var gradientLayer = CAGradientLayer()
    private var backgroundGradientColor: UIColor = edsDefaultColor {
        didSet {
            //当添加背景色时，文本颜色变为白色更直观
            gradientLayer.setHorCenterGradientLayer(centerColor: backgroundGradientColor)
        }
    }

    fileprivate func initViews() {

        //自适应字体大小
        valueLabel.font = valueLabel.font.withSize(100)
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 1
        valueLabel.textColor = .white
        addSubview(valueLabel)
        valueLabel.horizontalToSuperview(insets: .horizontal(space))
        valueLabel.heightToSuperview()

        layer.insertSublayer(gradientLayer, at: 0)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        //渐变层添加时frame(0,0,0,0),CAGradientLayer不能使用约束
        gradientLayer.frame = rect
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension DeviceTextCell: DevicePageItemSource {
    func getNumerOfRows(with pageItem: DevicePageItem) -> Int {
        return 1
    }

    func initViews(with pageItem: DevicePageItem, rx tags: [Tag], rowIndex: Int) {
        if let tag = tags.first {
            tag.showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { value in
                let status = TagValueConverter.getText(value: value, items: pageItem.items)
                //文本，背景横向渐变
                self.valueLabel.text = status.text
                self.backgroundGradientColor = status.status?.getStatusColor() ?? edsDefaultColor
            }).disposed(by: disposeBag)
        }
    }
}

