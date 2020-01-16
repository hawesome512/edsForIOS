//
//  DeviceItemMeterViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/8.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import HGCircularSlider
import RxSwift
import Moya

class DeviceItemMeterViewController: UIViewController {

    @IBOutlet weak var circularSlider: CircularSlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var authorityLabel: UILabel!

    private var stepLabels: [UILabel] = []
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initDefaultViews()
    }

    func initViews(with pageItem: DevicePageItem, tag: Tag, authority: AuthorityResult) {

        guard var items = pageItem.items, items.count > 0 else {
            return
        }

        //检查是否存在单位Tag，（ACB.Ir),在计算的时候需要换算
        var unitTag: Tag?
        if let unit = pageItem.unit {
            unitTag = TagUtility.sharedInstance.getRelatedTag(with: unit, related: tag)
        }

        //等差数列,["*","0","0.1","10"]，在Device.json中尽量将步进设大，在app中只做粗调
        if items[0] == DeviceModel.itemStepArray, items.count == 4 {
            //此处使用Decimal防止出现Double计算的各种混乱
            let doubleItems = items.suffix(from: 1).map { Decimal(Double($0) ?? 1) }
            items = []
            for i in stride(from: doubleItems[0], through: doubleItems[2], by: doubleItems[1]) {
                items.append("\(i)")
            }
        }
        //items刻度
        addStepLabels(items: items)

        //slider范围：0～count
        circularSlider.maximumValue = CGFloat(items.count)
        //因slider.value为CGFloat,需处理保证选中step，且max=min(%count)处理
        circularSlider.rx.controlEvent(.editingDidEnd).subscribe(onNext: {
            let index = Int(self.circularSlider.endPointValue.rounded()) % items.count
            self.circularSlider.endPointValue = CGFloat(index)
        }).disposed(by: disposeBag)
        circularSlider.rx.controlEvent(.valueChanged).subscribe(onNext: {
            let index = Int(self.circularSlider.endPointValue.rounded()) % items.count
            self.valueLabel.text = items[index]
        }).disposed(by: disposeBag)

        tag.showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {
            var tagValue = $0
            self.titleLabel.text = pageItem.name.localize(with: prefixDevice) + ":\(tagValue.clean)"
            //单位换算
            if let unitValue = unitTag?.getValue() {
                tagValue = tagValue / unitValue
            }
            //计算index,在APP的items中缩减了数量，tagValue未必在items中，计算相邻的index
            let index = items.firstIndex(of: tagValue.clean) ?? self.getNearestIndex(items, tagValue)
            self.circularSlider.endPointValue = CGFloat(index)
            self.valueLabel.text = items[index]
            self.updateButton.isEnabled = true
        }).disposed(by: disposeBag)

        updateButton.rx.tap.subscribe({ _ in
            guard var newValue = self.valueLabel.text else {
                return
            }
            //单位换算
            if let unitValue = unitTag?.getValue() {
                newValue = ((Double(newValue) ?? 0) * unitValue).clean
            }
            //若tag值无变化，拒绝提交
            guard newValue != tag.Value else {
                return
            }
            let newTag = Tag(name: tag.Name, value: newValue)
            self.valueLabel.text = "updating".localize(with: prefixDevice)
            self.updateButton.isEnabled = false
            MoyaProvider<WAService>().request(.setTagValues(authority: TagUtility.sharedInstance.tempAuthority, tagList: [newTag])) { result in
                switch result {
                case .success(let response):
                    print("update \(newTag.Name) value to \(newTag.Value!):\(JsonUtility.didSettedValues(data: response.data))")
                default:
                    break
                }
            }
        }).disposed(by: disposeBag)
        
        switch authority {
        case .granted:
            break
        default:
            authorityLabel.text = authority.rawValue.localize(with: prefixTrend)
            updateButton.isEnabled = false
            circularSlider.isEnabled = false
        }

    }

    private func initDefaultViews() {
        updateButton.isEnabled = false
        updateButton.setTitle("update".localize(with: prefixDevice), for: .normal)
        updateButton.layer.cornerRadius = updateButton.bounds.height / 2
        circularSlider.trackColor = edsDivideColor
        circularSlider.endPointValue = 0
    }

    private func addStepLabels(items: [String]) {
        let labelWidth = traitCollection.horizontalSizeClass == .regular ? 45 : 30
        items.enumerated().forEach {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: 20))
            label.text = $0.element
            label.font = UIFont.preferredFont(forTextStyle: .title1)
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            view.addSubview(label)
            stepLabels.append(label)
        }
    }


    /// 获取数值中最接近value的位置
    /// - Parameters:
    ///   - items: <#items description#>
    ///   - value: <#value description#>
    private func getNearestIndex(_ items: [String], _ value: Double) -> Int {
        let temps = items.map { abs(Double($0)! - value) }
        return temps.firstIndex(of: temps.min()!) ?? 0
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }


    /// 尺寸变化的时候表盘和刻度相应调整
    override func viewDidLayoutSubviews() {
        let width = circularSlider.bounds.width

        circularSlider.lineWidth = width * 0.15
        circularSlider.backtrackLineWidth = width * 0.15
        //thumb略小于lineWidth
        circularSlider.thumbRadius = circularSlider.lineWidth / 2 * 0.75
        //设定step刻度位置，基于slider圆心和角度偏移
        let radius = width * 0.35//(1/2-0.15)
        stepLabels.enumerated().forEach {
            let angle = CGFloat( Double.pi * 2 * Double($0.offset) / Double(circularSlider.maximumValue))
            $0.element.center = circularSlider.center.offset(x: radius * sin(angle), y: -radius * cos(angle))
        }
    }

}
