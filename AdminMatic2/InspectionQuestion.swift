//
//  InspectionQuestion.swift
//  AdminMatic2
//
//  Created by Nick on 1/23/19.
//  Copyright © 2019 Nick. All rights reserved.
//



 
import Foundation
import SwiftyJSON
import ObjectMapper


class InspectionQuestion:Mappable{
    var ID: String?
    var name: String?
    var answer: String?
    
    
//class InspectionQuestion {
   // var ID: String!
    //var name: String!
    //var answer:String!
    
    
    
    
    required init(_ID:String?, _name: String?, _answer:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = "0"
        }
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        if _answer != nil {
            self.answer = _answer
        }else{
            self.answer = "0"
        }
        
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        print("Mapping")
        ID    <- map["ID"]
        name    <- map["name"]
        answer    <- map["answer"]
        
    }
        
        
        
}

