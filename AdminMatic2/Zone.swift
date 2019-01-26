//
//  Zone.swift
//  AdminMatic2
//
//  Created by Nick on 8/21/18.
//  Copyright © 2018 Nick. All rights reserved.
//



import Foundation

class Zone {
    var ID: String!
    var name: String!
    
    
     
    
    required init(_ID:String?, _name: String?) {
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

