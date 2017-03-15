//
//  Item.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation

class Item {
    
    var ID: String!
    var name: String!
    var type: String!
    //var desc: String!
    //var cost: String!
    // var vendor: String!
    var price: String!
    var units: String!
    
    
    required init(_name:String?, _id: String?, _type:String?, _price:String?, _units:String?) {
        //print(json)
        if _id != nil {
            self.ID = _id
        }else{
            self.ID = ""
        }
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        /*
         if _desc != nil {
         self.desc = _desc
         }else{
         self.desc = ""
         }
         if _cost != nil {
         self.cost = _cost
         }else{
         self.cost = ""
         }
         if _vendor != nil {
         self.vendor = _vendor
         }else{
         self.vendor = ""
         }
         */
        if _price != nil {
            self.price = _price
        }else{
            self.price = ""
        }
        if _units != nil {
            self.units = _units
        }else{
            self.units = ""
        }
    }
}
