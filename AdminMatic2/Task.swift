//
//  Task.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation

class Task {
    
    var ID: String!
    var sort: String!
    var status: String!
    var task: String!
    var pic: String!
    var thumb: String!
    
    
    
    
    
    required init(_ID:String?, _sort: String?, _status:String?, _task:String?, _pic:String?, _thumb:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = "0"
        }
        if _sort != nil {
            self.sort = _sort
        }else{
            self.sort = ""
        }
        if _status != nil {
            self.status = _status
        }else{
            self.status = ""
        }
        if _task != nil {
            self.task = _task
        }else{
            self.task = ""
        }
        if _pic != nil {
            self.pic = _pic
        }else{
            self.pic = "0"
        }
        if _thumb != nil {
            self.thumb = _thumb
        }else{
            self.thumb = "0"
        }
        
    }
    
}
