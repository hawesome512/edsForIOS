//
//  WorkorderViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import YPImagePicker
import Kingfisher
import Moya
import CallKit
import MessageUI

class WorkorderController: UIViewController {
    
    private var flows: [WorkorderFlow] = []
    private var tasks: [WorkorderTask] = []
    private var messages: [WorkorderMessage] = []
    private var infos: [WorkorderInfo] = []
    private var photoSource = PhotoSource()
    
    private let tableView = UITableView()
    private let progressView = UIProgressView()
    private var progressCount = 0
    
    //任务/留言太多时折叠处理
    private var foldViews: [WorkorderSectionType: FoldView] = [.task: FoldView(), .message: FoldView()]
    private let disposeBag = DisposeBag()
    
    //电话派发工单，监听电话接通状态
    private let callObserver = CXCallObserver()
    
    //执行
    private let executeBarIndex = 2
    private var executing = false {
        didSet {
            executedState.accept(executing)
        }
    }
    //执行保存（图片）过程的指示器
    private let indicator = UIActivityIndicatorView(style: .medium)
    private var executedState = BehaviorRelay<Bool>(value: false)
    private let accountName = AccountUtility.sharedInstance.loginedPhone?.name ?? NIL
    
    var workorder: Workorder? {
        didSet {
            guard let workorder = workorder else { return }
            title = workorder.title
            flows = workorder.getFlows()
            tasks = workorder.getTasks()
            messages = workorder.getMessages()
            infos = workorder.getInfos()
            photoSource.webUrls = workorder.getImageURLs()
            
            initFoldView(type: .task, total: tasks.count)
            initFoldView(type: .message, total: messages.count)
        }
    }
    
    private func initFoldView(type: WorkorderSectionType, total: Int) {
        guard let view = foldViews[type] else { return }
        //任务清单的count保持不变，但留言可以增减，需更新totalCount
        view.totalCount = total
        view.foldButton.rx.tap.bind(onNext: {
            view.folded = !view.folded
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initBarItems()
    }
    
    private func initViews() {
        
        callObserver.setDelegate(self, queue: DispatchQueue.main)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.edgesToSuperview()
        
        progressView.progressTintColor = .systemRed
        navigationController?.toolbar.addSubview(progressView)
        progressView.edgesToSuperview(excluding: .bottom)
        progressView.height(4)
        
        indicator.startAnimating()
        
        //工单处于创建状态，执行人进入工单，自动新增已派发状态，可直接执行
        if workorder?.state == .created && workorder?.worker == accountName {
            workorder?.setState(with: .distributed, by: accountName)
        }
        
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(sharePage))
        let refreshBUtton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshWorkorder))
        navigationItem.rightBarButtonItems = [shareButton,refreshBUtton]
    }
    
    @objc func sharePage(){
        let image = QRCodeUtility.generate(with: .workorder, param: workorder!.id)
        let sourceView = navigationItem.rightBarButtonItem?.plainView
        ShareUtility.shareImage(image: image, controller: self, sourceView: sourceView ?? view)
    }
    
    @objc func refreshWorkorder(){
        guard let id = workorder?.id else { return }
        WorkorderUtility.sharedInstance.refreshWorkerorder(id)
        WorkorderUtility.sharedInstance.successfulRefresh.throttle(.seconds(1), scheduler: MainScheduler.instance).bind(onNext: {refresh in
            guard refresh == self.workorder else { return }
            self.workorder = refresh
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func initBarItems() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let distribute = UIBarButtonItem(title: WorkorderState.distributed.getText(), style: .plain, target: self, action: #selector(selectDistribution))
        let execute = UIBarButtonItem(title: WorkorderState.executed.getText(), style: .plain, target: self, action: #selector(executeWorkorder))
        let audit = UIBarButtonItem(title: WorkorderState.audited.getText(), style: .plain, target: self, action: #selector(auditWorkorder))
        let record = UIBarButtonItem(title: "message".localize(with: prefixWorkorder), style: .plain, target: self, action: #selector(leaveMessage))
        toolbarItems = [distribute, space, execute, space, audit, space, record]
        
        updateBarItems()
    }
    
    private func updateBarItems() {
        guard let state = workorder?.state else {
            return
        }
        let userLevel = AccountUtility.sharedInstance.loginedPhone?.level
        //尚未执行，所有人都可以派发
        toolbarItems?[0].isEnabled = (state.rawValue < WorkorderState.executed.rawValue && userLevel != UserLevel.qrcodeObserver)
        //必须是本人且尚未审核才可以执行
        toolbarItems?[2].isEnabled = (workorder!.worker == accountName && state.rawValue < WorkorderState.audited.rawValue)
        //必须是本人，且已执行的才可以审核
        toolbarItems?[4].isEnabled = (workorder!.auditor == accountName && state.rawValue == WorkorderState.executed.rawValue)
        //所有人都可以留言
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setToolbarHidden(false, animated: animated)
        navigationController?.toolbar.barStyle = .black
        navigationController?.toolbar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //结束后必须隐藏toolBar，否则前一个调用的vc底部将存在空白toolbar
        navigationController?.setToolbarHidden(true, animated: animated)
        navigationController?.toolbar.barStyle = .default
        navigationController?.toolbar.tintColor = edsDefaultColor
    }
    
}

extension WorkorderController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return WorkorderSectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = WorkorderSectionType(rawValue: section)!
        let view = SectionHeaderView()
        switch type {
        case .message:
            //e.g.:留言(10)
            view.title = type.getSectionTitle()! + "(\(messages.count))"
        case .task:
            view.title = type.getSectionTitle()! + "(\(tasks.count))"
        case .photo:
            view.title = type.getSectionTitle()! + "(\(photoSource.getTotal()))"
        default:
            view.title = type.getSectionTitle()
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let type = WorkorderSectionType(rawValue: section)!
        switch type {
        case .task, .message:
            return foldViews[type]!.getRowNumber()
        case .info:
            return infos.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = WorkorderSectionType(rawValue: indexPath.section)!
        switch type {
        case .state:
            let cell = WorkorderStateCell()
            cell.flows = flows
            return cell
        case .basic:
            let cell = WorkorderBasicCell()
            cell.workorder = workorder
            cell.viewController = self
            return cell
        case .task:
            let cell = WorkorderTaskCell()
            cell.task = tasks[indexPath.row]
            //非执行状态不可点击
            executedState.asObservable().bind(onNext: { executing in
                cell.checkBox.isEnabled = executing
            }).disposed(by: disposeBag)
            //将任务清单确认情况保存至tasks等待上传
            cell.checkBox.selectedState.asObservable().bind(onNext: { selected in
                self.tasks[indexPath.row].state = selected ? .checked : .unchecked
            }).disposed(by: disposeBag)
            return cell
        case .photo:
            let cell = WorkorderPhotoCollectionCell()
            cell.photoSource = photoSource
            cell.parentVC = self
            executedState.asObservable().bind(onNext: { executing in
                cell.executing = executing
            }).disposed(by: disposeBag)
            return cell
        case .info:
            let cell = WorkorderInfoCell()
            cell.info = infos[indexPath.row]
            return cell
        case .message:
            let cell = WorkorderMessageCell()
            let msg = messages[indexPath.row]
            cell.message = msg
            cell.delegate = self
            cell.parentVC = self
            //只可删除自己的留言
            cell.deleteButton.alpha = msg.name == accountName ? 1 : 0
            cell.levelImage.alpha = msg.name == workorder?.auditor ? 1 : 0
            return cell
        case .qrcode:
            let cell = FixedQRCodeCell()
            cell.qrImageView.image = QRCodeUtility.generate(with: .workorder, param: workorder?.id ?? NIL)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let type = WorkorderSectionType(rawValue: section)!
        switch type {
        case .task, .message:
            return foldViews[type]!
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let type = WorkorderSectionType(rawValue: section)!
        switch type {
        case .task, .message:
            return foldViews[type]!.getRowNumber() < FoldView.limitCount ? 0 : UITableView.automaticDimension
        default:
            return 0
        }
    }
}

// MARK: - 更新工单
extension WorkorderController {
    
    func updateWorkorder() {
        guard let workorder = workorder else {
            return
        }
        EDSService.getProvider().request(.updateWorkorder(workorder: workorder)) { result in
            
            self.progressView.progress = 0
            
            switch result {
            case .success(let response):
                if JsonUtility.didUpdatedEDSServiceSuccess(data: response.data) {
                    WorkorderUtility.sharedInstance.update(with: workorder)
                    self.flows = workorder.getFlows()
                    self.tableView.reloadData()
                    self.updateBarItems()
                }
            default:
                break
            }
        }
    }
}


// MARK: - 派发工单
extension WorkorderController: ShareDelegate, CXCallObserverDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    //派发方式选择界面：电话/短信/邮件/微信等等
    @objc func selectDistribution() {
        let shareVC = ShareController()
        shareVC.titleLabel.text = WorkorderState.distributed.getText()
        shareVC.delegate = self
        present(shareVC, animated: true, completion: nil)
    }
    
    //获取已选择的派发方式
    func share(with shareType: ShareType) {
        guard let workorder = workorder, let executor = AccountUtility.sharedInstance.getPhone(by: workorder.worker) else {
            return
        }
        let sentContent = String(format: "distribution".localize(with: prefixWorkorder), executor.name!, workorder.title, workorder.getShortTimeRange(), workorder.location, workorder.id)
        switch shareType {
        case .phone:
            ShareUtility.callPhone(to: executor.number!)
        case .sms:
            ShareUtility.sendSMS(to: executor.number!, with: sentContent, imageData: nil, in: self)
        case .mail:
            let imageData = QRCodeUtility.generate(with: .workorder, param: workorder.id)?.pngData()
            ShareUtility.sendMail(to: executor.email, title: "distribution_title".localize(with: prefixWorkorder), content: sentContent, imageData: imageData, in: self)
        }
    }
    
    //监听电话派发的状态
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        //已经接通电话，已经结束通话，电话派发工单成功
        if call.hasConnected && call.hasEnded {
            distributed()
        }
    }
    
    //短信派发状态
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //发送短信成功
        if result == .sent {
            distributed()
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    //邮件派发状态
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //发送邮件成功
        if result == .sent {
            distributed()
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    //派发成功
    func distributed() {
        ActionUtility.sharedInstance.addAction(.distributeWorkorder, extra: workorder?.title)
        //只有新建状态下的派发，才需要上传数据。其他即为二次派发
        guard workorder?.state == WorkorderState.created else {
            return
        }
        workorder?.setState(with: .distributed, by: accountName)
        updateWorkorder()
    }
}

//MARK: - 执行工单
extension WorkorderController {
    
    @objc func executeWorkorder() {
        if executing {
            uploadImages()
            ActionUtility.sharedInstance.addAction(.executeWorkorder, extra: workorder?.title)
        } else {
            //提醒保存执行
            let content = "save_alert".localize(with: prefixWorkorder)
            ControllerUtility.presentAlertController(content: content, controller: self)
            //不能直接更改title，只能替换
            let title = "save".localize()
            toolbarItems?[executeBarIndex] = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(executeWorkorder))
        }
        executing = !executing
    }
    
    func uploadImages() {
        //上传指示器
        toolbarItems?[executeBarIndex] = UIBarButtonItem(customView: indicator)
        progressCount = 0
        
        let indexPath = IndexPath(row: 0, section: WorkorderSectionType.photo.rawValue)
        let photoCell = tableView.cellForRow(at: indexPath)! as! WorkorderPhotoCollectionCell
        photoSource = photoCell.photoSource
        let images = photoSource.images
        guard images.count > 0 else {
            prepareUpdateWorkorder(uploadedImages: [])
            return
        }
        var uploadedImages: [(name: String, image: UIImage)] = []
        images.forEach { image in
            let fileName = AccountUtility.sharedInstance.generateImageID()
            EDSService.getProvider().request(.upload(data: image.pngData()!, fileName: fileName)) { result in
                switch result {
                case .success(let response):
                    if JsonUtility.didUpdatedEDSServiceSuccess(data: response.data) {
                        uploadedImages.append((fileName, image))
                    }
                default:
                    break
                }
                self.progressCount += 1
                self.progressView.progress = Float(self.progressCount) / Float(images.count + 1)
                if self.progressCount == images.count {
                    self.prepareUpdateWorkorder(uploadedImages: uploadedImages)
                }
            }
        }
    }
    
    func prepareUpdateWorkorder(uploadedImages: [(name: String, image: UIImage)]) {
        //更新工单任务和图片信息
        photoSource.images = uploadedImages.map { $0.image }
        var newImages = uploadedImages.map { $0.name }
        newImages.append(contentsOf: photoSource.webUrls)
        workorder?.setImages(newImages)
        workorder?.setTasks(tasks)
        workorder?.setState(with: .executed, by: accountName)
        updateWorkorder()
        
        let title = WorkorderState.executed.getText()
        toolbarItems?[executeBarIndex] = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(executeWorkorder))
    }
}

// MARK: - 审核&留言
extension WorkorderController: MessageDelegate, UITextFieldDelegate {
    
    
    @objc func auditWorkorder() {
        let title = "audit_title".localize(with: prefixWorkorder)
        let content = "audit_alert".localize(with: prefixWorkorder)
        let auditVC=UIAlertController(title: title, message: content, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel".localize(), style: .cancel, handler: nil)
        let auditAction = UIAlertAction(title: "audited".localize(with: prefixWorkorder), style: .default, handler: {_ in
            self.workorder?.setState(with: .audited, by: self.accountName)
            self.updateWorkorder()
            ActionUtility.sharedInstance.addAction(.auditeWorkorder, extra: self.workorder?.title)
        })
        auditVC.addAction(cancelAction)
        auditVC.addAction(auditAction)
        present(auditVC, animated: true, completion: nil)
    }
    
    @objc func leaveMessage() {
        let title = "message".localize(with: prefixWorkorder)
        let msgVC = ControllerUtility.generateInputAlertController(title: title, placeholder: nil, delegate: self)
        let save = UIAlertAction(title: "save".localize(), style: .default) { _ in
            guard let message = msgVC.textFields?.first?.text, !message.isEmpty else { return }
            self.messages.append(WorkorderMessage.encode(with: message))
            self.foldViews[.message]?.totalCount = self.messages.count
            self.foldViews[.message]?.folded = false
            self.workorder?.setMessage(self.messages)
            self.updateWorkorder()
        }
        msgVC.addAction(save)
        present(msgVC, animated: true, completion: nil)
    }
    
    
    func delete(message: WorkorderMessage) {
        guard let index = messages.firstIndex(where: { $0.toString() == message.toString() }) else {
            return
        }
        let deleteVC = ControllerUtility.generateDeletionAlertController(with: "message".localize(with: prefixWorkorder))
        let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
            self.messages.remove(at: index)
            self.foldViews[.message]?.totalCount = self.messages.count
            self.workorder?.setMessage(self.messages)
            self.updateWorkorder()
        }
        deleteVC.addAction(deleteAction)
        present(deleteVC, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
