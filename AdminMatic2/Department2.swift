//
//  Department2.swift
//  AdminMatic2
//
//  Created by Nick on 6/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class Department2:Codable {
    
    enum CodingKeys: String, CodingKey{
        case ID
        case name
        case status
        case color
        case depHead
    }
    
    
    var ID: String
    var name: String
    var status: String
    var color: String
    var depHead: String
    
    var crews:[Crew2] = []
    var emps:[Employee2] = []
    
    
    init(_ID:String, _name: String,_status:String,  _color:String,  _depHead:String) {
            self.ID = _ID
            self.name = _name
            self.status = _status
            self.color = _color
            self.depHead = _depHead
        
    }
}



