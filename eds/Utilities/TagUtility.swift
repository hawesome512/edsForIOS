//
//  TagUtility.swift
//  eds
//
//  Created by 厦门士林电机有限公司 on 2019/11/20.
//  Copyright © 2019 厦门士林电机有限公司. All rights reserved.
//  监控点列表的处理

import Foundation

class TagUtility {


    static func update(source: [Tag], by target: [Tag?]?) {
        //Filter>forEach>first
        target?.forEach { tag in
            if let sourceTag = source.first(where: { $0.Name == tag?.Name }) {
                sourceTag.Value = tag?.Value
            }
        }
    }

    static func update(source: [Tag], by target: [MQTTTag?]?) {
        let targetTags = target?.map { $0?.toTag() }
        update(source: source, by: targetTags)
    }
}
