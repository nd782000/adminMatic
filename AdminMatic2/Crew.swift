//
//  Crew.swift
//  AdminMatic2
//
//  Created by Nick on 2/16/18.
//  Copyright © 2018 Nick. All rights reserved.
//
 
//
//  Department.swift
//  AdminMatic2
//
//  Created by Nick on 2/16/18.
//  Copyright © 2018 Nick. All rights reserved.
//


import Foundation

class Crew {
    var ID: String!
    var name: String!
    var status: String!
    var color: String!
    var crewHead: String!
    
    var employeeArray:[Employee] = []
    
    
    required init(_ID:String?, _name: String?, _status:String?,  _color:String?, _crewHead:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        if _status != nil {
            self.status = _status
        }else{
            self.status = ""
        }
        if _color != nil {
            self.color = _color
        }else{
            self.color = ""
        }
        
        if _crewHead != nil {
            self.crewHead = _crewHead
        }else{
            self.crewHead = ""
        }
        
        
    }
    
    
    init(_ID:String?, _name: String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        
        
        
    }
    
    
}




