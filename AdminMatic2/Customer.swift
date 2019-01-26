//
//  Customer.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
// 

import Foundation

class Customer {
    var ID: String
    var name: String
    var address: String
    var contactID: String
    
    required init(_name:String?, _id: String?, _address:String?, _contactID:String?) {
        //print(json)
        self.ID = _id ?? ""
        self.name = _name ?? ""
        self.address = _address ?? ""
        self.contactID = _contactID ?? ""
        
    }
}
 

