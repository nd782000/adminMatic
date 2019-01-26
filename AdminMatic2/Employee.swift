//
//  Employee.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//
 

import Foundation

class Employee {
    
    
    
    
    var ID: String!
    var name: String!
    var lname: String!
    var fname: String!
    var username: String!
    var pic: String!
    var phone: String!
    var depID: String!
    var payRate: String!
    var appScore: String!
    var userLevel: Int!
    var userLevelName: String!
    
    var deptName: String!
    var deptColor: String!
    
    var crewName: String!
    var crewColor: String!
    //var crewColor2: String!
    
    var hasSignature:Bool = false
    
    required init(_ID:String?, _name: String?, _lname:String?, _fname:String?, _username:String?, _pic:String?, _phone:String?, _depID:String?, _payRate:String?, _appScore:String?, _userLevel:Int?, _userLevelName:String?) {
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
        
        if _lname != nil {
            self.lname = _lname
        }else{
            self.lname = ""
        }
        
        if _fname != nil {
            self.fname = _fname
        }else{
            self.fname = ""
        }
        
        if _username != nil {
            self.username = _username
        }else{
            self.username = ""
        }
        
        if _pic != nil {
            self.pic = _pic
        }else{
            self.pic = ""
        }
        
        if _phone != nil {
            self.phone = _phone
        }else{
            self.phone = ""
        }
        if _depID != nil {
            self.depID = _depID
        }else{
            self.depID = ""
        }
        if _payRate != nil {
            self.payRate = _payRate
        }else{
            self.payRate = ""
        }
        if _appScore != nil {
            self.appScore = _appScore
        }else{
            self.appScore = ""
        }
        if _userLevel != nil {
            self.userLevel = _userLevel
        }else{
            self.userLevel = 1
        }
        
        if _userLevelName != nil {
            self.userLevelName = _userLevelName
        }else{
            self.userLevelName = ""
        }
        
        //print("init emp ID = \(ID)")
    }
    
    //simple initializer
    init(_ID:String?, _name: String?, _pic:String?) {
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
        if _pic != nil {
            self.pic = _pic
        }else{
            self.pic = ""
        }
    }
}
