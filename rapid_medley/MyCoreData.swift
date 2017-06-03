//
//  CoreData.swift
//  rapid_medley
//
//  Created by base64 on 2017/05/30.
//  Copyright © 2017年 basemusi. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class MyCoreData{
    //CoreDataからの読み出し
    class func readPartMemo() -> [PartMusic]{
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        let query: NSFetchRequest<PartMemo> = PartMemo.fetchRequest()
        var ret : [PartMusic] = []
        do {
            let fetchResults = try viewContext.fetch(query)
            for result: AnyObject in fetchResults {
                let bpm: Int? = result.value(forKey: "bpm") as? Int
                let scalefrom: Int? = result.value(forKey: "scalefrom") as? Int
                let scaleto: Int? = result.value(forKey: "scaleto") as? Int
                let music: String? = result.value(forKey: "music") as? String
                let start: Int? = result.value(forKey: "start") as? Int
                let end: Int? = result.value(forKey: "end") as? Int
                let volume: Float? = result.value(forKey: "volume") as? Float
                let id: Int64? = result.value(forKey: "id") as? Int64
                ret.append(PartMusic(bpm: bpm!,
                                     scaleFrom: scalefrom!,
                                     scaleTo: scaleto!,
                                     music: URL(string: music!)!,
                                     start: start!,
                                     end: end!,
                                     volume: volume!,
                                     id: Int64(id!))
                )
            }
        } catch {
            print("readふえぇ")
        }
        return ret
    }
    
    //CoreDataに保存する
    class func savePartData(save: [PartMusic]){
        for pm in save {
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let viewContext = appDelegate.persistentContainer.viewContext
            let memo = NSEntityDescription.entity(forEntityName: "PartMemo", in: viewContext)
            let newRecord = NSManagedObject(entity: memo!, insertInto: viewContext)
            newRecord.setValue(pm.BPM, forKey: "bpm")
            newRecord.setValue(pm.SCALEFROM, forKey: "scalefrom")
            newRecord.setValue(pm.SCALETO, forKey: "scaleto")
            newRecord.setValue(pm.MUSIC, forKey: "music")
            newRecord.setValue(pm.START, forKey: "start")
            newRecord.setValue(pm.END, forKey: "end")
            newRecord.setValue(pm.VOLUME, forKey: "volume")
            newRecord.setValue(pm.ID, forKey: "id")
            appDelegate.saveContext()
        }
    }
    
    //CoreDataからの読み出し
    class func readPlayingData() -> PlayingData{
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        let query: NSFetchRequest<PlayingDataMemo> = PlayingDataMemo.fetchRequest()
        let ret = PlayingData()
        do {
            let fetchResults = try viewContext.fetch(query)
            for result: AnyObject in fetchResults {
                let cut: Float? = result.value(forKey: "cut") as? Float
                let id: Int64? = result.value(forKey: "id") as? Int64
                ret.add(cut: cut!, id: id!)
            }
        } catch {
            print("readふえぇ")
        }
        return ret
    }
    
    //CoreDataを削除してから保存する
    class func savePlayingData(save: PlayingData){
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<PlayingDataMemo> = PlayingDataMemo.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                let record = result as! NSManagedObject
                viewContext.delete(record)
            }
            appDelegate.saveContext()
        } catch {
            print("deleteふえぇ")
        }
        for i in 0..<save.cutTime.count {
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let viewContext = appDelegate.persistentContainer.viewContext
            let memo = NSEntityDescription.entity(forEntityName: "PlayingDataMemo", in: viewContext)
            let newRecord = NSManagedObject(entity: memo!, insertInto: viewContext)
            newRecord.setValue(save.cutTime[i], forKey: "cut")
            newRecord.setValue(save.musicId[i], forKey: "id")
            appDelegate.saveContext()
        }
    }
    
    //解析済みidを求める
    class func readAnalyzedId() -> [Int64]{
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        let query: NSFetchRequest<PartMemo> = PartMemo.fetchRequest()
        var ret : [Int64] = []
        do {
            let fetchResults = try viewContext.fetch(query)
            for result: AnyObject in fetchResults {
                let id: Int64? = result.value(forKey: "id") as? Int64
                var push = true
                for i in ret{
                    if(i == id){
                        push = false
                    }
                }
                if(push){
                    ret.append(id!)
                }
            }
        } catch {
            print("readふえぇ")
        }
        return ret
    }
    
    //解析したデータを削除するwith id
    //CoreDataを削除してから保存する
    class func deletePartMemo(id: Int64){
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<PartMemo> = PartMemo.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                let savedId: Int64? = result.value(forKey: "id") as? Int64
                if(savedId! == id){
                    let record = result as! NSManagedObject
                    viewContext.delete(record)
                }
            }
            appDelegate.saveContext()
        } catch {
            print("deleteふえぇ")
        }
    }
}
