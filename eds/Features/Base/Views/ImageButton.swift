//
//  ImageButton.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/6.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class ImageButton: UIButton {

    private let contentImage = UIImageView()
    private let contentLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        contentImage.contentMode = .scaleAspectFit
        contentImage.tintColor = .white
        addSubview(contentImage)
        contentImage.verticalToSuperview(insets: .vertical(edsMinSpace))
        contentImage.widthToHeight(of: contentImage)
        contentImage.leadingToSuperview()

        contentLabel.textAlignment = .right
        contentLabel.textColor = .white
        contentLabel.font = UIFont.preferredFont(forTextStyle: .title1) //UIFont.boldSystemFont(ofSize: 34)
        contentLabel.adjustsFontSizeToFitWidth = true
        addSubview(contentLabel)
        contentLabel.edgesToSuperview(excluding: .left, insets: .uniform(edsMinSpace))
        contentLabel.leadingToTrailing(of: contentImage, offset: edsMinSpace)
    }

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        contentImage.image = image?.withRenderingMode(.alwaysTemplate)
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        contentLabel.text = title
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
