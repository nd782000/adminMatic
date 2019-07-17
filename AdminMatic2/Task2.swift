//
//  Task2.swift
//  AdminMatic2
//
//  Created by Nick on 6/6/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation
import UIKit
//import SwiftyJSON
import ObjectMapper

class Task2:Codable, Mappable {
    
    
    
    
    
    enum CodingKeys : String, CodingKey {
        case ID
        case sort
        case status
        case task
        case images
    }
    
    var ID: String!
    var sort: String!
    var status: String!
    var task: String!
    
   var images: [Image2]? = []
    
    
    init(_ID:String, _sort: String, _status:String, _task:String) {
        //print(json)
            self.ID = _ID
            self.sort = _sort
            self.status = _status
            self.task = _task
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
