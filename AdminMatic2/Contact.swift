//
//  Contact.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation

class Contact {
    var ID: String!
    var sort: String!
    var value: String!
    var type: String!
    var contactName: String!
    var main: String!
    var name: String!
    var street1: String!
    var street2: String!
    var city: String!
    var state: String!
    var zip: String!
    var zone: String!
    var zoneName: String!
    var color: String!
    var lat: NSString!
    var lng: NSString!
    var layoutVars:LayoutVars = LayoutVars()
    
    init(_ID:String?){
        
    }
    
    convenience init(_ID:String?,_sort:String?,_value:String?,_type:String?,_contactName:String?,_main:String?,_name:String?, _street1:String?, _street2:String?, _city:String?, _state:String?, _zip:String?, _zone:String?, _zoneName:String?, _color:String?, _lat:NSString?, _lng:NSString?) {
        self.init(_ID: _ID)
        if _ID != nil {self.ID = _ID}else{self.ID = ""}
        if _sort != nil {self.sort = _sort}else{self.sort = ""}
        if _value != nil {self.value = _value}else{self.value = ""}
        
        if _type != nil {self.type = _type}else{self.type = ""}
        if (self.type == "1"){
            self.value = cleanPhoneNumber(_value)
        }
        if _contactName != nil {self.contactName = _contactName}else{self.contactName = ""}
        if _main != nil {self.main = _main}else{self.main = ""}
        if _name != nil {self.name = _name}else{self.name = ""}
        if _street1 != nil {self.street1 = _street1}else{self.street1 = ""}
        if _street2 != nil {self.street2 = _street2}else{self.street2 = ""}
        if _city != nil {self.city = _city}else{self.city = ""}
        if _state != nil {self.state = _state}else{self.state = ""}
        if _zip != nil {self.zip = _zip}else{self.zip = ""}
        if _zone != nil {self.zone = _zone}else{self.zone = ""}
        if _zoneName != nil {self.zoneName = _zoneName}else{self.zoneName = ""}
        if _color != nil {self.color = _color}else{self.color = ""}
        if _lat != nil {self.lat = _lat}else{self.lat = ""}
        if _lng != nil {self.lng = _lng}else{self.lng = ""}
    }
    
}
