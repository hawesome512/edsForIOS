//
//  AboutController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/5.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class AboutController: UIViewController {

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        title = "aboutEDS".localize()
        view.backgroundColor = .white

        let imageView = UIImageView()
        imageView.image = UIImage(named: "eds")
        imageView.layer.cornerRadius = edsLargeImageSize / 8
        imageView.layer.masksToBounds = true
        view.addSubview(imageView)
        imageView.width(edsLargeImageSize)
        imageView.height(edsLargeImageSize)
        imageView.centerInSuperview(offset: CGPoint(x: 0, y: -edsLargeImageSize / 2))

        let versionLabel = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "V \(version)"
        }
        versionLabel.textColor = edsDefaultColor
        versionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(versionLabel)
        versionLabel.centerXToSuperview()
        versionLabel.topToBottom(of: imageView, offset: edsMinSpace)

        let descriptionLabel = UILabel()
        descriptionLabel.text = "aboutDescription".localize()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        view.addSubview(descriptionLabel)
        descriptionLabel.topToBottom(of: versionLabel, offset: edsMinSpace)
        descriptionLabel.horizontalToSuperview(insets: .horizontal(edsSpace))

        let moreButton = UIButton()
        moreButton.rx.tap.bind(onNext: {
            let path = "EDS电力配电系统.pdf".getEDSServletWorkorderDocUrl()
            ShareUtility.openWeb(path)
        }).disposed(by: disposeBag)
        moreButton.setAttributedTitle(NSAttributedString(string: "aboutMore".localize(), attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.foregroundColor: edsDefaultColor
        ]), for: .normal)
        moreButton.tintColor = edsDefaultColor
        view.addSubview(moreButton)
        moreButton.topToBottom(of: descriptionLabel)
        moreButton.centerX(to: descriptionLabel)

        let companyLabel = UILabel()
        companyLabel.text = String(format: "aboutCompany".localize(), Date().year)
        companyLabel.textAlignment = .center
        companyLabel.numberOfLines = 0
        companyLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        companyLabel.textColor = .systemGray
        view.addSubview(companyLabel)
        companyLabel.horizontalToSuperview(insets: .horizontal(edsSpace))
        companyLabel.bottomToSuperview(offset: -edsSpace, usingSafeArea: true)
    }

}
