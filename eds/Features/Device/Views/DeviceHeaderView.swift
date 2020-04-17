//
//  DeviceHeaderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/12/27.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  设备页头图

import UIKit
import RxSwift
import TinyConstraints
import YPImagePicker
import Moya
import Kingfisher

class DeviceHeaderView: UIView {

    private let cornerGradientLayer = CAGradientLayer()
    let imageView = UIImageView()
    let imageButton = UIButton()
    private let disposeBag = DisposeBag()
    
    var parentVC: UIViewController?
    var device: Device? {
        didSet {
            DeviceUtility.setImage(in: imageView, with: device!)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        //添加渐变层
        cornerGradientLayer.setCornerGradientLayer(endColor: edsDefaultColor)
        layer.insertSublayer(cornerGradientLayer, at: 0)
        //默认View为黑色
        backgroundColor = .white
        addSubview(imageView)
        imageView.edgesToSuperview()
        imageView.contentMode = .scaleAspectFit

        addSubview(imageButton)
        imageButton.edges(to: imageView)
        imageButton.rx.tap.bind(onNext: {
            self.showPicker()
        }).disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        //渐变层需要约束frame
        cornerGradientLayer.frame = bounds
    }

    private func showPicker() {
        var config = YPImagePickerConfiguration()
        //关闭滤镜，16:9裁剪，限制图片上传尺寸，不将裁减图片保存本地
        config.showsPhotoFilters = false
        config.showsCrop = .rectangle(ratio: 16 / 9)
        config.targetImageSize = .cappedTo(size: 1024)
        config.shouldSaveNewPicturesToAlbum = false
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto?.image {

                self.imageView.image = photo
                self.imageView.contentMode = .scaleAspectFill
                let imageID = User.tempInstance.generateImageID()
                let moyaProvider = MoyaProvider<EDSService>()
                moyaProvider.request(.upload(data: photo.pngData()!, fileName: imageID)) { response in
                    switch(response) {
                    case .success:
                        if let device = self.device {
                            device.image = imageID
                            moyaProvider.request(.updateDevice(device: device)) { _ in }
                            print("upload device image success")
                        }
                    default:
                        break
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        parentVC?.navigationController?.present(picker, animated: true, completion: nil)
    }

}
