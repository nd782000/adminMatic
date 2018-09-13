//
//  ContractTask.swift
//  AdminMatic2
//
//  Created by Nick on 8/14/18.
//  Copyright © 2018 Nick. All rights reserved.
//



import Foundation
import UIKit
import SwiftyJSON
import ObjectMapper

class ContractTask:Mappable {
    
    var ID: String!
    var contractItemID: String!
    var createDate: String!
    var createdBy: String!
    var sort: String!
    var taskDescription: String!
    var images: [Image] = []
    
    
    
    
    
    
    required init(_ID:String?, _contractItemID:String?, _createDate:String?, _createdBy:String?, _sort: String?, _taskDescription:String?, _images:[Image]?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = "0"
        }
        
        if _contractItemID != nil {
            self.contractItemID = _contractItemID
        }else{
            self.contractItemID = ""
        }
        
        
        if _createDate != nil {
            self.createDate = _createDate
        }else{
            self.createDate = ""
        }
        
        if _createdBy != nil {
            self.createdBy = _createdBy
        }else{
            self.createdBy = ""
        }
        
        if _sort != nil {
            self.sort = _sort
        }else{
            self.sort = ""
        }
        
        if _taskDescription != nil {
            self.taskDescription = _taskDescription
        }else{
            self.taskDescription = ""
        }
        
        if(_images != nil){
            self.images = _images!
        }else{
            self.images = []
        }
        
        
    }
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        print("Mapping")
        ID    <- map["ID"]
        contractItemID      <- map["contractItemID"]
        createDate      <- map["createDate"]
        createdBy      <- map["createdBy"]
        sort      <- map["sort"]
        taskDescription      <- map["taskDescription"]
    }
    
    
    
    
    
}
