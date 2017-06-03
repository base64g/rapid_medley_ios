//
//  ViewController.swift
//  iikanji_medley
//
//  Created by base64 on 2017/04/25.
//  Copyright © 2017年 basemusi. All rights reserved.
//

/*
 This program uses Surge framework.
 
 Surge
 
 The MIT License
 
 Copyright (c) 2014 Mattt Thompson (http://mattt.me/)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit
import AVFoundation
import MediaPlayer
import Surge
import CoreData

class ViewController: UIViewController, MPMediaPickerControllerDelegate{
    @IBOutlet weak var playingPositin: UISlider!
    @IBOutlet weak var playingImage: UIImageView!
    @IBOutlet weak var PlayingText: UILabel!
    @IBOutlet weak var analyzingText: UILabel!
    @IBOutlet weak var analyzingApeal: UIActivityIndicatorView!
    @IBOutlet weak var analyzingImage: UIImageView!
    @IBOutlet weak var nowTime: UILabel!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var mixingApeal: UIActivityIndicatorView!
    
    var Mix : Mixer = Mixer()
    var playingData:PlayingData = PlayingData()
    var audioPlayer = AVAudioPlayer()
    var audioPlayerSafe = false
    let noAnalyzingDataImage = UIImage(named: "nodata")
    let noDataImage = UIImage(named: "nodata")
    let playButtonImage = UIImage(named: "play")
    let pauseButtonImage = UIImage(named: "tempstop")
    let repeatButtonImage = UIImage(named: "repeat")
    let repeatonButtonImage = UIImage(named: "repeaton")
    let analyzeQueue = DispatchQueue(label: "analyze")
    
    override func viewDidLoad() {
        // 全体に見栄え良く
        // オプション画面の実装
        super.viewDidLoad()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/" + "iikanjiMedley.wav"))!)
            durationTime.text = formatTimeString(d: audioPlayer.duration)
            nowTime.text = formatTimeString(d: 0.0)
            audioPlayerSafe = true
            audioPlayer.numberOfLoops = -1
        } catch {
            print("not exist iikanji")
        }
        Mix.Music = MyCoreData.readPartMemo()
        playingData = MyCoreData.readPlayingData()
        analyzingImage.image = noAnalyzingDataImage
        let (_, artwork) = playingData.getNow(time: 0.0)
        if let artworkSafe = artwork{
            playingImage.image = artworkSafe.image(at: artworkSafe.bounds.size)
        }else{
            playingImage.image = noDataImage
        }
        analyzingText.text = ""
        analyzingText.numberOfLines = 2
        self.view.backgroundColor = UIColor.white
        analyzingApeal.hidesWhenStopped = true
        analyzingApeal.stopAnimating()
        mixingApeal.hidesWhenStopped = true
        mixingApeal.stopAnimating()
        playingUpdate()
        deleteErrorData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        print("メモリふえぇ")
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pick() {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択を不可にする。（trueにすると、複数選択できる）
        picker.allowsPickingMultipleItems = true
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func pushMix() {
        if(Mix.Music.isEmpty){
            showAlert(title: "エラー", message: "曲の解析データがありません。先にオーディオデータの解析をしてください。")
        }else{
            if(!mixingApeal.isAnimating){
                mixingApeal.startAnimating()
                DispatchQueue.global(qos: .default).async {
                    self.playingData = self.Mix.iikanjiMix(connect: 30)
                    DispatchQueue.main.async {
                        self.mixingApeal.stopAnimating()
                        MyCoreData.savePlayingData(save: self.playingData)
                        self.playingPositin.value = 0
                        self.pushStop()
                        self.pushPlay()
                    }
                }
            }
        }
    }
    
    @IBAction func pushPlay() {
        //player.play()
        if(audioPlayerSafe && audioPlayer.isPlaying){
            if(audioPlayerSafe){
                audioPlayer.pause()
            }
        }else{
            var nowLoop:Int
            if(audioPlayerSafe){
                nowLoop = audioPlayer.numberOfLoops
            }else{
                nowLoop = -1
            }
            let url = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/" + "iikanjiMedley.wav"))!
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayerSafe = true
            } catch {
                showAlert(title: "エラー", message: "メドレーのデータがありません。先にメドレー生成をしてください。")
                return
            }
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                showAlert(title: "エラー", message: "バックづラウンド再生のエラー。")
            }
            durationTime.text = formatTimeString(d: audioPlayer.duration)
            nowTime.text = formatTimeString(d: 0.0)
            audioPlayer.currentTime = TimeInterval(playingPositin.value * Float(audioPlayer.duration))
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.numberOfLoops = nowLoop
        }
    }
    
    @IBAction func pushRepeat() {
        if(audioPlayerSafe){
            if(audioPlayer.numberOfLoops == -1){
                audioPlayer.numberOfLoops = 0
                repeatButton.setImage(repeatButtonImage, for: .normal)
            }else{
                audioPlayer.numberOfLoops = -1
                repeatButton.setImage(repeatonButtonImage, for: .normal)
            }
        }
    }
    
    @IBAction func pushStop() {
        if(audioPlayerSafe){
            audioPlayer.stop()
            playingPositin.value = 0
            audioPlayer.currentTime = 0.0
        }
    }
    
    @IBAction func sliderMove() {
        if(audioPlayerSafe){
            audioPlayer.currentTime = TimeInterval(playingPositin.value * Float(audioPlayer.duration))
        }
    }
    
    @IBAction func pushDelete() {
        performSegue(withIdentifier: "DeleteView", sender: nil)
    }
    @IBAction func goBack(_ segue:UIStoryboardSegue) {
        Mix.Music = MyCoreData.readPartMemo()
        print("hoge")
    }
    
    // メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print("selected")
        dismiss(animated: true, completion: nil)
        
        analyzeQueue.async {
            for item in mediaItemCollection.items{
                let id = item.persistentID
                let dones = MyCoreData.readPartMemo()
                var toDo = true
                for done in dones{
                    if(UInt64(done.ID) == UInt64(id)){
                        toDo = false
                    }
                }
                if(!toDo){
                    if let title = item.title{
                        self.showAlert(title: "エラー", message: title + "は既に解析済みです。")
                    }
                    continue
                }
                DispatchQueue.main.async {
                    if let title = item.title{
                        self.analyzingText.text = "analyzing\n" + title
                    }
                    if let artwork = item.artwork, let artworkImage = artwork.image(at: artwork.bounds.size)  {
                        self.analyzingImage.image = artworkImage
                    }
                    self.analyzingApeal.startAnimating()
                }
                if let url = item.assetURL {
                    let split = Spliter(address: url, id: Int64(id))
                    split.run()
                    DispatchQueue.main.async {
                        MyCoreData.savePartData(save: split.partMusics)
                        self.Mix.add(spliter: split)
                    }
                }else{
                    if let title = item.title {
                        self.showAlert(title: "エラー", message: title + "のデータにアクセスできません。オーディオデータがデバイスの中にあるか確認してください。")
                    }
                    print("アセットふえぇ")
                }
            }
            DispatchQueue.main.async {
                self.analyzingImage.image = self.noAnalyzingDataImage
                self.analyzingText.text = ""
                self.analyzingApeal.stopAnimating()
            }
        }
    }
     
     //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        print("canseled")
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }
    
    
    // playingImageとかの更新
    func playingUpdate(){
        if(audioPlayerSafe){
            var now = Float(audioPlayer.currentTime)
            now += 0.4
            if(now > Float(audioPlayer.duration)){
                now -= Float(audioPlayer.duration)
            }
            nowTime.text = formatTimeString(d: Double(now))
            playingPositin.value = Float(now) / Float(audioPlayer.duration)
            let (title, artwork) = playingData.getNow(time: Float(now))
            if let titleSafe = title{
                PlayingText.text = titleSafe
            }
            if let artworkSafe = artwork{
                playingImage.image = artworkSafe.image(at: artworkSafe.bounds.size)
            }
            if(audioPlayer.isPlaying){
                playButton.setImage(pauseButtonImage, for: .normal)
            }else{
                playButton.setImage(playButtonImage, for: .normal)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
            self.playingUpdate()
        }
    }
    
    
    //時間いい感じにするやつ
    func formatTimeString(d: Double) -> String {
        let s: Int = Int(d) % 60
        let m: Int = Int((d - Double(s)) / 60.0 )
        let str = String(format: "%02d:%02d", m, s)
        return str
    }
    
    //エラーメッセージとか表示する
    func showAlert(title:String, message:String) {
        // アラートを作成
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        // アラートにボタンをつける
        alert.addAction(UIAlertAction(title: "閉じる", style: .default))
        
        // アラート表示
        self.present(alert, animated: true, completion: nil)
    }
    
    //デバイス上にない音楽のデータを削除
    func deleteErrorData(){
        let analyzedData = MyCoreData.readPartMemo()
        for item in analyzedData{
            let property = MPMediaPropertyPredicate(value: item.ID, forProperty: MPMediaItemPropertyPersistentID)
            let query = MPMediaQuery()
            query.addFilterPredicate(property)
            var delete = false
            if let search = query.items{
                if(search.isEmpty){
                    delete = true
                }else{
                    if let _ = search.first!.assetURL {
                        delete = false
                    }else{
                        delete = true
                    }
                }
            }else{
                delete = true
            }
            if(delete){
                MyCoreData.deletePartMemo(id: item.ID)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                    self.showAlert(title: "ワーニング", message: "デバイス上にない音楽の解析データを確認したので削除しました。")
                }
            }
        }
    }
    
}

