//
//  WorkorderAdditionViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/3/26.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya

protocol WorkorderAdditionDelegate {
    func added(workorder: Workorder)
}

class WorkorderAdditionViewController: UITableViewController, UINavigationBarDelegate {

    //数据上传过程的指示器
    private let indicator = UIActivityIndicatorView(style: .large)
    private var doneButton: UIBarButtonItem?
    //任务清单在section:1
    private let taskSection = 1
    //使用硬编码的方式固定日期范围的行，为要在日期选择器后回调赋值
    private let dateCellIndex = 3
    //在section:0中的row
    private let rows = ["title", "type", "properties", "proper_time", "executed", "audited", "instruction", "task"]
    //保持数据前要重各单元格取值，建立一个单元格数组，方便后期利用，因数量不多（8）不会影响整体性能
    private var textInputCells: [TextInputCell] = []
    //日期范围选择器，选择两个时间：开始+截止
    private var dateItems: [String] = []
    //任务清单
    private var tasks: [String] = []

    var workorder = Workorder()
    var delegate: WorkorderAdditionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initViews()
        initCells()
    }

    private func initViews() {
        title = "add_workorder".localize(with: prefixWorkorder)

        dateItems.append("start_time".localize(with: prefixWorkorder))
        dateItems.append("end_time".localize(with: prefixWorkorder))

        tableView.addSubview(indicator)
        indicator.topToSuperview(offset: edsMinSpace)
        indicator.centerXToSuperview()
        indicator.color = .systemRed
        indicator.alpha = 0
        indicator.startAnimating()

        tableView.separatorStyle = .none
        tableView.register(TextInputCell.self, forCellReuseIdentifier: String(describing: TextInputCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.register(TaskAdditionCell.self, forCellReuseIdentifier: String(describing: TaskAdditionCell.self))
        //tableView可编辑，才能实现部分行左边删除键
        tableView.allowsSelection = false
        tableView.setEditing(true, animated: false)

        //目标大标题显示无效，猜测跟TableVC冲突，待细研究 20.03.30 by.hs
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        navigationItem.rightBarButtonItem = doneButton!
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAction))
    }

    private func initCells() {

        textInputCells = rows.enumerated().map { row in
            let cell = TextInputCell()
            cell.title = row.element.localize(with: prefixWorkorder)
            switch row.offset {
            case 1:
                cell.items = WorkorderType.allCases.map { $0.getText() }
            case 2:
                cell.multiSelected = true
                cell.items = DeviceUtility.sharedInstance.indentDeviceListText()
            case 3:
                cell.dates = dateItems
                cell.datePickerDelegate = self
            case 4:
                cell.items = AccountUtility.sharedInstance.phoneList.map { $0.name! }
            case 5:
                cell.items = AccountUtility.sharedInstance.phoneList.map { $0.name! }
            case 6:
                cell.items = WorkorderTaskModel.sharedInstance?.instructions ?? []
            case 7:
                cell.items = WorkorderTaskModel.sharedInstance?.tasks?.map { $0.task! } ?? []
                //根据选择的任务类型生成任务清单
                cell.delegate = self
            default:
                break
            }
            return cell
        }
        setInitValues()
    }

    private func setInitValues() {
        //报警工单模板
        guard !workorder.title.isEmpty else {
            return
        }
        textInputCells[0].textField.text = workorder.title
        textInputCells[1].textField.text = workorder.type.getText()
        textInputCells[1].dropDown.selectRow(workorder.type.rawValue)
        textInputCells[2].textField.text = workorder.location
    }

    @objc func doneAction() {
        initWorkorder()
        saveWorkorder()
    }

    //为了保证弹出的键盘可以被正常关闭，做如下操作：弹出确认框前取消tableView编辑状态，将关闭键盘
    //禁止左滑返回，必须调用dismissAction
    //如果tableView.endEdit触发关闭键盘后马上dismiss VC，键盘并不会被正常关闭，将一直留在APP页面中，影响正常使用
    @objc func dismissAction() {
        tableView.endEditing(true)
        let alertVC = UIAlertController(title: "cancel_alert".localize(), message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "cancel".localize(), style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        let edit = UIAlertAction(title: "edit".localize(), style: .default, handler: nil)
        alertVC.addAction(cancel)
        alertVC.addAction(edit)
        present(alertVC, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

}

// MARK: - Workorder保存
extension WorkorderAdditionViewController {

    private func initWorkorder() {

        let inputs = textInputCells.map { cell -> (text: String, selectedIndex: Int) in
            let text = cell.textField.text ?? ""
            let index = cell.dropDown.indexPathForSelectedRow?.row ?? 0
            return (text, index)
        }
        //不能在此次初始化工单，因为建议时间在其他地方赋值
        //workorder = Workorder()
        workorder.added = true
        workorder.title = inputs[0].text
        workorder.type = WorkorderType(rawValue: inputs[1].selectedIndex)!
        workorder.location = inputs[2].text
        //start and end time在选择时间后已设定至workorder
        workorder.worker = inputs[4].text
        workorder.auditor = inputs[5].text
        if inputs[6].selectedIndex != 0 {
            //作业文档第一项为“无”
            let msg = WorkorderMessage.encode(with: inputs[6].text)
            var msgs = workorder.getMessages()
            msgs.append(msg)
            workorder.setMessage(msgs)
        }
        //tasks在新增任务的时候已设定至tasks
        workorder.setTasks(titles: tasks)
        //创建人即当前登录用户
        if let userName = AccountUtility.sharedInstance.phone?.name {
            //尽管默认工单状态即为.created，但是调用setState(with:by:)可以存档流程记录
            workorder.setState(with: .created, by: userName)
            workorder.creator = userName
            //当创建与执行为同一人时，省略派发通知流程，因本人创建，默认知道该工单存在
            if userName == workorder.worker {
                workorder.setState(with: .distributed, by: userName)
            }
        }

    }

    private func saveWorkorder() {
        //进度条在顶部
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)

        //信息不完整,必要工单信息：id(自动生成),title,start,end,task
        guard workorder.prepareSaved() else {
            let title = "imcomplete".localize(with: prefixWorkorder)
            let message = ["title", "proper_time", "task", "executed", "audited"].map { $0.localize(with: prefixWorkorder) }.joined(separator: "/")
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok".localize(), style: .default, handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
            return
        }

        indicator.alpha = 1
        doneButton?.isEnabled = false
        MoyaProvider<EDSService>().request(.updateWorkorder(workorder: workorder)) { result in
            self.indicator.alpha = 0
            self.doneButton?.isEnabled = true
            switch result {
            case .success(let response):
                if JsonUtility.didUpdatedEDSServiceSuccess(data: response.data) {
                    //回调
                    self.delegate?.added(workorder: self.workorder)
                    //在navigationController中退出发生如下
                    self.navigationController?.popViewController(animated: true)
                }
            default:
                break
            }
        }
    }
}

// MARK: -表单实现
extension WorkorderAdditionViewController { //:UITableViewDataSource, UITableViewDelegate {
    override func numberOfSections(in tableView: UITableView) -> Int {
        //0:工单子项，1:任务清单列表
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //0:新增/主题/类型/资产/时间/执行/审核/文档/清单（共8项）
        return section == taskSection ? tasks.count + 1 : rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard indexPath.section != taskSection else {
            guard indexPath.row != 0 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskAdditionCell.self), for: indexPath) as! TaskAdditionCell
                cell.title = "add_task".localize(with: prefixWorkorder)
                cell.delegate = self
                return cell
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            cell.textLabel?.text = tasks[indexPath.row - 1]
            //左边还包含任务清单子项删除键，缩进层级
            cell.indentationLevel = 3
            return cell
        }

        return textInputCells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == taskSection ? 40 : 80
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //任务清单列表可删减，提前是tableView.setEditing(true)
        return indexPath.section == taskSection && indexPath.row > 0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == taskSection ? 40 : 0
    }

}

// MARK: - 协议
extension WorkorderAdditionViewController: TextInputCellDelegate, TaskAdditionCellDelegate, PickerDelegate {

    //取消日期选择
    func pickerCanceled() {
        textInputCells[dateCellIndex].textField.text = nil
    }

    //选择好有效日期
    func picked(results: [Date]) {
        //format: 3月10 - 3月31
        let cell = textInputCells[dateCellIndex]
        workorder.start = results[0].toDateTimeString()
        workorder.end = results[1].toDateTimeString()
        cell.textField.text = workorder.getTimeRange()
    }

    //新增任务
    func addItem(text: String) {
        guard !tasks.contains(text) else {
            return
        }
        tasks.insert(text, at: 0)
        let indexPath = IndexPath(row: 1, section: taskSection)
        tableView.insertRows(at: [indexPath], with: .automatic)
        //在真机调试时发现bug,选择任务清单后新增任务一两次后不能再点击，需tableview上下稍微滚动，才能有反应，故做如下处理
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }

    //文本选择，选择eds系统提供的任务清单列表
    func itemSelected(item: String) {
        tasks = WorkorderTaskModel.sharedInstance?.tasks?.first { $0.task! == item }?.items ?? []
        tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: .automatic)
    }

}
