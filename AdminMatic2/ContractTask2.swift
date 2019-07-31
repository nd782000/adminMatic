//
//  ContractTask2.swift
//  AdminMatic2
//
//  Created by Nick on 7/8/19.
//  Copyright © 2019 Nick. All rights reserved.
//





import Foundation
import UIKit
import ObjectMapper

class ContractTask2:Codable,Mappable {
    
    
    enum CodingKeys : String, CodingKey {
        case ID
        case contractItemID
        case createdBy
        case sort
        case createDate
        case taskDescription
        case images
       
        
    }
        
    var ID: String!
    var contractItemID: String!
    var createdBy: String!
    var sort: String!
    var createDate: String!
    var taskDescription: String!
    
    var images: [Image2]? = []
    
    
    
    init(_ID:String, _contractItemID:String, _createdBy:String, _sort: String, _createDate: String, _taskDescription: String) {
        self.ID = _ID
        self.contractItemID = _contractItemID
        self.createdBy = _createdBy
        self.sort = _sort
        self.createDate = _createDate
        self.taskDescription = _taskDescription
        
    }
    
    
    
    /*
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
 */
    
    
    
    
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
