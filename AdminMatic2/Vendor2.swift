//
//  Vendor2.swift
//  AdminMatic2
//
//  Created by Nick on 6/6/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class Vendor2:Codable {
    
    
    enum CodingKeys : String, CodingKey {
        case ID
        case name
        case address = "mainAddr"
        case lng
        case lat
        case phone = "mainPhone"
        case website
        case balance
        case itemCost = "cost"
        case itemPrice = "price"
        case itemPreffered = "preffered"
    }
    
    
    var ID: String
    var name: String
    
    
    var address: String?
    var lng: String?
    var lat: String?
    var phone: String?
    var website: String?
    var balance: String?
    var itemCost: String?
    var itemPrice: String?
    var itemPreffered: String?
    
    
    init(_name:String, _id: String) {
        self.ID = _id
        self.name = _name
    }
    
}

