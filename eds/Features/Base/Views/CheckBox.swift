//
//  CheckBox.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/17.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CheckBox: UIButton {

    private let disposeBag = DisposeBag()

    override var isSelected: Bool {
        didSet {
            tintColor = isSelected ? UIColor.systemRed : UIColor.systemGray
            let image = isSelected ? "checkmark.square.fill" : "square"
            setBackgroundImage(UIImage(systemName: image), for: .normal)
            selectedState.accept(isSelected)
        }
    }
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                let scaleTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.transform = scaleTransform
                self.alpha = 0
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7, options: [], animations: {
                    self.transform = .identity
                    self.alpha = 1
                }, completion: nil)
            }
        }
    }
    var selectedState = BehaviorRelay<Bool>(value: false)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.rx.tap.bind(onNext: {
            self.isSelected = !self.isSelected
        }).disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
