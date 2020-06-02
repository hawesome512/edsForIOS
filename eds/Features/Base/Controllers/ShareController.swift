//
//  ShareController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/31.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

protocol ShareDelegate {
    func share(with shareType: ShareType)
}

class ShareController: BottomController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var shareItems = ShareType.allCases
    var delegate: ShareDelegate?

    override init() {
        super.init()
        viewHeight = 180
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = edsMinSpace
        layout.minimumInteritemSpacing = edsMinSpace
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ShareCell.self, forCellWithReuseIdentifier: String(describing: ShareCell.self))
        collectionView.backgroundColor = .systemBackground
        contentView.addSubview(collectionView)
        //上边缩进，避免遮盖⬇️下滑关闭按键
        collectionView.edgesToSuperview(excluding: .top)
        collectionView.topToBottom(of: titleLabel, offset: edsMinSpace)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ShareCell.self), for: indexPath) as! ShareCell
        let item = shareItems[indexPath.row]
        cell.imageView.tintColor = item.getImageConfig().color
        cell.imageView.image = item.getImageConfig().image
        cell.titleLabel.text = item.toString()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rect = collectionView.bounds
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let count = CGFloat(shareItems.count)
        let width = rect.width - layout.minimumLineSpacing * count
        return CGSize(width: width / count, height: rect.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        //delegate要在dismiss之后，否侧会出错
        //原因：parentVC调用shareVC,delegate触发parentVC调用短信/邮件等页面，不先dismiss shareVC，parentVC不能present其他的vc
        delegate?.share(with: shareItems[indexPath.row])
    }
}

enum ShareType: String, CaseIterable {
    case phone
    case sms
    case mail
//    case wechat

    func toString() -> String {
        return rawValue.localize()
    }

    func getImageConfig() -> (image: UIImage?, color: UIColor) {
        switch self {
        case .mail:
            return (UIImage(systemName: "envelope.open"), UIColor.systemBlue)
        case .phone:
            return (UIImage(systemName: "phone.arrow.up.right"), UIColor.systemRed)
        case .sms:
            return (UIImage(systemName: "ellipses.bubble"), UIColor.systemYellow)
//        case .wechat:
//            return (UIImage(named: "wechat"), UIColor.systemGreen)
        }
    }
}

class ShareCell: UICollectionViewCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.width(edsHeight)
        imageView.height(edsHeight)
        imageView.centerXToSuperview()
        imageView.topToSuperview()

        addSubview(titleLabel)
        titleLabel.centerXToSuperview()
        titleLabel.topToBottom(of: imageView, offset: edsMinSpace)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
