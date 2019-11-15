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

class ViewController: UIViewController {

    @IBOutlet weak var showImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func selectPicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerVC = UIImagePickerController()
            pickerVC.isEditing = false
            pickerVC.delegate = self
            pickerVC.sourceType = .photoLibrary
            present(pickerVC, animated: true, completion: nil)
        }
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            MoyaProvider<EDSService>().request(.upload(fileURL: url, fileName: "0123.jpeg")) { result in
                switch result {
                case .success(let response):
                    print(try? response.mapString())
                case .failure:
                    break
                }
            }
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            showImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
