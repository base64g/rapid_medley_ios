//
//  PlayingDataMemo+CoreDataProperties.swift
//  rapid_medley
//
//  Created by base64 on 2017/05/30.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation
import CoreData


extension PlayingDataMemo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayingDataMemo> {
        return NSFetchRequest<PlayingDataMemo>(entityName: "PlayingDataMemo")
    }

    @NSManaged public var cut: Float
    @NSManaged public var id: Int64

}
