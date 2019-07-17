//
//  License2.swift
//  AdminMatic2
//
//  Created by Nick on 6/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class License2:Codable {
    
    
    enum CodingKeys: String, CodingKey{
        case ID
        case name
        case expiration
        case number
        case status
        case issuer
        
    }
    var ID: String
    var name: String
    var expiration: String
    var number: String
    var status: String
    var issuer: String
    
    /*
     status:
     0 = expired
     1 = expiring soon
     2 = active
     
     */
    
    
    init(_ID:String,_name:String,_expiration:String,_number:String,_status:String,_issuer:String){
        
        self.ID = _ID
        self.name = _name
        self.expiration = _expiration
        self.number = _number
        self.status = _status
        self.issuer = _issuer
        
        
        
    }
    
    
    /*
    required init(_ID:String?, _name: String?, _expiration:String?, _number:String?, _status:String?, _issuer:String?) {
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
        
        if _expiration != nil {
            self.expiration = _expiration
        }else{
            self.expiration = ""
        }
        
        if _number != nil {
            self.number = _number
        }else{
            self.number = ""
        }
        
        if _status != nil {
            self.status = _status
        }else{
            self.status = ""
        }
        
        if _issuer != nil {
            self.issuer = _issuer
        }else{
            self.issuer = ""
        }
        
    }
 */
    
    
    
    
}
