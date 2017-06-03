//
//  PartMusic.swift
//  rapid_medley
//
//  Created by base64 on 2017/05/02.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation

class PartMusic{
    let BPM:Int
    let SCALEFROM:Int
    let SCALETO:Int
    let MUSIC:String
    let START:Int
    let END:Int
    let VOLUME:Float
    let ID:Int64
    init(bpm:Int, scaleFrom:Int, scaleTo:Int, music:URL, start:Int, end:Int, volume:Float, id:Int64){
        BPM = bpm
        SCALEFROM = scaleFrom
        SCALETO = scaleTo
        MUSIC = String(describing: music)
        START = start
        END = end
        VOLUME = volume
        ID = id
    }
    
    class func cmp(x: PartMusic, y: PartMusic) -> Bool {
        if(x.BPM != y.BPM){
            return x.BPM < y.BPM
        }
        if(x.SCALEFROM != y.SCALEFROM){
            return x.SCALEFROM < y.SCALEFROM
        }
        if(x.SCALETO != y.SCALETO){
            return x.SCALETO < y.SCALETO
        }
        if(x.START != y.START){
            return x.START < y.START
        }
        return x.END < y.END
    }
}
