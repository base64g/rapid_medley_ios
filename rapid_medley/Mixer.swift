//
//  Mixer.swift
//  rapid_medley
//
//  Created by base64 on 2017/05/02.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation
import AVFoundation
import Surge

class Mixer{
    let BPMCHANGE = 100
    let SCALECHANGE = 5
    let FADETIME:Int = Int(44100 * 0.2)
    var Music:[PartMusic] = []
    
    init(){
    }
    
    func add(spliter: Spliter){
        for p in spliter.partMusics {
            Music.append(p)
        }
    }
    
    //解析した曲をいい感じにつなげる
    func iikanjiMix(connect:Int) -> PlayingData{
        let startDate = NSDate() // 時間測定開始
        
        var retPlaying = PlayingData()
        
        
        
        var nowScale:Int = Int(arc4random()) % 800
        var nowBpm = 177
        var mixed:[Float] = []
        var nowTime:Float = 0.0
        var nextFade:[Float] = [Float](repeating: 0, count: FADETIME)
        
        for _ in 0..<connect {
            var connectTo:[PartMusic] = []
            for part in Music {
                if(nowBpm - BPMCHANGE <= part.BPM && part.BPM <= nowBpm + BPMCHANGE && nowScale - SCALECHANGE <= part.SCALEFROM && part.SCALEFROM <= nowScale + SCALECHANGE){
                    connectTo.append(part)
                }
            }
            let select = connectTo.isEmpty ? Music[Int(arc4random()) % Music.count] : connectTo[Int(arc4random()) % connectTo.count]
            
            nowTime += Float(select.END - select.START) / 44100.0
            retPlaying.add(cut: nowTime, id: select.ID)
            
            nowScale = select.SCALETO
            nowBpm = select.BPM
            let audio = AudioDataClass(address: URL(string: select.MUSIC)!)
            audio.loadAudioData(left: select.START-FADETIME, right: select.END+FADETIME)
            
            audio.mixbuffer = Surge.mul(audio.mixbuffer, y: [Float](repeating: 1.0/select.VOLUME, count:audio.mixbuffer.count))
            
            let START = FADETIME
            let END = select.END-select.START+FADETIME
            var tmp = [Float](repeating: 0, count: select.END-select.START)
            
            for j in START..<END {
                tmp[j - START] += audio.mixbuffer[j]
            }
            
            for i in 0..<FADETIME {
                tmp[i] = tmp[i] / Float(FADETIME*2) * Float(i+FADETIME) + nextFade[i] / Float(FADETIME*2) * Float(FADETIME-i)
            }
            
            var fade = [Float](repeating: 0, count: FADETIME)
            for j in 0..<START {
                fade[j] += audio.mixbuffer[j]
            }
            
            nextFade = [Float](repeating: 0, count: FADETIME)
            for j in END..<END+FADETIME {
                nextFade[j - END] += audio.mixbuffer[j]
            }
            if(!mixed.isEmpty){
                for i in mixed.count-FADETIME..<mixed.count {
                    let x:Int = i - mixed.count + FADETIME
                    mixed[i] = (mixed[i] / Float(FADETIME*2) * Float(FADETIME*2 - x)) + (fade[x] / Float(FADETIME*2) * Float(x))
                }
            }
            mixed += tmp
        }
        let audio = AudioDataClass(address: URL(string:"a")!)
        _ = audio.writeAudioData(data: [mixed], address: "iikanjiMedley.wav", format: nil)
        print("mix",NSDate().timeIntervalSince(startDate as Date)) // 時間測定終了
        return retPlaying
    }
}
