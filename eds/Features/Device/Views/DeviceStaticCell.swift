//
//  DeviceStaticCell.swift
//  TableViewCell
//
//  Created by 厦门士林电机有限公司 on 2019/12/20.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  Device静态（非通信型），资产管理的一部分

import UIKit

class DeviceStaticCell: UITableViewCell {

    private let space: CGFloat = 20

    var deviceImageView = UIImageView()
    var nameLabel = UILabel()

    var staticType: DeviceStaticCellType? {
        didSet {
            if let staticType = staticType {
                tintColor = staticType.getColor()
                nameLabel.text = staticType.getName()
                nameLabel.textColor = staticType.getColor()
                deviceImageView.image = staticType.getIcon()
                accessoryView = staticType.getAccessoryView()
            }
        }
    }

    private func initViews() {
        deviceImageView.contentMode = .scaleAspectFit
        addSubview(deviceImageView)
        deviceImageView.heightToSuperview(offset: space)
        deviceImageView.widthToHeight(of: deviceImageView)
        deviceImageView.leadingToSuperview(offset: space)
        deviceImageView.centerYToSuperview()

        nameLabel.textAlignment = .center
        addSubview(nameLabel)
        nameLabel.centerYToSuperview()
        nameLabel.leadingToTrailing(of: deviceImageView)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}


/// 静态Cell类型：配电房，配电箱，静态设备
/// 相应类型图片应放置于Assets中，以device_枚举类型命名，如device_room
/// 配电房&配电箱可展开/增删设备，uicolor:black
enum DeviceStaticCellType {
    case room(named: String)
    case box(named: String)
    case fixture(named: String)

    func getName() -> String {
        switch self {
        case .box(let name), .room(let name), .fixture(let name):
            return name
        }
    }

    func getColor() -> UIColor {
        switch self {
        case .room, .box:
            return .black
        default:
            return .systemGray
        }
    }

    func getIcon() -> UIImage? {
        //enum含参数(name)，不能使用rawValue属性获得string,self👉string:"box("")"
        let iconName = String(describing: self).components(separatedBy: "(")[0]
        return UIImage(named: "device_" + String(describing: iconName))?.withTintColor(getColor())
    }

    func getAccessoryView() -> UIView? {
        switch self {
        case .room, .box:
            return UIImageView(image: UIImage(systemName: "plus"))
        default:
            return nil
        }
    }

}
