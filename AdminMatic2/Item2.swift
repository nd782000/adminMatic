//
//  Item2.swift
//  AdminMatic2
//
//  Created by Nick on 7/17/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation


class Item2: Codable {
    
    enum CodingKeys : String, CodingKey {
        case ID
        case name
        case typeName
        case type
        case totalRemainingQty = "remQty"
        case price
        case units = "unit"
        case description
        case taxable = "tax"
        
        case workOrders
        case vendors
        
    }
    
    
    
    var ID: String!
    var name: String!
    
    
    var type: String?
    var typeName: String?
    var totalRemainingQty: String?
    
    
    //var desc: String!
    //var cost: String!
    // var vendor: String!
    var price: String!
    var units: String!
    var description: String!
    var taxable: String!
    var workOrders: [WorkOrder2]?
    var vendors: [Vendor2]?
    
    required init(_name:String?, _id: String?, _type:String?, _price:String?, _units:String?, _description:String?, _taxable:String?) {
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
        if _description != nil {
            self.description = _description
        }else{
            self.description = ""
        }
        if _taxable != nil {
            self.taxable = _units
        }else{
            self.taxable = ""
        }
    }
}
