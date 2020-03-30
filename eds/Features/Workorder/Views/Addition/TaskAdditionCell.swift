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

    let textField = KaedeTextField()
    private let addButton = UIButton()
    private let disposeBag = DisposeBag()

    var delegate: TaskAdditionCellDelegate?

    var title: String? {
        didSet {
            textField.placeholder = title
        }
    }

    private func initViews() {
        addButton.rx.tap.bind(onNext: {
            self.addItem()
        }).disposed(by: disposeBag)
        addButton.tintColor = edsDefaultColor
        addButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addSubview(addButton)
        addButton.width(28)
        addButton.height(28)
        addButton.centerYToSuperview()
        addButton.leadingToSuperview(offset: 20)

        textField.placeholderFontScale = 1
        textField.tintColor = .white
        textField.textColor = .white
        textField.placeholderColor = .systemGray
        textField.backgroundColor = edsDefaultColor
        textField.foregroundColor = edsDivideColor
        textField.font = UIFont.preferredFont(forTextStyle: .title3)
        addSubview(textField)
        textField.trailingToSuperview(offset: edsSpace)
        textField.leadingToTrailing(of: addButton, offset: edsMinSpace)
        textField.verticalToSuperview(insets: .vertical(0))
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.delegate = self
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
        addItem()
        return true
    }

    func addItem() {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            delegate?.addItem(text: text)
            textField.text = nil
        }
    }

}
