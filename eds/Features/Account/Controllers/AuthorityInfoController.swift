//
//  AuthorityInfoController.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/5/27.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import UIKit

class AuthorityInfoController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //因权限pdf文档固定为黑色字体，需设置灰度背景色
        view.backgroundColor = .systemGray3
        // Do any additional setup after loading the view.
        let imageView=UIImageView(image: UIImage(named: "authority")?.withTintColor(.label))
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.edgesToSuperview()
    }


}
