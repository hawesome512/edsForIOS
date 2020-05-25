//
//  IconPagingCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/4.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//  从Parchment搬运过来，menu图标显示

import UIKit
import Parchment

struct IconPagingCellViewModel {
    let image: UIImage?
    let selected: Bool
    let tintColor: UIColor
    let selectedTintColor: UIColor

    init(image: UIImage?, selected: Bool, options: PagingOptions) {
        self.image = image
        self.selected = selected
        self.tintColor = options.textColor
        self.selectedTintColor = options.selectedTextColor
    }
}

struct IconItem: PagingItem, Hashable, Comparable {

    let icon: String
    let index: Int
    let image: UIImage?

    init(icon: String, index: Int) {
        self.icon = icon
        self.index = index
        self.image = UIImage(named: icon)
    }

    //Parchment规定PagingItem必须实现hashable,comparable
//    var hashValue: Int {
//        return icon.hashValue
//    }

    static func < (lhs: IconItem, rhs: IconItem) -> Bool {
        return lhs.index < rhs.index
    }

    static func == (lhs: IconItem, rhs: IconItem) -> Bool {
        return (
            lhs.index == rhs.index &&
                lhs.icon == rhs.icon
        )
    }
}

class IconPagingCell: PagingCell {

    fileprivate var viewModel: IconPagingCellViewModel?
    private let deselectedScale: CGFloat = 0.8

    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        //图标上下适当缩进
        imageView.edgesToSuperview(insets: .vertical(10))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setPagingItem(_ pagingItem: PagingItem, selected: Bool, options: PagingOptions) {
        if let item = pagingItem as? IconItem {

            let viewModel = IconPagingCellViewModel(
                image: item.image,
                selected: selected,
                options: options)

            imageView.image = viewModel.image

            //选中图标变大，颜色变红
            if viewModel.selected {
                imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                imageView.image = imageView.image?.withTintColor(.systemRed)
            } else {
                imageView.transform = CGAffineTransform(scaleX: deselectedScale, y: deselectedScale)
                imageView.image = imageView.image?.withTintColor(edsDefaultColor)
            }

            self.viewModel = viewModel
        }
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        guard let viewModel = viewModel else { return }
        //尺寸、颜色动画
        if let attributes = layoutAttributes as? PagingCellLayoutAttributes {
            let scale = ((1 - deselectedScale) * attributes.progress) + deselectedScale
            imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            imageView.tintColor = UIColor.interpolate(
                from: viewModel.tintColor,
                to: viewModel.selectedTintColor,
                with: attributes.progress)
        }
    }

}


