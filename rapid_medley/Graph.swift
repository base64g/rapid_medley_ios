//
//  Graph.swift
//  rapid_medley
//
//  Created by base64 on 2017/04/26.
//  Copyright © 2017年 basemusi. All rights reserved.
//
import UIKit
import CoreGraphics

class Graph: UIView {
    class func draw(width: Int, data:[Float]) -> UIView{
        // ビューのサイズ
        let size = CGSize(width: width, height: width)
        // UIViewを生成
        let view:UIView = UIView(frame: CGRect(origin: CGPoint(x:0,y:0), size: size))
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        // CoreGraphicsで描画する
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let maximum :Float! = data.max()
        let minimum :Float! = data.min()
        let mid = (maximum + minimum)/2
        let length = data.count
        print("Graph [ 0,",length-1,"] -> ",minimum, maximum)
        
        // 描画する
        let path = UIBezierPath()
        for i in 0..<length-1 {
            let fromX = width*i/(length-1)
            let toX   = width*(i+1)/(length-1)
            let multi = (Float(width) / 2) / (maximum - mid)
            var tmp = Float(width/2) - (data[i] - mid) * multi
            let fromY = Int(tmp)
                tmp = Float(width/2) - (data[i+1] - mid) * multi
            let toY   = Int(tmp)
            path.move(to: CGPoint(x:fromX, y:fromY))
            path.addLine(to: CGPoint(x:toX, y:toY))
            UIColor.orange.setStroke()
            path.stroke()
        }
        
        // viewのlayerに描画したものをセットする
        view.layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
        
        UIGraphicsEndImageContext()
        return view
    }
}
