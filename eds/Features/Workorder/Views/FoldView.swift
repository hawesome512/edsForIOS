//
//  FoldView.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class FoldView: UIView {

    var folded = true {
        didSet {
            setImage()
        }
    }

    static let limitCount = 3
    var totalCount = 0
    let foldButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        tintColor = edsDefaultColor
        addSubview(foldButton)
        foldButton.width(edsIconSize)
        foldButton.height(edsIconSize)
        foldButton.centerXToSuperview()
        setImage()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setImage() {
        let image = folded ? "chevron.compact.down" : "chevron.compact.up"
        foldButton.setBackgroundImage(UIImage(systemName: image), for: .normal)
    }

    func getRowNumber() -> Int {
        return folded ? min(FoldView.limitCount, totalCount) : totalCount
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
