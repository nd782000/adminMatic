//
//  Crew2.swift
//  AdminMatic2
//
//  Created by Nick on 6/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class Crew2:Codable {
    
    enum CodingKeys : String, CodingKey{
        case ID = "crewID"
        case name
        
        case emps
        
    }
    
    
    var ID: String
    var name: String
    var emps:[Employee2] = []
    
    var status: String?
    var color: String?
    var crewHead: String?
    
    
    
    init(_ID:String, _name: String) {
        self.ID = _ID
        self.name = _name
        
    }
    
    /*
    init(_ID:String, _name: String, _status:String,  _color:String, _crewHead:String) {
            self.ID = _ID
            self.name = _name
            self.status = _status
            self.color = _color
            self.crewHead = _crewHead
    }*/
    
}




