//
//  PhotoCollectionViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/24.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Foundation


class PhotoCollectionViewController: UIViewController {

    var photoURLs = [URL]()

    //起始偏移
    var offsetIndex = 0

    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

    private func initViews() {

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        collectionView.backgroundColor = .white
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: String(describing: PhotoCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 0
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.subviews.first?.alpha = 1
    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        //全屏显示，layout.scrollDirection=.hor,上下会缩进安全距离，不能达到全屏效果，且报错cell.height>collectionView.height
        let inset = collectionView.adjustedContentInset
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        layout.sectionInset = UIEdgeInsets(top: -inset.top, left: 0, bottom: -inset.bottom, right: 0)
        let size = collectionView.frame.size
        layout.itemSize = size
        if offsetIndex > 0 {
            let offsetX = (size.width + layout.minimumLineSpacing) * CGFloat(offsetIndex)
            collectionView.setContentOffset(CGPoint(x: offsetX, y: -inset.top), animated: false)
        }
    }
}

extension PhotoCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoCell.self), for: indexPath) as! PhotoCell
        cell.url = photoURLs[indexPath.row]
        cell.indexLabel.innerText = "\(indexPath.row + 1)/\(photoURLs.count)"
        return cell
    }

}

