//
//  PlayingData.swift
//  rapid_medley
//
//  Created by base64 on 2017/06/04.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
class PlayingData {
    var cutTime: [Float] = []
    var musicId: [Int64] = []
    
    func add(cut: Float, id: Int64){
        cutTime.append(cut)
        musicId.append(id)
    }
    // (title, artwork, next)
    func getNow(time: Float) -> (String?, MPMediaItemArtwork?){
        if(cutTime.isEmpty){
            return (nil, nil)
        }
        
        var i = 0;
        while(i < cutTime.count && time > cutTime[i]){
            i += 1
        }
        i = i % cutTime.count
        let property = MPMediaPropertyPredicate(value: musicId[i], forProperty: MPMediaItemPropertyPersistentID)
        let query = MPMediaQuery()
        query.addFilterPredicate(property)
        return (query.items!.first!.title, query.items!.first!.artwork)
    }
}
