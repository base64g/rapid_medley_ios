//
//  DeleteView.swift
//  rapid_medley
//
//  Created by base64 on 2017/05/31.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer
class DeleteView: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet var table:UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var images: [UIImage] = []
    
    var titles: [String] = []
    
    var ids:[Int64] = []
    
    var selected: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.allowsMultipleSelection = true
        ids = MyCoreData.readAnalyzedId()
        for id in ids{
            let property = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
            let query = MPMediaQuery()
            query.addFilterPredicate(property)
            if let singles = query.items {
                if let single = singles.first {
                    if let titleSafe = single.title{
                        titles.append(titleSafe)
                    }
                    if let artwork = single.artwork, let artworkImage = artwork.image(at: artwork.bounds.size)  {
                        images.append(artworkImage)
                    }
                }
            }
        }
    }
    
    @IBAction func pushDelete() {
        
        let alert: UIAlertController = UIAlertController(title: "確認", message: "本当に選択した解析データを削除してもいいですか？", preferredStyle:  UIAlertControllerStyle.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("OK")
            for i in self.selected{
                MyCoreData.deletePartMemo(id: self.ids[i])
                self.images.remove(at: i)
                self.titles.remove(at: i)
                self.table.reloadData()
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        
        let img = images[indexPath.row]
        
        let imageView = table.viewWithTag(1) as! UIImageView
        imageView.image = img
        let label = table.viewWithTag(2) as! UILabel
        label.text = titles[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        
        cell?.accessoryType = .checkmark
        selected.append(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        
        cell?.accessoryType = .none
        for i in 0..<selected.count {
            if(selected[i] == indexPath.row){
                selected.remove(at: i)
                break;
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
