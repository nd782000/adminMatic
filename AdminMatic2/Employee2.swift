//
//  Employee2.swift
//  AdminMatic2
//
//  Created by Nick on 6/7/19.
//  Copyright © 2019 Nick. All rights reserved.
//



import Foundation

class Employee2:Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case ID
        case name
        case lName = "lname"
        case fName = "fname"
        case userName = "username"
        case userLevel = "level"
        case userLevelName = "levelName"
        case licenseArray = "licenses"
        case hasSignature
        
        case pic
        case payRate
        case phone
        case appScore
        case depID = "dep"
    
    }
    
    
    var ID: String
    var name: String
    var lName: String
    var fName: String
    var userName: String
    var userLevel: String
    var userLevelName: String
    
    var licenseArray:[License2]? = []
    var hasSignature:Bool? = false
    var pic: String?
    var phone: String?
    var payRate: String?
    var appScore: String?
    
    var depID: String?
    var deptName: String?
    var deptColor: String?
    
    var crewName: String?
    var crewColor: String?
    
    init (_ID:String,_name:String,_lName:String,_fName:String,_userName:String,_userLevel:String,_userLevelName:String){
        
        self.ID = _ID
        self.name = _name
        self.lName = _lName
        self.fName = _fName
        self.userName = _userName
        self.userLevel = _userLevel
        self.userLevelName = _userLevelName
    }
    
    
   
    
    
    
}

