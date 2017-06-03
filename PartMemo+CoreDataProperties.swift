//
//  PartMemo+CoreDataProperties.swift
//  rapid_medley
//
//  Created by base64 on 2017/05/29.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation
import CoreData


extension PartMemo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PartMemo> {
        return NSFetchRequest<PartMemo>(entityName: "PartMemo")
    }

    @NSManaged public var bpm: Int32
    @NSManaged public var end: Int32
    @NSManaged public var music: String?
    @NSManaged public var scalefrom: Int32
    @NSManaged public var scaleto: Int32
    @NSManaged public var start: Int32
    @NSManaged public var volume: Float
    @NSManaged public var id: Int64

}
