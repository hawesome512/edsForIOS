//
//  WorkorderViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/16.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class WorkorderViewController: UITableViewController {

    private var flows: [WorkorderFlow] = []
    private var tasks: [WorkorderTask] = []
    private var messages: [WorkorderMessage] = []
    private var infos: [WorkorderInfo] = []
    private var images: [URL] = []

    //任务/留言太多时折叠处理
    private var foldViews: [WorkorderSectionType: FoldView] = [.task: FoldView(), .message: FoldView()]
    private let disposeBag = DisposeBag()

    var workorder: Workorder? {
        didSet {
            if let workorder = workorder {
                title = workorder.title
                flows = workorder.getFlows()
                tasks = workorder.getTasks()
                messages = workorder.getMessages()
                infos = workorder.getInfos()
                images = workorder.getImageURLs()

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

        navigationController?.navigationBar.prefersLargeTitles = false
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return WorkorderSectionType.allCases.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = WorkorderSectionType(rawValue: section)!
        let view = SectionHeaderView()
        switch type {
        case .message:
            //e.g.:留言(10)
            view.title = String(format: type.getSectionTitle()!, messages.count)
        default:
            view.title = type.getSectionTitle()
        }
        return view
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = WorkorderSectionType(rawValue: indexPath.section)!
        switch type {
        case .state:
            let cell = WorkorderStateCell()
            cell.flows = flows
            return cell
        case .basic:
            let cell = WorkorderBasicCell()
            cell.workorder = workorder
            return cell
        case .task:
            let cell = WorkorderTaskCell()
            cell.task = tasks[indexPath.row]
            return cell
        case .photo:
            let cell = WorkorderPhotoCollectionCell()
            cell.imageUrls = images
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
    }


    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let type = WorkorderSectionType(rawValue: section)!
        switch type {
        case .task, .message:
            return foldViews[type]!
        default:
            return UIView()
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let type = WorkorderSectionType(rawValue: section)!
        switch type {
        case .task, .message:
            return foldViews[type]!.getRowNumber() <= FoldView.limitCount ? 0 : UITableView.automaticDimension
        default:
            return 0
        }
    }
}
