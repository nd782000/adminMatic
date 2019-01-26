//
//  Payroll.swift
//  AdminMatic2
//
//  Created by Nick on 2/20/18.
//  Copyright © 2018 Nick. All rights reserved.
// 

//
//  Shift.swift
//  AdminMatic2
//
//  Created by Nick on 2/18/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import ObjectMapper


class Payroll {
    
    var ID: String!
    var empID: String!
    var startTime: Date!
    var stopTime: Date!
    var lunch: String!
    var date: Date!
    var total: String!
    var verified: String!
    var createdBy: String!
    
    var del: String! // used for deleting unvarified payroll rows
    var noStop: Bool = false
    
    
    
    required init(_ID:String?, _empID: String?, _startTime:Date?, _stopTime:Date?, _lunch:String?, _date:Date?, _total:String?, _verified:String?, _createdBy:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = "0"
        }
        if _empID != nil {
            self.empID = _empID
        }else{
            self.empID = ""
        }
        if _startTime != nil {
            self.startTime = _startTime
        }else{
            self.startTime = nil
        }
        if _stopTime != nil {
            self.stopTime = _stopTime
        }else{
            self.stopTime = nil
        }
        if _lunch != nil {
            self.lunch = _lunch
        }else{
            self.lunch = "0"
        }
        if _date != nil {
            self.date = _date
        }else{
            self.date = nil
        }
        if(_total != nil){
            self.total = _total!
        }else{
            self.total = ""
        }
        if(_verified != nil){
            self.verified = _verified!
        }else{
            self.verified = "0"
        }
        if(_createdBy != nil){
            self.createdBy = _createdBy!
        }else{
            self.createdBy = ""
        }
        
    }
    
    //init without start and stop
    required init(_ID:String?, _empID: String?, _lunch:String?, _date:Date?, _total:String?, _verified:String?, _createdBy:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = "0"
        }
        if _empID != nil {
            self.empID = _empID
        }else{
            self.empID = ""
        }
        if _lunch != nil {
            self.lunch = _lunch
        }else{
            self.lunch = "0"
        }
        if _date != nil {
            self.date = _date
        }else{
            self.date = nil
        }
        if(_total != nil){
            self.total = _total!
        }else{
            self.total = ""
        }
        if(_verified != nil){
            self.verified = _verified!
        }else{
            self.verified = "0"
        }
        if(_createdBy != nil){
            self.createdBy = _createdBy!
        }else{
            self.createdBy = ""
        }
        
    }
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        print("Mapping")
        ID    <- map["ID"]
        empID      <- map["empID"]
        
        lunch      <- map["lunch"]
        total      <- map["total"]
        verified      <- map["verified"]
        createdBy      <- map["createdBy"]
        
        
        
        
        //print("del = \(String(describing: del))")
        let dateTransform = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //yyyy-MM-dd
            return dateFormatter.date(from: value!)
        }, toJSON: { (value: Date?) -> String? in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: value!)
        })
        
        date      <- (map["date"], dateTransform)
        startTime      <- (map["startTime"], dateTransform)
        if(stopTime == nil){
            print("stop = nil")
        }else{
            stopTime      <- (map["stopTime"], dateTransform)
        }
        
    }
    
    
    
}


