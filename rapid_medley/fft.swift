//
//  fft.swift
//  rapid_medley
//
//  Created by base64 on 2017/05/06.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation
import Accelerate

class FFT {
    class func fft(input:[Float]) -> [Float]{
        let N = input.count
        // サンプリング数。この半分までの周波数までしか解析できない？。
        let log2n : vDSP_Length = vDSP_Length(log2(Double(N)))     // 10
        
        var inputData = input
        
        // FFT準備
        let fftObj : FFTSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2))!
        
        // 窓関数
        var windowData = [Float](repeating: 0, count: N)
        var windowOutput = [Float](repeating: 0, count: N)
        
        vDSP_hann_window(&windowData, vDSP_Length(N), Int32(0))
        vDSP_vmul(&inputData, 1, &windowData, 1, &windowOutput, 1, vDSP_Length(N))
        
        // Complex
        var imaginaryData = [Float](repeating: 0, count: N)
        var dspSplit = DSPSplitComplex(realp: &windowOutput, imagp: &imaginaryData)
        
        let ctozinput:UnsafePointer<DSPComplex> = UnsafeRawPointer(windowOutput).bindMemory(to: DSPComplex.self, capacity: windowOutput.count)
        vDSP_ctoz(ctozinput, 2, &dspSplit, 1, vDSP_Length(N / 2))
        
        // FFT解析
        vDSP_fft_zrip(fftObj, &dspSplit, 1, log2n, Int32(FFT_FORWARD))
        vDSP_destroy_fftsetup(fftObj)
        
        var result:[Float] = []
        
        // 結果出力
        for i in 0 ..< N / 2 {
            let real = dspSplit.realp[i];
            let imag = dspSplit.imagp[i];
            let distance = sqrt(pow(real, 2) + pow(imag, 2))
            //print(i, distance)
            result.append(distance)
        }
        return result
    }
}
