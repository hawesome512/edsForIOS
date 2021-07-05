//
//  TaskAdditionCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/27.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import TextFieldEffects

protocol TaskAdditionCellDelegate {
    func addItem(text: String)
}

class TaskAdditionCell: UITableViewCell, UITextFieldDelegate {

//    let textField = KaedeTextField()
    private let addButton = UIButton()
    private let disposeBag = DisposeBag()

    var delegate: TaskAdditionCellDelegate?
    var parentVC: UIViewController?

    private func initViews() {
        let title = "add_task".localize(with: prefixWorkorder)
        addButton.rx.tap.bind(onNext: {
            let inputVC = ControllerUtility.generateInputAlertController(title: title, placeholder: nil, delegate: self)
            let confirmAction = UIAlertAction(title: "confirm".localize(), style: .default, handler: {_ in
                guard let input = inputVC.textFields?.first?.text else { return }
                self.delegate?.addItem(text: input)
            })
            inputVC.addAction(confirmAction)
            self.parentVC?.present(inputVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        addButton.contentHorizontalAlignment = .left
        addButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: edsSpace*2, bottom: 0, right: 0)
        addButton.setTitle(title, for: .normal)
        addButton.setTitleColor(edsDefaultColor, for: .normal)
        contentView.addSubview(addButton)
        addButton.verticalToSuperview()
        addButton.horizontalToSuperview(insets: .horizontal(edsSpace))
        
        let imageView = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        addButton.addSubview(imageView)
        imageView.leadingToSuperview()
        imageView.heightToSuperview(multiplier: 2/3)
        imageView.centerYToSuperview()
        imageView.widthToHeight(of: imageView)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

}
