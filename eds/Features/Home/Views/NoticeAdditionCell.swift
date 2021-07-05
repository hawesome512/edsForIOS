//
//  MessageAdditionCell.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/24.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import TextFieldEffects
import RxSwift

class NoticeAdditionCell: UITableViewCell, UITextFieldDelegate, PickerDelegate {

    let messageField = HoshiTextField()
    let dateField = HoshiTextField()
    let noticeButton = UIButton()
    var parentVC: UIViewController?

    private let textFont = UIFont.boldSystemFont(ofSize: 20)
    private let disposeBag = DisposeBag()
    private var pickedDate: Date?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {

        let titleLabel = UILabel()
        titleLabel.text = "notice_new".localize(with: prefixHome)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        contentView.addSubview(titleLabel)
        titleLabel.leadingToSuperview(offset: edsSpace)
        titleLabel.topToSuperview(offset: edsSpace)
        
        //用户从正在编辑的messageFiedld离开(未使用键盘上的.doneAction/完成)，点击了dateField，键盘将不会被正常关闭，使用以下方法处理
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        addGestureRecognizer(tapRecognizer)
        messageField.rx.controlEvent(.editingDidBegin).bind(onNext: {
            self.dateField.isUserInteractionEnabled = false
        }).disposed(by: disposeBag)
        messageField.rx.controlEvent(.editingDidEnd).bind(onNext: {
            self.dateField.isUserInteractionEnabled = true
            self.dateField.becomeFirstResponder()
        }).disposed(by: disposeBag)

        messageField.placeholder = "notice_message".localize(with: prefixHome)
        messageField.clearButtonMode = .whileEditing
        addTextField(messageField)
        messageField.topToBottom(of: titleLabel, offset: edsSpace)

        let timeText = "notice_time".localize(with: prefixHome)
        dateField.placeholder = timeText
        addTextField(dateField)
        dateField.topToBottom(of: messageField, offset: edsSpace)
        dateField.rx.controlEvent(.editingDidBegin).asObservable().bind(onNext: {
            //时间选择
            self.dateField.resignFirstResponder()
            let pickerVC = DatePickerController()
            pickerVC.items = [timeText]
            pickerVC.delegate = self
            self.parentVC?.present(pickerVC, animated: true, completion: nil)

        }).disposed(by: disposeBag)

        noticeButton.setTitle("notice_confirm".localize(with: prefixHome), for: .normal)
        noticeButton.tintColor = .white
        noticeButton.backgroundColor = edsDefaultColor
        noticeButton.rx.tap.bind(onNext: {
            //验证输入完整性
            guard let message = self.messageField.text, let date = self.dateField.text, !message.isEmpty, !date.isEmpty else {
                let msg = "notice_imcomplete".localize(with: prefixHome)
                let inputsVC = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok".localize(), style: .cancel, handler: nil)
                inputsVC.addAction(okAction)
                self.parentVC?.present(inputsVC, animated: true, completion: nil)
                return
            }
            let author = AccountUtility.sharedInstance.loginedPhone?.name ?? NIL
            var notice = Notice(message: message, author: author, deadline: self.pickedDate)
            BasicUtility.sharedInstance.updateNotice(notice.toString())
            ActionUtility.sharedInstance.addAction(.addNotice)
            self.parentVC?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        contentView.addSubview(noticeButton)
        noticeButton.height(60)
        noticeButton.horizontalToSuperview(insets: .horizontal(edsSpace))
        noticeButton.topToBottom(of: dateField, offset: edsSpace)
        noticeButton.bottomToSuperview(offset: -edsSpace)
    }

    private func addTextField(_ textField: HoshiTextField) {
        textField.placeholderColor = .systemGray
        textField.placeholderFontScale = 1
        textField.borderActiveColor = edsDefaultColor
        textField.borderInactiveColor = .systemGray
        textField.borderStyle = .bezel
        textField.font = textFont
        textField.delegate = self
        contentView.addSubview(textField)
        textField.height(60)
        textField.horizontalToSuperview(insets: .horizontal(edsSpace))
        textField.clearButtonMode = .unlessEditing
        textField.returnKeyType = .done
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    func picked(results: [Date]) {
        dateField.text = results.first?.toDateString()
        pickedDate = results.first
    }

    func pickerCanceled() {

    }

}
