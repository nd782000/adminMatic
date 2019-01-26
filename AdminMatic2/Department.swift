//
//  Department.swift
//  AdminMatic2
//
//  Created by Nick on 2/16/18.
//  Copyright © 2018 Nick. All rights reserved.
//
 

import Foundation

class Department {
    var ID: String!
    var name: String!
    var status: String!
    var color: String!
    var depHead: String!
    
    var employeeArray:[Employee] = []
    
    
    required init(_ID:String?, _name: String?,_status:String?,  _color:String?,  _depHead:String?) {
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
        if _depHead != nil {
            self.depHead = _depHead
        }else{
            self.depHead = ""
        }
        
        
    }
}



