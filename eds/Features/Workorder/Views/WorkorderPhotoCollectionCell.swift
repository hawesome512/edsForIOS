//
//  WorkorderPhotoCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/18.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Kingfisher
import YPImagePicker
import RxSwift

class WorkorderPhotoCollectionCell: UITableViewCell {

    private let disposeBag = DisposeBag()

    //图片来源：本机选择，网络
    var photoSource = PhotoSource()
    var executing = false {
        didSet {
            collectionView.reloadData()
        }
    }
    var parentVC: UIViewController?
    private let photoHeight: CGFloat = 120
    private let countLimit = 12

    private let rightImage = UIImageView()
    //单行显示图片数量，为方便计算使用cgfloat格式
    private var horShowLimit: CGFloat = 3

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: edsMinSpace, left: edsMinSpace, bottom: edsMinSpace, right: edsMinSpace)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
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

    override func layoutMarginsDidChange() {
        horShowLimit = traitCollection.horizontalSizeClass == .compact ? 3 : 6
    }

}

extension WorkorderPhotoCollectionCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let total = photoSource.getTotal()
        let count = executing ? total + 1 : total
        rightImage.alpha = CGFloat(count) > horShowLimit ? 1 : 0
        //哪怕为空，非执行状态，至少也显示一张图片
        return max(count, 1)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCell.self), for: indexPath) as! PhotoCell
        if executing {
            if indexPath.row == 0 {
                cell.contentImage.image = UIImage(systemName: "plus")
                cell.deleteButton.alpha = 0
            } else {
                photoSource.setImage(in: cell.contentImage, at: indexPath.row - 1)
                cell.deleteButton.alpha = 1
                cell.deleteButton.tag = indexPath.row
                cell.deleteButton.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
            }
        } else {
            photoSource.setImage(in: cell.contentImage, at: indexPath.row)
            cell.deleteButton.alpha = 0
        }
        cell.setBorder()
        return cell
    }

    @objc func deleteItem(_ sender: UIButton) {
        let row = sender.tag
        photoSource.removeImage(at: row - 1)
        //不能使用deleItems,例如原先row=2的cell,在删除row=1后，理论上row=2👉row=1，实际上row=2即cell.indexPath没有改变，尽管它已经上移了一位
        collectionView.reloadData()//.deleteItems(at: [IndexPath(row: row, section: 0)])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - edsMinSpace * (horShowLimit + 1)) / horShowLimit
        return CGSize(width: width, height: photoHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if executing && indexPath.row == 0 {
            let picker = ControllerUtility.generateImagePicker(maxCount: Workorder.imageLimit - photoSource.getTotal())
            picker.didFinishPicking { (items, cancelled) in
                items.forEach {
                    switch $0 {
                    case .photo(p: let photo):
                        self.photoSource.images.append(photo.image)
                    default:
                        break
                    }
                }
                picker.dismiss(animated: true, completion: nil)
                if items.count > 0 {
                    collectionView.reloadData()
                }
            }
            parentVC?.navigationController?.present(picker, animated: true, completion: nil)
            return
        }
        guard photoSource.getTotal() != 0 else {
            //图集为空，点击无效
            return
        }
        let photosVC = PhotoCollectionViewController()
        photosVC.photoSource = photoSource
        photosVC.offsetIndex = executing ? indexPath.row - 1: indexPath.row
        parentVC?.navigationController?.pushViewController(photosVC, animated: true)
    }


}
