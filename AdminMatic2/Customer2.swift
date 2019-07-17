//
//  Customer2.swift
//  AdminMatic2
//
//  Created by Nick on 6/5/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class Customer2: Codable {
    var ID: String
    var sysname:String
    
    
    //optional vars
    var address: String?
    var balance:String?
    var hear:String?
    var active:String?
    var fname:String?
    var lname:String?
    var custNotes:String?
    var servNotes:String?

    
    enum CodingKeys : String, CodingKey {
        case ID
        case sysname
        
        case address = "mainAddr"
        case balance
        case hear
        case active
        case fname
        case lname
        case custNotes
        case servNotes
    }
    
    init(_ID:String, _sysname: String){
        self.ID = _ID
        self.sysname = _sysname
    }
    
    
    
   /* init(_ID:String, _sysname: String, _address:String){
        self.ID = _ID
        self.sysname = _sysname
        self.address = _address
    }*/
    
    /*
 
 "sysname":"East Ferry Condo Assocation","hear":1,"active":1,"balance":240,"fname":"Jim","lname":"Estes","custNotes":"2018 weekly clean up done, wants fall clean up but will let us know when roofers are gone - 10\/24","servNotes":"","mainAddr":"47 Conanicus Ave, Jamestown"
 
 */
    
 
 
 
    
    
    
}


