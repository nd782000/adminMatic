//
//  Shift.swift
//  AdminMatic2
//
//  Created by Nick on 2/18/18.
//  Copyright © 2018 Nick. All rights reserved.
//

import Foundation

class Shift {
    
    var ID: String!
    var empID: String!
    var startTime: Date!
    var stopTime: Date!
    var status: String!
    var comment: String!
    var qty: String!
    
     
    required init(_ID:String?, _empID: String?, _startTime:Date?, _stopTime:Date?, _status:String?, _comment:String?, _qty:String?) {
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
        
        if(_status != nil){
            self.status = _status!
        }else{
            self.status = ""
        }
        
        if(_comment != nil){
            self.comment = _comment!
        }else{
            self.comment = ""
        }
        
        if(_qty != nil){
            self.qty = _qty!
        }else{
            self.qty = ""
        }
        
        
    }
    
}

