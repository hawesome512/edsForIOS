//
//  VarifyUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2020/1/15.
//  Copyright © 2020 厦门士林电机有限公司. All rights reserved.
//

import Foundation
import UIKit

enum AuthorityResult: String {
    //用户等级限制
    case userLocked
    //设备本地锁
    case localLocked
    //验证密码中
    case verifying
    //授权
    case granted
    //取消
    case cancel
}

class VerifyUtility {

    static func verify(tag: Tag, delegate: PasswordVerifyDelegate, parentVC: UIViewController?) -> AuthorityResult {

        //用户权限锁
        guard AccountUtility.sharedInstance.isOperable() else {
            return .userLocked
        }

        let deviceName = TagUtility.getDeviceName(with: tag.Name)!
        let deviceType = TagUtility.getDeviceType(with: deviceName)!
        guard let authorities = DeviceModel.sharedInstance?.types.first(where: { $0.type == deviceType })?.authority else {
            //设备无权限限制
            return .granted
        }

        //【格式】："authority":["CtrlMode/-1/0/local/1/remote","CtrlCode/%04X"]
        let modeTag = TagUtility.sharedInstance.getTagList(by: [DeviceModel.authorityMode], in: deviceName).first
        var modeInfos = authorities.first { $0.contains(DeviceModel.authorityMode) }?.components(separatedBy: DeviceModel.itemInfoSeparator)
        modeInfos?.removeFirst()
        if let modeTag = modeTag,var modeInfos = modeInfos,modeInfos.count == 5,let switchIndex = Int(modeInfos[0]) {
            var modeValue = Int(modeTag.getValue())
            //验证开关位是否为1
            if switchIndex >= 0 {
                modeValue = TagValueConverter.getSwitch(value: modeTag.getValue(), items: modeInfos) ? 1 : 0
            }
            //开关位-1可能跟后面的标志位值一样，避免后续找firstIndex冲突先remove
            modeInfos.removeFirst()
            if let valueIndex = modeInfos.firstIndex(of: "\(modeValue)"),
               valueIndex >= 0,
               valueIndex <= modeInfos.count - 2,
               modeInfos[valueIndex+1] == DeviceModel.localMode {
                return .localLocked
            }
        }

        let codeTag = TagUtility.sharedInstance.getTagList(by: [DeviceModel.authorityCode], in: deviceName).first
        let codeInfos = authorities.first { $0.contains(DeviceModel.authorityCode) }?.components(separatedBy: DeviceModel.itemInfoSeparator)
        if let codeTag = codeTag {
            //codeInfos:[CtrlCode,%04X],16进制，4位长度,进行密码验证
            let psdVC = PasswordController(title: nil, message: nil, preferredStyle: .alert) //PasswordViewController()
            psdVC.delegate = delegate
            let needFormatted = codeInfos?.count == 2
            psdVC.validPassword = needFormatted ? String(format: codeInfos![1], Int(codeTag.getValue())) : codeTag.getValue().clean
            parentVC?.present(psdVC, animated: true, completion: nil)
            return .verifying
        }

        return .granted
    }
}
