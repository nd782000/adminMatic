//
//  Usage2.swift
//  AdminMatic2
//
//  Created by Nick on 6/6/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation
import UIKit
import ObjectMapper


class Usage2:Codable, Mappable{
    
    enum CodingKeys : String, CodingKey {
        case ID
        case woID
        case itemID = "woItemID"
        case type
        case addedBy
        case qty
        
        
        
        
        case empID
        case depID
        case startString = "start"
        case stopString = "stop"
        case lunch
        
        case empName
        
        case unitPrice
        case totalPrice
        case vendor
        case unitCost
        case totalCost
        case chargeType
        case override
        case empPic
        case del
        case custName
        case woStatus
        case hasReceipt
        
        
        
        //case receipt
        
    }
    
    var ID: String?
    var woID: String?
    var itemID: String?
    var type: String?
    var addedBy: String?
    var qty: String?
    

    
    var empID: String?
    var depID: String?
    var startString: String?
    var stopString: String?
    
    var start: Date?
    var stop: Date?
    var lunch: String? = "0.0"
    
    var empName: String?
    
    var unitPrice: String?
    var totalPrice: String?
    var vendor: String?
    var unitCost: String?
    var totalCost: String?
    var chargeType: String?
    var override: String?
    var empPic: String?
    var del: String?
    var custName:String?
    var woStatus:String?
    var hasReceipt:String?
    
    
    var locked: Bool?
    
    var receipt:Image2?
    
    
    init(_ID:String,_woID:String,_itemID:String,_type: String,_addedBy:String,_qty:String) {
        self.ID = _ID
        self.woID = _woID
        self.itemID = _itemID
        self.type = _type
        self.addedBy = _addedBy
        self.qty = _qty
    }
    
   
    
    
    required init?(map: Map) {
    }
 
    
    
    func mapping(map: Map) {
        print("Mapping")
        ID    <- map["ID"]
        empID      <- map["empID"]
        depID      <- map["depID"]
        woID      <- map["woID"]
        lunch      <- map["lunch"]
        qty      <- map["qty"]
        empName      <- map["empName"]
        type      <- map["type"]
        itemID      <- map["itemID"]
        unitPrice      <- map["unitPrice"]
        totalPrice      <- map["totalPrice"]
        vendor      <- map["vendor"]
        unitCost      <- map["unitCost"]
        totalCost      <- map["totalCost"]
        chargeType      <- map["usageCharge"]
        override      <- map["override"]
        empPic      <- map["empPic"]
        locked      <- map["locked"]
        addedBy      <- map["addedBy"]
        del      <- map["del"]
        
        
        
        //print("del = \(String(describing: del))")
        let dateTransform = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //yyyy-MM-dd
            return dateFormatter.date(from: value!)
        }, toJSON: { (value: Date?) -> String? in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: value!)
        })
        
        
        start      <- (map["start"], dateTransform)
        if(stop == nil){
            print("stop = nil")
        }else{
            stop      <- (map["stop"], dateTransform)
        }
        
    }
    
}



