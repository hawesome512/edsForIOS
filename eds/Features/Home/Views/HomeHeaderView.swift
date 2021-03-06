//
//  HomeHeaderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/9.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import YPImagePicker
import Moya

class HomeHeaderView: UIView, UITextFieldDelegate {
    
    private let disposeBag = DisposeBag()
    //选择图片后马上会触发parentVC.willAppear>basic.didSet>重新按basic设定图片，此时self.bannerImage.setImage(photo, for: .normal)将被覆盖
    private var pickedImage: UIImage?
    private let defaultImage = UIImage(named: "banner_default")
    
    let imageButton = UIButton()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let locationButton = UIButton()
    let noticeButton = UIButton()
    let noticeLabel = UILabel()
    var parentVC: UIViewController?
    
    private var basic:Basic?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        BasicUtility.sharedInstance.successfulBasicInfoUpdated
            .throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: { result in
            self.initData(result)
        }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initData(_ result: Bool?){
        guard result == true, let basic = BasicUtility.sharedInstance.getBasic() else { return }
        self.basic = basic
        titleLabel.text = basic.user
        if let notice = Notice.getNotice(with: basic.notice) {
            noticeLabel.text = notice.message
        } else {
            noticeLabel.text = ""
        }
        if pickedImage == nil {
            let banner = basic.banner
            ViewUtility.setWebImage(in: imageView, photo: banner, download: .both, disposeBag: disposeBag, contentMode: .scaleAspectFill)
        } else {
            imageView.image = pickedImage
        }
    }
    
    private func initViews() {
        
        imageView.image = UIImage(named: "banner_default")
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.edgesToSuperview()
        
        imageButton.rx.tap.bind(onNext: {
            self.showMenu()
        }).disposed(by: disposeBag)
        addSubview(imageButton)
        imageButton.edgesToSuperview()
        
        noticeLabel.textColor = .systemYellow
        noticeLabel.textAlignment = .right
        addSubview(noticeLabel)
        noticeLabel.bottomToSuperview(offset: -edsMinSpace)
        noticeLabel.horizontalToSuperview(insets: .horizontal(edsSpace))
        
        //        titleLabel.text = "厦门士林电机"
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        addSubview(titleLabel)
        titleLabel.leadingToSuperview(offset: edsSpace)
        titleLabel.bottomToTop(of: noticeLabel, offset: -edsMinSpace)
        
        noticeButton.setBackgroundImage(UIImage(systemName: "speaker.2"), for: .normal)
        noticeButton.tintColor = .white
        addSubview(noticeButton)
        noticeButton.width(edsIconSize)
        noticeButton.height(edsIconSize)
        noticeButton.trailingToSuperview(offset: edsSpace)
        noticeButton.centerY(to: titleLabel)
        noticeButton.rx.tap.bind(onNext: {
            let noticeVC = NoticeController()
            noticeVC.hidesBottomBarWhenPushed = true
            self.parentVC?.navigationController?.pushViewController(noticeVC, animated: true)
        }).disposed(by: disposeBag)
        
        locationButton.tintColor = .white
        locationButton.setBackgroundImage(UIImage(named: "location")?.withTintColor(.white), for: .normal)
        addSubview(locationButton)
        locationButton.width(edsIconSize)
        locationButton.height(edsIconSize)
        locationButton.leadingToTrailing(of: titleLabel, offset: edsMinSpace)
        locationButton.trailingToLeading(of: noticeButton, offset: -edsSpace, relation: .equalOrLess)
        locationButton.centerY(to: titleLabel)
        locationButton.rx.tap.bind(onNext: {
            let mapVC = MapController()
            mapVC.hidesBottomBarWhenPushed = true
            self.parentVC?.navigationController?.pushViewController(mapVC, animated: true)
        }).disposed(by: disposeBag)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    private func showMenu(){
        guard AccountUtility.sharedInstance.isOperable() else {
            return
        }
        //编辑弹出菜单
        let menuVC = UIAlertController(title: "edit".localize(), message: nil, preferredStyle: .actionSheet)
        //头图
        let imageAction = UIAlertAction(title: "banner".localize(with: prefixHome), style: .default, handler: { _ in
            let pickerVC = ControllerUtility.generateImagePicker(maxCount: 1, showCrop: true)
            pickerVC.didFinishPicking(completion: { [unowned pickerVC] items, _ in
                if let photo = items.singlePhoto?.image {
                    self.pickedImage = photo
                    let imageID = AccountUtility.sharedInstance.generateImageID()
                    EDSService.getProvider().request(.upload(data: photo.pngData()!, fileName: imageID)) { response in
                        switch(response) {
                        case .success:
                            BasicUtility.sharedInstance.updateBanner(imageID)
                        default:
                            break
                        }
                    }
                }
                pickerVC.dismiss(animated: true, completion: nil) })
            self.parentVC?.present(pickerVC, animated: true, completion: nil)
        })
        //标题
        let title = "title".localize(with: prefixHome)
        let titleAction = UIAlertAction(title: title, style: .default, handler: { _ in
            let titleVC = ControllerUtility.generateInputAlertController(title: title, placeholder: self.basic?.user, delegate: self)
            let textField = titleVC.textFields?.first
            let confirmAction = UIAlertAction(title: "confirm".localize(), style: .default, handler: { _ in
                if let newTitle = textField?.text, !newTitle.isEmpty {
                    BasicUtility.sharedInstance.updateUser(newTitle)
                    self.titleLabel.text = newTitle
                }
            })
            titleVC.addAction(confirmAction)
            self.parentVC?.present(titleVC, animated: true, completion: nil)
        })
        //地址
        let location = "location".localize(with: prefixHome)
        let locationAction = UIAlertAction(title: location, style: .default, handler: { _ in
            let locationVC = ControllerUtility.generateInputAlertController(title: location, placeholder: self.basic?.location, delegate: self)
            let textField = locationVC.textFields?.first
            let confirmAction = UIAlertAction(title: "confirm".localize(), style: .default, handler: { _ in
                if let newLoc = textField?.text, !newLoc.isEmpty {
                    BasicUtility.sharedInstance.updateLocation(newLoc)
                }
            })
            locationVC.addAction(confirmAction)
            self.parentVC?.present(locationVC, animated: true, completion: nil)
        })
        //取消
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        menuVC.addAction(imageAction)
        menuVC.addAction(titleAction)
        menuVC.addAction(locationAction)
        menuVC.addAction(cancelAction)
        if let ppc = menuVC.popoverPresentationController {
            ppc.sourceView = self
            ppc.sourceRect = self.bounds
        }
        self.parentVC?.present(menuVC, animated: true, completion: nil)
    }
    
}
