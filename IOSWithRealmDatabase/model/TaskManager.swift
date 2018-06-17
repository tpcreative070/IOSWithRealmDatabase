//
//  TaskManager.swift
//  IOSWithRealmDatabase
//
//  Created by Mac10 on 6/16/18.
//  Copyright © 2018 Mac10. All rights reserved.
//

import UIKit
import RealmSwift

class TaskManager: Object {

    @objc dynamic var key = ""
    @objc dynamic var task = ""
    @objc dynamic var date = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    public class var shared: TaskManager {
        struct Static {
            static let instance: TaskManager = TaskManager()
        }
        return Static.instance
    }
    
    /*In the case : Creating a task with the same primary key as a previously saved task */
    func added(task : TaskManager){
        let realm = try! Realm()
        try! realm.write() {
            realm.add(task,update:true)
        }
    }
    
    /*In the case : Creating a task with the unique primary key as a previously saved task */
    func created(task : TaskManager){
        let realm = try! Realm()
        try! realm.write() {
            realm.create(TaskManager.self, value: ["key": task.key, "task": task.task, "date" : task.date], update: true)
        }
    }
    
    func deleteAll(){
        let realm = try! Realm()
        try! realm.write() {
            realm.deleteAll()
        }
    }
    
    func delete(task : TaskManager){
        let realm = try! Realm()
        try! realm.write() {
            realm.delete(task)
        }
    }
    
    func getAll(callBack: @escaping ([TaskManager]) -> Void) {
        let realm = try! Realm()
        try! realm.write() {
            let result = realm.objects(TaskManager.self).sorted(byKeyPath: "key", ascending: false)
            let response = result.toArray(ofType: TaskManager.self)
            callBack(response)
            print(result)
        }
    }
    
    func getCurrentDateTime() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let currentDateTime = Date()
        let result = formatter.string(from: currentDateTime)
        return result
    }
    
    func currentTimeInMiliseconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
}

extension Int {
    //Milliseconds to date
    func dateFromMilliseconds() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self)/1000)
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        let array = Array(self) as! [T]
        return array
    }
}
