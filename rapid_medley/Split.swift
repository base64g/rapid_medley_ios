//  split.swift
//  iikanji_medley
//
//  Created by base64 on 2017/04/26.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation
import AVFoundation
import Surge

class Spliter{
    let frame = 512 //何フレームごとに音量を求めるか
    let pi:Float = acos(-1.0)
    let audio:AudioDataClass
    let fullLength:Int
    var volumeDiff:[Float] = []
    var periodMatch:[Float] = [0]
    var BPM:Int = -1
    var Period:Int = -1 //拍の周期
    var START:Int = -1
    var beatFrame:[Int] = []
    let nframe:Int
    let volumeSampleRate:Int = 16
    let periodRange = 300...600
    var maximumVolumeDiff:Float = 0
    var cutFrame:[Int] = []
    var partMusics:[PartMusic] = []
    let scaleLength = 15
    var scaleData:[Int] = []
    var VOLUME:Float = 0
    let id:Int64
    init(address:URL, id:Int64){
        let startDate = NSDate() // 時間測定開始
        print("loading")
        self.id = id
        audio = AudioDataClass(address: address)
        audio.loadAudioData()
        fullLength = audio.mixbuffer.count
        nframe  = fullLength / frame
        print("initialize",NSDate().timeIntervalSince(startDate as Date)) // 時間測定終了
    }
    
    //音量の計算
    func calVolume(){
        VOLUME = Surge.max(Surge.abs(audio.mixbuffer))
    }
    
    //拍を検出する
    func beatDetect(){
        let startDate = NSDate() // 時間測定開始
        let objcpp = ObjCpp()
        let beats = objcpp.beats(UnsafeMutablePointer<Float>(mutating: audio.mixbuffer), Int32(audio.mixbuffer.count))
        for beat in beats!{
            if((beat as! Int) >= 0){
                beatFrame.append(Int(beat as! Int))
            }
        }
        BPM = Int(Float(beatFrame.count) / (Float(audio.mixbuffer.count) / 44100.0) * 60.0)
        Period = Int(Float(audio.samplingRate!) / Float(BPM) * Float(60))
        print("detect beat",NSDate().timeIntervalSince(startDate as Date)) // 時間測定終了
        
    }
    
    //曲を切り取る部分を求める
    func cutDetect(){
        let startDate = NSDate() // 時間測定開始
        
        var cutScore:[Int] = [0,0,0,0]
        
        let eps:Int = Period / 20
        for i in 1..<beatFrame.count-1{
            let t = (beatFrame[i] + eps) / 512
            var point = 1
            var scaleSum = scaleData[t]
            var scale = scaleData[t]
            if(scale<20){
                continue
            }
            while(t+point < scaleData.count){
                if(abs(scale - scaleData[t + point]) > 40){
                    break
                }
                point += 1
                scaleSum += scaleData[t + point]
                scale = scaleSum / point
            }
            if(abs(scale - scaleData[(beatFrame[i] - eps) / 512]) > 15){
                point += 1
            }
            cutScore[i % 4] += point * point
        }
        print(cutScore)
        var bestCutStart = 4
        var bestCutStartScore = cutScore[0]
        for i in 1..<4{
            if(bestCutStartScore < cutScore[i]){
                bestCutStartScore = cutScore[i]
                bestCutStart = i
            }
        }
        var id = bestCutStart
        while(id < beatFrame.count - 1){ //フェードの時めんどいから端を１拍無視する
            cutFrame.append(beatFrame[id])
            id+=4;
        }
        print("cut",NSDate().timeIntervalSince(startDate as Date)) // 時間測定終了
    }
    
    func calScale(){
        let startDate = NSDate() // 時間測定開始
        let objcpp = ObjCpp()
        let tmp = objcpp.scale(UnsafeMutablePointer<Float>(mutating: audio.mixbuffer), Int32(audio.mixbuffer.count))
        for scale in tmp! {
            scaleData.append(scale as! Int)
        }
        print("calScale",NSDate().timeIntervalSince(startDate as Date)) // 時間測定終了
    }
    
    func getScale(t:Int) -> Int {
        var scalePoint = [Int](repeating: 0, count: 2001)
        for i in Int(t/512)..<Int(t/512)+scaleLength {
            if(0 <= scaleData[i] && scaleData[i] < scalePoint.count){
                scalePoint[scaleData[i]] += 1
            }
        }
        var bestScale = 0
        var bestScaleScore = 0
        for scale in 0..<2001 {
            var nowScaleScore = 0
            var nowScaleSum = 0
            for ds in scale-5...scale+5 {
                if(ds < 0 || 2000 < ds){
                    continue
                }
                nowScaleScore += scalePoint[ds]
                nowScaleSum += scalePoint[ds] * ds
            }
            if(nowScaleScore > bestScaleScore){
                bestScaleScore = nowScaleScore
                bestScale = Int(nowScaleSum / nowScaleScore)
            }
        }
        if(bestScale < 20){
            bestScale = 0
        }
        return bestScale
    }
    
    //切り取る部分を分類
    func analyzeCut(){
        let startDate = NSDate() // 時間測定開始
        //bpm, 音の性質（高さ）, 曲名, 開始位置, 終了位置
        for i in 0..<cutFrame.count-4 {
            let from = getScale(t:(cutFrame[i]) + Int(44100 * 0.2))
            let to = getScale(t:(cutFrame[i+4]) + Int(44100 * 0.2))
            if(to != 0 && from != 0){
                partMusics.append(PartMusic(bpm: BPM,
                                            scaleFrom: from,
                                            scaleTo: to,
                                            music:audio.address,
                                            start: cutFrame[i],
                                            end: cutFrame[i+4],
                                            volume: VOLUME,
                                            id: id))
            }
        }
        print("analyze",NSDate().timeIntervalSince(startDate as Date)) // 時間測定終了
    }
    
    //↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓TEST FUNCTION↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓//
    
    func testWriteMusicOnBeat(){
        
        var writeData:[Float] =  audio.mixbuffer
        for s in 0..<writeData.count {
            writeData[s] *= 0.1
        }
        for t in beatFrame {
            writeData[t] += 2000000
        }
        _ = audio.writeAudioData(data: [writeData], address: "beat.wav", format: nil)
    }
    
    func testWriteMusicWithCut(){
        var writeData:[Float] =  audio.mixbuffer
        for s in 0..<writeData.count {
            writeData[s] *= 0.1
        }
    
        for t in cutFrame {
            if(t < writeData.count){
                writeData[t] += 2000000
            }
        }
        _ = audio.writeAudioData(data: [writeData], address: "cut.wav", format: nil)
    }
    
    func scaleTest(){
        var writeData:[Float] = []
        var now:Float = 0.0
        for t in 0..<scaleData.count {
            for i in 0..<512 {
                writeData.append(sin(now))
                now += 2.0*pi*Float(scaleData[t])/44100.0
                while(now>=2.0*pi){
                    now-=2*pi
                }
            }
        }
        for i in 0..<writeData.count {
            if(i < audio.mixbuffer.count){
                writeData[i] += audio.mixbuffer[i] * 0.2
            }
        }
        _ = audio.writeAudioData(data: [writeData], address: "scale.wav", format: nil)
        
    }
    
    func run(){
        calVolume()
        beatDetect()
        calScale()
        cutDetect()
        analyzeCut()
        //testWriteMusicOnBeat()
        //testWriteMusicWithCut()
        //scaleTest()
    }
}
