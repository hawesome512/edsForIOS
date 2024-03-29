//
//  EnergySegmentCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  能耗时间模式：日/月/年，每个选项下是可选择的日期集合

import UIKit
import RxSwift
import SwiftDate

protocol DateSegmentDelegate {
    func pick(dateItem: EnergyDateItem)
}

class EnergySegmentCell: UITableViewCell {

    private let disposeBag = DisposeBag()
    private let cellID = String(describing: DateCollectionCell.self)
    private var dates: [EnergyDateItem] = []
    var delegate: DateSegmentDelegate?
    var dateItem: EnergyDateItem?

    private let dateSegment = UISegmentedControl(items: EnergySegmentType.allCases.map { $0.getText() })
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("required init(coder:) not completed!")
    }

    private func initViews() {

        dateSegment.rx.selectedSegmentIndex.asObservable().bind(onNext: { index in
            guard let type = EnergySegmentType(rawValue: index) else {
                return
            }
            let dates = type.getDates()
            self.dates = dates
            self.collectionView.reloadData()
            let indexPath = IndexPath(row: self.dates.count - 1, section: 0)
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
            self.delegate?.pick(dateItem: dates.last!)
        }).disposed(by: disposeBag)
        contentView.addSubview(dateSegment)
        dateSegment.edgesToSuperview(excluding: .bottom)
        dateSegment.height(edsIconSize)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = edsDivideColor
        collectionView.register(DateCollectionCell.self, forCellWithReuseIdentifier: cellID)
        contentView.addSubview(collectionView)
        collectionView.edgesToSuperview(excluding: .top)
        //适当增加高度，防止误触
        collectionView.height(60)
        collectionView.topToBottom(of: dateSegment)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //首次选择并调整到最新项（最右边）,只有在视图加载出来后跳转才能生效
    override func layoutSubviews() {
        var indexPath = IndexPath(row: 0, section: 0)
        if let dateType = dateItem?.dateType {
            dateSegment.selectedSegmentIndex = dateType.rawValue
            dates = dateType.getDates()
            let index = dates.firstIndex(where: { $0 == dateItem }) ?? 0
            indexPath = IndexPath(row: index, section: 0)
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        } else {
            //默认月模式
            let selectedType: EnergySegmentType = .month
            dateSegment.selectedSegmentIndex = selectedType.rawValue
            dates = selectedType.getDates()
            indexPath = IndexPath(row: dates.count - 1, section: 0)
//            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        }
        //在首次触发layoutSubviews时，cell未完全加载显示，此时调用collectionView.scrollPosition无效
        //设置一个延迟触发机制
        Observable<Int>.timer(.milliseconds(100), scheduler: MainScheduler.instance).bind(onNext: {_ in
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
        }).disposed(by: disposeBag)
    }

}

extension EnergySegmentCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DateCollectionCell
        if indexPath.row < dates.count {
            cell.title = dates[indexPath.row].getText()
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: edsHeight * 2, height: edsHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pick(dateItem: dates[indexPath.row])
    }
}
