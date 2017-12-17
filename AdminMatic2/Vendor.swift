//
//  Vendor.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation

class Vendor {
    var ID: String!
    var name: String!
    var address: String!
    var lng: String!
    var lat: String!
    var phone: String!
    var website: String!
    var balance: String!
    var itemCost: String?
    var itemPrice: String?
    var itemPreffered: String?
    
    
    required init(_name:String?, _id: String?, _address:String?, _phone:String?, _website:String?, _balance:String?, _lng:String?, _lat:String?) {
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
        
        if _address != nil {
            self.address = _address
        }else{
            self.address = "No Address on File"
        }
        if _phone != nil {
            self.phone = _phone
        }else{
            self.phone = ""
        }
        if _website != nil {
            self.website = _website
        }else{
            self.website = ""
        }
        if _balance != nil {
            self.balance = _balance
        }else{
            self.balance = ""
        }
        if _lng != nil {
            self.lng = _lng
        }else{
            self.lng = ""
        }
        if _lat != nil {
            self.lat = _lat
        }else{
            self.lat = ""
        }
        
    }
}
