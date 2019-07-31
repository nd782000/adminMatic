//
//  Contact2.swift
//  AdminMatic2
//
//  Created by Nick on 7/25/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class Contact2:Codable {
    
    
    enum CodingKeys : String, CodingKey {
        case ID
        case sort
        case value
        case type
        case contactName
        case main
        case name
        case street1
        case street2
        case city
        case state
        case zip
        case zone
        case zoneName
        case color
        case lat
        case lng
        case fullAddress
        
        
    }
        
    
    var ID: String
    var sort: String
    var type: String
    
    var contactName: String?
    var value: String?
    var main: String?
    var name: String?
    var street1: String?
    var street2: String?
    var city: String?
    var state: String?
    var zip: String?
    var zone: String!
    var zoneName: String?
    var color: String?
    var lat: String?
    var lng: String?
    var fullAddress: String?
    // var layoutVars:LayoutVars = LayoutVars()
    
    init(_ID:String,_sort:String,_type:String){
        self.ID = _ID
        self.sort = _sort
        self.type = _type
       
    }

}
