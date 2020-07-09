//
//  ParamSliderController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/7/8.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import fluid_slider
import RxSwift

class ParamSliderController: UIViewController, UITextFieldDelegate {
    
    private let disposeBag = DisposeBag()
    private let valueFont = UIFont.preferredFont(forTextStyle: .headline)
    private let slider = Slider()
    private let titleLabel = UILabel()
    private let updateButton = UIButton()
    private let editButton = UIButton()
    private let authorityLabel = UILabel()
    private var feedbackGenerator: UISelectionFeedbackGenerator?
    
    private var tag: Tag?
    private var sliderValue = ""
    private var pageItem: DevicePageItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initViews()
    }
    
    private func initViews(){
        view.backgroundColor = .systemBackground
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.textColor = edsDefaultColor
        view.addSubview(titleLabel)
        titleLabel.leadingToSuperview(offset: edsSpace)
        titleLabel.topToSuperview(offset: edsSpace,usingSafeArea: true)
        
        slider.shadowOffset = CGSize(width: 0, height: 10)
        slider.shadowBlur = 5
        slider.shadowColor = UIColor(white: 0, alpha: 0.1)
        slider.contentViewColor = UIColor.systemRed
        slider.valueViewColor = .systemBackground
        slider.didBeginTracking = { [weak self] _ in
            self?.feedbackGenerator = UISelectionFeedbackGenerator()
            self?.feedbackGenerator?.prepare()
        }
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        slider.didEndTracking = { [weak self] _ in
            self?.feedbackGenerator = nil
        }
        view.addSubview(slider)
        slider.horizontalToSuperview(insets: .horizontal(edsSpace))
        slider.centerInSuperview()
        slider.height(60)
        
        updateButton.setTitle("update".localize(), for: .normal)
        updateButton.backgroundColor = edsDefaultColor
        updateButton.setTitleColor(UIColor.white, for: .normal)
        updateButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        updateButton.layer.cornerRadius = 60/2
        view.addSubview(updateButton)
        updateButton.height(60)
        updateButton.horizontalToSuperview(insets: .horizontal(edsSpace))
        updateButton.bottomToSuperview(offset: -edsSpace, usingSafeArea: true)
        
        authorityLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        authorityLabel.textColor = UIColor.secondaryLabel
        view.addSubview(authorityLabel)
        authorityLabel.horizontalToSuperview(insets: .horizontal(edsSpace))
        authorityLabel.bottomToTop(of: updateButton, offset: -edsSpace)
        
        editButton.tintColor = .secondaryLabel
        editButton.setBackgroundImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        editButton.rx.tap.bind(onNext: {
            guard let items = self.pageItem?.items, items.count == 4 else { return }
            let title = self.titleLabel.text ?? ""
            let placeholder = String(format: "stepArrayTip".localize(), items[1],items[3],items[2])
            let inputVC = ControllerUtility.generateInputAlertController(title: title, placeholder: placeholder, delegate: self)
            let confirmAction = UIAlertAction(title: "confirm".localize(), style: .default, handler: {_ in
                guard let input = inputVC.textFields?.first?.text, let newValue = Double(input) else { return }
                let doubleItems = items.suffix(from: 1).map{ Double($0) ?? 1}
                let inSteps = (newValue - doubleItems[0]).truncatingRemainder(dividingBy: doubleItems[1]) == 0
                guard newValue >= doubleItems[0], newValue <= doubleItems[2], inSteps else {
                    let alert = "stepInputError".localize()
                    ControllerUtility.presentAlertController(content: alert, controller: self)
                    return
                }
                self.sliderValue = input
                self.update()
            })
            inputVC.addAction(confirmAction)
            self.present(inputVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        view.addSubview(editButton)
        editButton.leadingToTrailing(of: titleLabel,offset: edsMinSpace)
        editButton.centerY(to: titleLabel)
        editButton.width(edsIconSize)
        editButton.height(edsIconSize)
    }
    
    func initViews(with pageItem: DevicePageItem, tag: Tag, authority: AuthorityResult) {
        self.tag = tag
        self.pageItem = pageItem
        //等差数列,["*","0","0.1","10"],此处使用Decimal防止出现Double计算的各种混乱
        guard let items = pageItem.items, items.count == 4, items[0] == DeviceModel.itemStepArray else { return }
        let decItems = items.suffix(from: 1).map { Decimal(string: $0) ?? 1}
        let count = (decItems[2] - decItems[0])/decItems[1] as NSNumber
        
        let attrs: [NSAttributedString.Key : Any] = [.font: valueFont, .foregroundColor: UIColor.systemBackground]
        slider.setMinimumLabelAttributedText(NSAttributedString(string: items[1], attributes: attrs))
        slider.setMaximumLabelAttributedText(NSAttributedString(string: items[3], attributes: attrs))
        slider.attributedTextForFraction = { fraction in
            let index = roundf((fraction as NSNumber).floatValue * count.floatValue) as NSNumber
            self.sliderValue = ((decItems[0] + index.decimalValue * decItems[1]) as NSNumber).stringValue
            return NSAttributedString(string: self.sliderValue, attributes: [.font: self.valueFont, .foregroundColor: UIColor.label])
        }

        tag.showValue.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: {tagValue in
            self.titleLabel.text = pageItem.name.localize() + ":\(tagValue.clean.toLocalNumber())"
            let value = ((Decimal(tagValue) - decItems[0])/(decItems[2] - decItems[0])) as NSNumber
            self.slider.fraction = CGFloat(value.floatValue)
            if authority == .granted {
                self.updateButton.isEnabled = true
                self.updateButton.alpha = 1
            }
        }).disposed(by: disposeBag)

        updateButton.rx.tap.throttle(.seconds(3), scheduler: MainScheduler.instance).subscribe({ _ in
            self.update()
        }).disposed(by: disposeBag)

        switch authority {
        case .granted:
            authorityLabel.text = nil
            updateButton.isEnabled = true
            updateButton.alpha = 1
            slider.isEnabled = true
            editButton.alpha = 1
        default:
            authorityLabel.text = authority.rawValue.localize()
            updateButton.isEnabled = false
            updateButton.alpha = 0.5
            slider.isEnabled = false
            editButton.alpha = 0
        }

    }
    
    @objc func valueChanged(){
        feedbackGenerator?.selectionChanged()
    }
    
    func update() {
        guard let tag = tag, let pageItem = pageItem, let authority = AccountUtility.sharedInstance.account?.authority else { return }
        guard sliderValue != tag.Value else { return }
        let newTag = Tag(name: tag.Name, value: sliderValue)
        self.updateButton.isEnabled = false
        self.updateButton.alpha = 0.5
        WAService.getProvider().request(.setTagValues(authority: authority, tagList: [newTag])) { result in
            switch result {
            case .success(let response):
                guard JsonUtility.didSettedValues(data: response.data) else { return }
                print("update \(newTag.Name) value to \(newTag.Value!):true")
                let device = DeviceUtility.sharedInstance.getDevice(of: tag.getDeviceName())?.title
                let log = "\(device!) \(pageItem.name.localize()):\(self.sliderValue)"
                ActionUtility.sharedInstance.addAction(.paramDevice, extra: log)
            default:
                break
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
