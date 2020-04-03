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

class WorkorderViewController: UIViewController {

    private var flows: [WorkorderFlow] = []
    private var tasks: [WorkorderTask] = []
    private var messages: [WorkorderMessage] = []
    private var infos: [WorkorderInfo] = []
    private var photos: [URL] = []

    private let tableView = UITableView()

    //任务/留言太多时折叠处理
    private var foldViews: [WorkorderSectionType: FoldView] = [.task: FoldView(), .message: FoldView()]
    private let disposeBag = DisposeBag()

    //电话派发工单，监听电话接通状态
    private let callObserver = CXCallObserver()

    //执行
    private var executing = false {
        didSet {
            executedState.accept(executing)
        }
    }
    private var executedState = BehaviorRelay<Bool>(value: false)

    var workorder: Workorder? {
        didSet {
            if let workorder = workorder {
                title = workorder.title
                flows = workorder.getFlows()
                tasks = workorder.getTasks()
                messages = workorder.getMessages()
                infos = workorder.getInfos()
                photos = workorder.getImageURLs()

                initFoldView(type: .task, total: tasks.count)
                initFoldView(type: .message, total: messages.count)
            }
        }
    }

    private func initFoldView(type: WorkorderSectionType, total: Int) {
        if let view = foldViews[type] {
            view.totalCount = total
            view.foldButton.rx.tap.bind(onNext: {
                view.folded = !view.folded
                self.tableView.reloadData()
            }).disposed(by: disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        initBarItems()
    }

    private func initViews() {

        callObserver.setDelegate(self, queue: DispatchQueue.main)

        navigationController?.navigationBar.prefersLargeTitles = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.edgesToSuperview()
    }

    private func initBarItems() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let distribute = UIBarButtonItem(title: WorkorderState.distributed.getText(), style: .plain, target: self, action: #selector(selectDistribution))
        let execute = UIBarButtonItem(title: WorkorderState.executed.getText(), style: .plain, target: self, action: #selector(executeWorkorder))
        let audit = UIBarButtonItem(title: WorkorderState.audited.getText(), style: .plain, target: self, action: nil)
        let record = UIBarButtonItem(title: "message".localize(with: prefixWorkorder), style: .plain, target: self, action: nil)
        toolbarItems = [distribute, space, execute, space, audit, space, record]
    }

    override func viewWillAppear(_ animated: Bool) {
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

extension WorkorderViewController: UITableViewDataSource, UITableViewDelegate {
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
            view.title = type.getSectionTitle()! + "(\(photos.count))"
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
            cell.photoSource.urls = photos
            return cell
        case .info:
            let cell = WorkorderInfoCell()
            cell.info = infos[indexPath.row]
            return cell
        case .message:
            let cell = WorkorderMessageCell()
            cell.message = messages[indexPath.row]
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

extension WorkorderViewController {

    func updateWorkorder() {
        guard let workorder = workorder else {
            return
        }
        MoyaProvider<EDSService>().request(.updateWorkorder(workorder: workorder)) { result in
            switch result {
            case .success(let response):
                if JsonUtility.didUpdatedEDSServiceSuccess(data: response.data) {
                    WorkorderUtility.sharedInstance.update(with: workorder)
                    self.tableView.reloadData()
                }
            default:
                break
            }
        }
    }
}


// MARK: - 派发工单
extension WorkorderViewController: ShareDelegate, CXCallObserverDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

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
            ShareUtility.sendMail(to: executor.email!, title: "distribution_title".localize(with: prefixWorkorder), content: sentContent, imageData: imageData, in: self)
        default:
            break
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
        //只有新建状态下的派发，才需要上传数据。其他即为二次派发
        guard workorder?.state == WorkorderState.created else {
            return
        }
        let name = AccountUtility.sharedInstance.phone?.name ?? NIL
        workorder?.setState(with: .distributed, by: name)
        updateWorkorder()
    }
}

//MARK: -执行工单
extension WorkorderViewController {

    @objc func executeWorkorder() {
        executing = !executing
        //不能直接更改title，只能替换
        let title = executing ? "save".localize() : WorkorderState.executed.getText()
        toolbarItems?[2] = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(executeWorkorder))
    }
}
