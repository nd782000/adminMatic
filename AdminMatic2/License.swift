//
//  License.swift
//  AdminMatic2
//
//  Created by Nick on 1/29/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class License {
    
    var ID: String!
    var name: String!
    var expiration: String!
    var number: String!
    var status: String!
    var issuer: String!
    
    /*
     status:
     0 = expired
     1 = expiring soon
     2 = active
 
 */
    

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
    
    
}
