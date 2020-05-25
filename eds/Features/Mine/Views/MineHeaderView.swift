//
//  MineHeaderView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/29.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
import Moya

class MineHeaderView: UIView, UITextFieldDelegate {

    private let disposeBag = DisposeBag()
    private var profileTopConstraint: NSLayoutConstraint?

    let nameLabel = UILabel()
    let profileImage = UIImageView()
    let levelLabel = UILabel()
    let phoneLabel = UILabel()
    let phoneImage = UIImageView()
    let emailLabel = UILabel()
    let emailImage = UIImageView()
    let levelImage = UIImageView()

    var loginedPhone: Phone? {
        didSet {
            guard let phone = self.loginedPhone else {
                return
            }
            let profileURL = phone.photo.getEDSServletImageUrl()
            ViewUtility.setWebImage(in: profileImage, with: profileURL, disposeBag: disposeBag,placeholder: UIImage(named: "eds"))
            nameLabel.text = phone.name
            levelLabel.text = phone.level.getText()
            levelImage.image = phone.level.getIcon()?.withTintColor(.white, renderingMode: .alwaysTemplate)
            phoneLabel.text = phone.number
            emailLabel.text = phone.email
            if phone.level == .systemAdmin || phone.level == .qrcodeObserver {
                phoneLabel.alpha = 0
                emailLabel.alpha = 0
                phoneImage.alpha = 0
                emailImage.alpha = 0
            }
        }
    }
    var parentVC: UIViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        let bgImage = UIButton()
        bgImage.rx.tap.bind(onNext: {
            self.showEditVC()
        }).disposed(by: disposeBag)
        bgImage.setImage(UIImage(named: "banner_default"), for: .normal)
        bgImage.imageView?.contentMode = .scaleAspectFill
        addSubview(bgImage)
        bgImage.edgesToSuperview()

        profileImage.image = UIImage(named: "eds")
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.borderWidth = 2
        addSubview(profileImage)
        profileImage.heightToSuperview(multiplier: 0.4)
        profileImage.widthToHeight(of: profileImage)
//        profileImage.topToSuperview(usingSafeArea: true)
        //TinyConstraint未找到相关用法：后台动态约束
        profileTopConstraint = profileImage.topAnchor.constraint(equalTo: profileImage.superview!.topAnchor)
        profileTopConstraint?.isActive = true
        profileImage.centerXToSuperview()

        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(bottomView)
        bottomView.edgesToSuperview(excluding: .top)
        bottomView.height(70)

        levelImage.image = UserLevel.qrcodeObserver.getIcon()
        levelImage.contentMode = .scaleAspectFit
        levelImage.tintColor = .white
        bottomView.addSubview(levelImage)
        levelImage.width(edsHeight)
        levelImage.height(edsHeight)
        levelImage.centerYToSuperview()
        levelImage.leadingToSuperview(offset: edsMinSpace)

        levelLabel.text = UserLevel.qrcodeObserver.getText()
        levelLabel.textColor = .white
        levelLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        bottomView.addSubview(levelLabel)
        levelLabel.leadingToTrailing(of: levelImage)
        levelLabel.centerYToSuperview()

        emailLabel.text = "shihlineds@xseec.cn"
        emailLabel.textColor = .white
        emailLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        bottomView.addSubview(emailLabel)
        emailLabel.trailingToSuperview(offset: edsMinSpace)
        emailLabel.bottomToSuperview(offset: -edsMinSpace)

        emailImage.image = UIImage(systemName: "envelope")
        emailImage.contentMode = .scaleAspectFit
        emailImage.tintColor = .white
        bottomView.addSubview(emailImage)
        emailImage.centerY(to: emailLabel)
        emailImage.trailingToLeading(of: emailLabel, offset: -edsMinSpace)
        emailImage.width(edsSpace)
        emailImage.height(edsSpace)

        phoneLabel.text = "18700000000"
        phoneLabel.textColor = .white
        phoneLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        bottomView.addSubview(phoneLabel)
        phoneLabel.topToSuperview(offset: edsMinSpace)
        phoneLabel.leading(to: emailLabel)

        phoneImage.image = UIImage(systemName: "phone")
        phoneImage.tintColor = .white
        bottomView.addSubview(phoneImage)
        phoneImage.width(edsSpace)
        phoneImage.height(edsSpace)
        phoneImage.centerX(to: emailImage)
        phoneImage.centerY(to: phoneLabel)

        nameLabel.text = "XSEEC"
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        nameLabel.adjustsFontSizeToFitWidth = true
        addSubview(nameLabel)
        nameLabel.centerXToSuperview()
        nameLabel.bottomToTop(of: bottomView)//, offset: -edsMinSpace)
        nameLabel.topToBottom(of: profileImage)
        nameLabel.trailingToLeading(of: emailImage, offset: edsMinSpace, relation: .equalOrGreater)
    }

    override func draw(_ rect: CGRect) {
        let statusHeight = parentVC?.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        profileTopConstraint?.constant = statusHeight + edsMinSpace
        let radius = profileImage.bounds.height / 2
        profileImage.layer.cornerRadius = radius
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    func showEditVC() {
        //系统管理员/临时的手机身份是虚拟生成的，无法编辑
        guard loginedPhone?.level != .systemAdmin, loginedPhone?.level != .qrcodeObserver else {
            return
        }
        let menuVC = UIAlertController(title: "edit".localize(), message: nil, preferredStyle: .actionSheet)
        let confirm = "confirm".localize()
        //头像
        let profile = "profile".localize()
        let profileAction = UIAlertAction(title: profile, style: .default, handler: { _ in
            let pickerVC = ControllerUtility.generateImagePicker(maxCount: 1)
            pickerVC.didFinishPicking(completion: { [unowned pickerVC] items, _ in
                if let photo = items.singlePhoto?.image {
                    self.profileImage.image = photo
                    let imageID = AccountUtility.sharedInstance.generateImageID()
                    EDSService.getProvider().request(.upload(data: photo.pngData()!, fileName: imageID)) { response in
                        switch(response) {
                        case .success:
                            //上传头像成功
                            self.loginedPhone?.photo = imageID
                            AccountUtility.sharedInstance.updatePhone()
                            ActionUtility.sharedInstance.addAction(.editPerson)
                        default:
                            break
                        }
                    }
                }
                pickerVC.dismiss(animated: true, completion: nil) })
            self.parentVC?.present(pickerVC, animated: true, completion: nil)
        })
        //用户名
        let username = "username".localize()
        let nameAction = UIAlertAction(title: username, style: .default, handler: { _ in
            let editVC = ControllerUtility.generateInputAlertController(title: username, placeholder: self.loginedPhone?.name, delegate: self)
            let confirmAction = UIAlertAction(title: confirm, style: .default, handler: { _ in
                if let newValue = editVC.textFields?.first?.text, !newValue.isEmpty {
                    self.loginedPhone?.name = newValue
                    self.nameLabel.text = newValue
                    AccountUtility.sharedInstance.updatePhone()
                    ActionUtility.sharedInstance.addAction(.editPerson)
                }
            })
            editVC.addAction(confirmAction)
            self.parentVC?.present(editVC, animated: true, completion: nil)
        })
        //电话
        let phone = "phone".localize()
        let phoneAction = UIAlertAction(title: phone, style: .default, handler: { _ in
            let editVC = ControllerUtility.generateInputAlertController(title: phone, placeholder: self.loginedPhone?.number, delegate: self)
            let confirmAction = UIAlertAction(title: confirm, style: .default, handler: { _ in
                if let newValue = editVC.textFields?.first?.text, !newValue.isEmpty {
                    self.loginedPhone?.number = newValue
                    self.phoneLabel.text = newValue
                    AccountUtility.sharedInstance.updatePhone()
                    ActionUtility.sharedInstance.addAction(.editPerson)
                }
            })
            editVC.addAction(confirmAction)
            self.parentVC?.present(editVC, animated: true, completion: nil)
        })
        //邮箱
        let email = "email".localize()
        let emailAction = UIAlertAction(title: email, style: .default, handler: { _ in
            let editVC = ControllerUtility.generateInputAlertController(title: email, placeholder: self.loginedPhone?.email, delegate: self)
            let confirmAction = UIAlertAction(title: confirm, style: .default, handler: { _ in
                if let newValue = editVC.textFields?.first?.text, !newValue.isEmpty {
                    self.loginedPhone?.email = newValue
                    self.emailLabel.text = newValue
                    AccountUtility.sharedInstance.updatePhone()
                    ActionUtility.sharedInstance.addAction(.editPerson)
                }
            })
            editVC.addAction(confirmAction)
            self.parentVC?.present(editVC, animated: true, completion: nil)
        })
        //取消
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)

        menuVC.addAction(profileAction)
        menuVC.addAction(nameAction)
        menuVC.addAction(phoneAction)
        menuVC.addAction(emailAction)
        menuVC.addAction(cancelAction)
        if let ppc = menuVC.popoverPresentationController {
            ppc.sourceView = self
            ppc.sourceRect = self.bounds
        }
        self.parentVC?.present(menuVC, animated: true, completion: nil)
    }

}
