//
//  AVUtility.swift
//  rapid_medley
//
//  Created by base64 on 2017/05/23.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import UIKit
import AVFoundation

class AVUtilities {
    static func read(_ original: AVAsset) -> [Int16]{
        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: original)
        } catch {
            print("could not initialize reader.")
            return []
        }
        
        guard let audioTrack = original.tracks(withMediaType: AVMediaTypeAudio).first else {
            print("could not retrieve the video track.")
            return []
        }
        
        let readerOutputSettings: [String: Int] = [ AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                                    AVLinearPCMIsBigEndianKey: 0,
                                                    AVLinearPCMIsFloatKey: 0,
                                                    AVLinearPCMBitDepthKey: 16,
                                                    AVLinearPCMIsNonInterleaved: 0]
        let readerOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: readerOutputSettings)
        reader.add(readerOutput)
        
        reader.startReading()
        
        let sampleData = NSMutableData()
        //サンプリングしたデータを格納する配列
        var arraySamples = [Int16]()
        //読み込むデータが無くなるまで、つまり終端のデータまで読み込みつづける。
        while reader.status == AVAssetReaderStatus.reading {
            //copyNextSampleBuffer:次のサンプルに進む？
            if let sampleBufferRef = readerOutput.copyNextSampleBuffer() {
                //samplebufferRefのprint結果については後述。
                print(sampleBufferRef)
                
                if let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef) {
                    
                    let bufferLength = CMBlockBufferGetDataLength(blockBufferRef)
                    
                    let data = NSMutableData(length: bufferLength)
                    
                    CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data!.mutableBytes)
                    let samples = UnsafeMutablePointer<Int16>(OpaquePointer(UnsafeMutableRawPointer(data!.mutableBytes)))
                    sampleData.append(samples, length: bufferLength)
                    CMSampleBufferInvalidate(sampleBufferRef)
                    for i in 0..<8192 {
                        arraySamples.append(samples.advanced(by: i).pointee)
                    }
                }
            } 
        }
        return arraySamples
    }
    static func reverse(_ original: AVAsset, outputURL: URL, completion: @escaping (AVAsset) -> Void) {
        
        // Initialize the reader
        
        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: original)
        } catch {
            print("could not initialize reader.")
            return
        }
        
        guard let videoTrack = original.tracks(withMediaType: AVMediaTypeVideo).last else {
            print("could not retrieve the video track.")
            return
        }
        
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        reader.add(readerOutput)
        
        reader.startReading()
        
        // read in samples
        
        var samples: [CMSampleBuffer] = []
        while let sample = readerOutput.copyNextSampleBuffer() {
            samples.append(sample)
        }
        
        // Initialize the writer
        
        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: AVFileTypeQuickTimeMovie)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        let videoCompositionProps = [AVVideoAverageBitRateKey: videoTrack.estimatedDataRate]
        let writerOutputSettings = [
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: videoTrack.naturalSize.width,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoCompressionPropertiesKey: videoCompositionProps
            ] as [String : Any]
        
        let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: writerOutputSettings)
        writerInput.expectsMediaDataInRealTime = false
        writerInput.transform = videoTrack.preferredTransform
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
        
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(samples.first!))
        
        for (index, sample) in samples.enumerated() {
            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
            let imageBufferRef = CMSampleBufferGetImageBuffer(samples[samples.count - 1 - index])
            while !writerInput.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.1)
            }
            pixelBufferAdaptor.append(imageBufferRef!, withPresentationTime: presentationTime)
            
        }
        
        writer.finishWriting {
            completion(AVAsset(url: outputURL))
        }
    }
}
