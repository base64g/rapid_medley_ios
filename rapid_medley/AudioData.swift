//
//  AudioData.swift
//  iikanji_medley
//
//  http://qiita.com/programanx1/items/8912e60843bd824d74ce を参考に編集
//

import Foundation
import AVFoundation
import Surge

class AudioDataClass{
    
    var address:URL
    
    var mixbuffer:[Float] = []
    
    var samplingRate:Double?
    var nChannel:Int?
    var nframe:Int?
    
    //initializer
    init(address:URL){
        self.address = address
    }
    
    //import audio file
    func loadAudioData(left:Int = 0, right:Int = 0){
        var audioFile:AVAudioFile!
        
        var PCMBuffer:AVAudioPCMBuffer!
        
        do{
            
            audioFile = try AVAudioFile(forReading: self.address)
            self.samplingRate = audioFile.fileFormat.sampleRate
            self.nChannel = Int(audioFile.fileFormat.channelCount)
            
        }catch{
            print("Error : loading audio file \(self.address) failed.")
        }
        
        if(audioFile != nil){
            self.nframe = Int(audioFile.length)
            
            let rightT:Int = right==0 ? nframe! : right
            
            audioFile.framePosition = Int64(left)
            
            PCMBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(rightT-left))
            var buffer:[[Float]]! = Array<Array<Float>>()
            do{
                try audioFile.read(into: PCMBuffer)
                for i in 0..<self.nChannel!{
                    let buf:[Float] = Array(UnsafeMutableBufferPointer(start:PCMBuffer.floatChannelData![i], count:rightT - left))
                    buffer.append(buf)
                }
                let two = [Float](repeating: 2, count: buffer[0].count)
                if(self.nChannel! >= 2){
                    self.mixbuffer = Surge.div(Surge.add(buffer[0], y:buffer[1]), y:two)
                }else{
                    self.mixbuffer = Surge.div(buffer[0], y:two)
                }
            }catch{
                print("loading audio data failed.")
            }
        }
    }
    
    //write audioData
    func writeAudioData(data:[[Float]],address:String,format:AVAudioFormat?)->Bool{
        var audioformat:AVAudioFormat?
        let nChannel:Int = data.count
        let nframe:Int = data[0].count
        if(nframe == 0){print("Error : no data."); return false}
        if(nChannel > 0){
            if(format == nil){
                if(self.samplingRate == nil){self.samplingRate = 44100;}
                audioformat = AVAudioFormat(standardFormatWithSampleRate: self.samplingRate!, channels: AVAudioChannelCount(nChannel))
            }else{
                audioformat = format
            }
        }else{
            return false
        }
        
        let buffer = AVAudioPCMBuffer(pcmFormat:audioformat!, frameCapacity: AVAudioFrameCount(nframe))
        buffer.frameLength = AVAudioFrameCount(nframe)
        
        for i in 0..<nChannel{
            for j in 0..<nframe{
                buffer.floatChannelData?[i][j] = data[i][j]
            }
        }
        
        var writeAudioFile:AVAudioFile?
        let url = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/" + address))!
        
        do{
            writeAudioFile = try AVAudioFile(forWriting: url, settings: [
                AVFormatIDKey:Int(kAudioFormatLinearPCM),
                AVSampleRateKey:audioformat!.sampleRate,
                AVNumberOfChannelsKey:nChannel,
                AVEncoderBitRatePerChannelKey:16
                ])
            
        }catch{
            print("Error : making audio file failed.")
            return false
        }
        
        do{
            try writeAudioFile!.write(from: buffer)
            print("\(nframe) samples are written in \(address)")
            
        }catch{
            print("Error : Could not export audio file")
            return false
        }
        
        return true
    }
}
