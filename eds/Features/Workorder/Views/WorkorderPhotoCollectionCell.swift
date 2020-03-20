//
//  WorkorderPhotoCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Kingfisher

class WorkorderPhotoCollectionCell: UITableViewCell {

    var imageUrls = [URL]()
    var photoHeight: CGFloat = 120

    private let rightImage = UIImageView()

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: edsMinSpace, left: edsMinSpace, bottom: edsMinSpace, right: edsMinSpace)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private func initViews() {
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: String(describing: PhotoCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.edgesToSuperview()
        collectionView.height(photoHeight + edsMinSpace * 2)

        rightImage.image = UIImage(systemName: "chevron.compact.right")
        rightImage.tintColor = edsLightGrayColor
        addSubview(rightImage)
        rightImage.width(edsIconSize)
        rightImage.height(edsIconSize)
        rightImage.centerYToSuperview()
        rightImage.trailingToSuperview(offset: edsMinSpace)
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

}

extension WorkorderPhotoCollectionCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCell.self), for: indexPath) as! PhotoCell
        cell.contentImage.kf.setImage(with: imageUrls[indexPath.row], placeholder: edsDefaultImage)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let count: CGFloat = traitCollection.horizontalSizeClass == .compact ? 3 : 6
        let width = (collectionView.bounds.width - edsMinSpace * (count + 1)) / count
        return CGSize(width: width, height: photoHeight)
    }


}
