//
//  EnergyBranchController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/4/23.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import RxSwift

class EnergyBranchController: UITableViewController {

    private let cellID = "cell"
    private let disposeBag = DisposeBag()
    //支路是否被编辑过，用于提示退出保存
    private var branchEdited = false

    var energyBranches: [EnergyBranch] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }

    private func initViews() {
        title = "edit".localize(with: prefixEnergy)
        energyBranches = BasicUtility.sharedInstance.getEnergyBranch()?.getAllBranches() ?? []
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveBranch))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAction))
    }

    //因要退出提示保存，禁止左滑返回上一页
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    @objc func saveBranch() {
        if energyBranches.count > 0 {
            let topIDCount = energyBranches[0].id.count
            let topLevelBranchs = energyBranches.filter { $0.id.count == topIDCount }
            sortID(branches: topLevelBranchs)
        }

        //处理支路更新
        let branch = EnergyBranch.getBranchMessage(energyBranches)
        BasicUtility.sharedInstance.updateBranch(branch)
        ActionUtility.sharedInstance.addAction(.editBranch)
        let alertVC = UIAlertController(title: "save".localize(with: prefixEnergy), message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localize(), style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }

    @objc func dismissAction() {
        if branchEdited {
            let alertVC = ControllerUtility.generateSaveAlertController(navigationController: navigationController)
            present(alertVC, animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    //同一层级的id重新排列
    func sortID(branches: [EnergyBranch]) {
        guard branches.count > 0 else {
            return
        }
        let rootStr = branches[0].id.prefix(branches[0].id.count - 1)
        branches.enumerated().forEach { (offset, child) in
            child.id = rootStr + offset.description
            sortID(branches: child.branches)
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return energyBranches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let branch = energyBranches[indexPath.row]
        cell.textLabel?.text = branch.title
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
        //id:第1⃣️级0，第2⃣️级00，第3⃣️级000，可以按此缩进体现层级关系
        cell.indentationLevel = branch.id.count - 1
        cell.indentationWidth = edsSpace * 2
        cell.shouldIndentWhileEditing = true
        //限制新增层级数量
        if branch.id.count < EnergyBranch.levelLimit {
            let addButton = UIButton(type: .contactAdd)
            addButton.rx.tap.bind(onNext: {
                let parent = self.energyBranches[indexPath.row]
                guard parent.branches.count < EnergyBranch.branchLimit else {
                    self.showLimitAlert()
                    return
                }
                //此处不能用上面定义的branch
                self.pickBranch(parent: parent)
            }).disposed(by: disposeBag)
            cell.accessoryView = addButton
        } else {
            cell.accessoryView = nil
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let branch = energyBranches[indexPath.row]
        let deleteVC = ControllerUtility.generateDeletionAlertController(with: branch.title)
        let deleteAction = UIAlertAction(title: "delete".localize(), style: .destructive) { _ in
            //主路删除，支路一并删除,*(0次或以上)
            let regex = try? NSRegularExpression(pattern: "^\(branch.id)\\w*$", options: .allowCommentsAndWhitespace)
            self.energyBranches.removeAll(where: { element in
                let range = NSRange(location: 0, length: element.id.count)
                return regex?.firstMatch(in: element.id, options: [], range: range) != nil
            })
            //若有父级支路，还有删除其在父级的支路
            if branch.id.count > 1 {
                self.energyBranches.forEach { element in
                    element.branches.removeAll(where: { $0.id == branch.id })
                }
            }
            tableView.reloadData()
            self.branchEdited = true
        }
        deleteVC.addAction(deleteAction)
        present(deleteVC, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = AdditionTableHeaderView()
        header.title.text = "addition".localize(with: prefixEnergy)
        header.delegate = self
        return header
    }

    func pickBranch(parent: EnergyBranch?) {
        let pickerVC = BranchPickerController()
        pickerVC.delegate = self
        pickerVC.parentBranch = parent
        present(pickerVC, animated: true, completion: nil)
    }

    func showLimitAlert() {
        let message = String(format: "limit".localize(with: prefixEnergy), arguments: [EnergyBranch.branchLimit])
        let limitVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localize(), style: .cancel, handler: nil)
        limitVC.addAction(okAction)
        present(limitVC, animated: true, completion: nil)
    }

}

extension EnergyBranchController: AdditionDelegate, BranchPickerDelegate {
    func pick(branchDevice: Device, in parent: EnergyBranch?) {
        let newBranch = EnergyBranch()
        newBranch.tagName = branchDevice.getShortID() + ":EP"
        newBranch.title = branchDevice.title
        if let parent = parent {
            //有父级
            let endIndex = energyBranches.count - 1
            let index = energyBranches.firstIndex(where: { $0 == parent }) ?? endIndex
            newBranch.id = parent.id + String.randomString(length: 1)
            parent.branches.append(newBranch)
            if index == endIndex {
                energyBranches.append(newBranch)
            } else {
                energyBranches.insert(newBranch, at: index + 1)
            }
        } else {
            //无父级
            newBranch.id = String.randomString(length: 1)
            energyBranches.append(newBranch)
        }
        tableView.reloadData()
        branchEdited = true
    }

    //table>title新增第1⃣️级支路
    func add(inParent parent: Device?) {
        pickBranch(parent: nil)
    }
}
