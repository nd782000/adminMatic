//
//  Task.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import SwiftyJSON
import ObjectMapper

class Task:Mappable {
    
    var ID: String!
    var sort: String!
    var status: String!
    var task: String!

    var images: [Image] = []

    
    
    
    
    
    required init(_ID:String?, _sort: String?, _status:String?, _task:String?, _images:[Image]?) {
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
        
        if(_images != nil){
            self.images = _images!
        }else{
            self.images = []
        }

        
    }
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        print("Mapping")
        ID    <- map["ID"]
        sort      <- map["sort"]
        status      <- map["status"]
        task      <- map["task"]
        
    }
    
    
    
    
    
}
