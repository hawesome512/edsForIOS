//
//  ViewController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/4.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON
import HandyJSON
import CocoaMQTT
import Foundation
import RxSwift
import RxCocoa

class ViewController: UIViewController {


    let disposeBag = DisposeBag()
    let button = UIButton()
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        loadTagList()
    }

    func loadTagList() {
        MoyaProvider<WAService>().request(.getTagList(authority: "xkb:xseec".toBase64(), projectID: "1/XKB")) { result in
            switch result {
            case .success(let response):
                TagUtility.sharedInstance.addTagList(with: JsonUtility.getTagList(data: response.data))
            default:
                break
            }
        }
    }

    fileprivate func initViews() {

        navigationController?.navigationBar.prefersLargeTitles = true
        title = "首页"
        
        button.backgroundColor = .systemBlue
        button.setTitle("Execute", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.rx.tap.bind(onNext: {

            //跳转设备列表
//            let deviceListVC = DeviceListViewController()
//            self.navigationController?.pushViewController(deviceListVC, animated: true)


        }).disposed(by: disposeBag)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 200).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        label.text = "0"
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

