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

class DeviceHeaderView: UIView, UITextFieldDelegate {

    private let cornerGradientLayer = CAGradientLayer()
    private let indicatorVIew = UIActivityIndicatorView()
    let imageView = UIImageView()
    let imageButton = UIButton()
    private let disposeBag = DisposeBag()

    var parentVC: UIViewController?
    var device: Device? {
        didSet {
            guard let device = device else { return }
            ViewUtility.setWebImage(in: imageView, photo: device.image, small: true, disposeBag: disposeBag, placeholder: device.getDefaultImage(), contentMode: .scaleAspectFill)
//            DeviceUtility.setImage(in: imageView, with: device!)
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
        imageButton.edgesToSuperview()
        imageButton.rx.tap.bind(onNext: {
            guard AccountUtility.sharedInstance.isOperable() else {
                return
            }
            let menuVC = UIAlertController(title: "edit".localize(), message: nil, preferredStyle: .actionSheet)
            let photoAction = UIAlertAction(title: "home_banner".localize(), style: .default, handler: { _ in
                self.showPicker()
            })
            let titleAction = UIAlertAction(title: "home_title".localize(), style: .default, handler: { _ in
                self.showEdit()
            })
            let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
            menuVC.addAction(titleAction)
            menuVC.addAction(photoAction)
            menuVC.addAction(cancelAction)
            if let ppc = menuVC.popoverPresentationController {
                ppc.sourceView = self.imageButton
                ppc.sourceRect = self.imageButton.bounds
            }
            self.parentVC?.present(menuVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)

        indicatorVIew.style = .large
        indicatorVIew.color = .systemRed
        indicatorVIew.alpha = 0
        indicatorVIew.startAnimating()
        addSubview(indicatorVIew)
        indicatorVIew.centerInSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        //渐变层需要约束frame
        cornerGradientLayer.frame = bounds
    }

    private func showPicker() {
        let picker = ControllerUtility.generateImagePicker(maxCount: 1, showCrop: true)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto?.image {
                self.imageView.image = photo
                self.imageView.contentMode = .scaleAspectFill
                let imageID = AccountUtility.sharedInstance.generateImageID()
                self.indicatorVIew.alpha = 1
                EDSService.getProvider().request(.upload(data: photo.pngData()!, fileName: imageID)) { response in
                    self.indicatorVIew.alpha = 0
                    switch(response) {
                    case .success:
                        if let device = self.device {
                            print("upload device image success")
                            device.image = imageID
                            DeviceUtility.sharedInstance.update(device)
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

    private func showEdit() {
        let titleVC = ControllerUtility.generateInputAlertController(title: "home_title".localize(), placeholder: self.device?.title, delegate: self)
        let confirmAction = UIAlertAction(title: "confirm".localize(), style: .default, handler: { _ in
            //device.title为空，是删除device
            if let device = self.device, let title = titleVC.textFields?.first?.text, !title.isEmpty {
                device.title = title
                self.parentVC?.title = title
                DeviceUtility.sharedInstance.update(device)
            }
        })
        titleVC.addAction(confirmAction)
        self.parentVC?.present(titleVC, animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

}
