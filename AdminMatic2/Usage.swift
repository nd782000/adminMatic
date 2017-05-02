//
//  Usage.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import SwiftyJSON
import ObjectMapper


class Usage:Mappable{
    var ID: String?
    var empID: String?
    var depID: String?
    var woID: String?
    var start: Date?
    var stop: Date?
    var lunch: String?
    var qty: String?
    var empName: String?
    var type: String?
    var itemID: String?
    var unitPrice: String?
    var totalPrice: String?
    var vendor: String?
    var unitCost: String?
    var totalCost: String?
    var chargeType: String?
    var override: String?
    var empPic: String?
    var locked: Bool?
    var addedBy: String?
    var del: String?
    
    var custName:String?
    var woStatus:String?
   
    
    //init with stop
    init(_ID:String?,_empID:String?,_depID:String?, _woID:String?,_start:Date?, _stop:Date?,_lunch:String?, _qty:String?,_empName:String?,_type: String?,_itemID:String?,_unitPrice:String?,_totalPrice:String?,_vendor:String?,_unitCost:String?,_totalCost:String?,_chargeType:String?, _override:String?,_empPic:String?,_locked:Bool?,_addedBy:String?, _del:String?) {
        
        
        print("usage with stop")
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _empID != nil {
            self.empID = _empID
        }else{
            self.empID = ""
        }
        if _depID != nil {
            self.depID = _depID
        }else{
            self.depID = ""
        }
        if _woID != nil {
            self.woID = _woID
        }else{
            self.woID = ""
        }
        
        if _start != nil {
            self.start = _start
        }else{
            self.start = nil
        }
        
        if _stop != nil {
            self.stop = _stop
        }else{
            self.stop = nil
        }
 
        if _lunch != nil {
            self.lunch = _lunch
        }else{
            self.lunch = ""
        }
        if _qty != nil {
            self.qty = _qty
        }else{
            self.qty = ""
        }
        
        if _empName != nil {
            self.empName = _empName
        }else{
            self.empName = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        if _itemID != nil {
            self.itemID = _itemID
        }else{
            self.itemID = ""
        }
        if _unitPrice != nil {
            self.unitPrice = _unitPrice
        }else{
            self.unitPrice = ""
        }
        if _totalPrice != nil {
            self.totalPrice = _totalPrice
        }else{
            self.totalPrice = ""
        }
        if _vendor != nil {
            self.vendor = _vendor
        }else{
            self.vendor = ""
        }
        if _unitCost != nil {
            self.unitCost = _unitCost
        }else{
            self.unitCost = ""
        }
        if _totalCost != nil {
            self.totalCost = _totalCost
        }else{
            self.totalCost = ""
        }
        
        if _chargeType != nil {
            self.chargeType = _chargeType
        }else{
            self.chargeType = ""
        }
        if _override != nil {
            self.override = _override
        }else{
            self.override = "1"
        }
        if _empPic != nil {
            self.empPic = _empPic
        }else{
            self.empPic = ""
        }
        if _locked != nil {
            self.locked = _locked
        }else{
            self.locked = false
        }
        if _addedBy != nil {
            self.addedBy = _addedBy
        }else{
            self.addedBy = ""
        }
        if _del != nil {
            self.del = _del
        }else{
            self.del = ""
        }

    }
    
    
    //init without stop
    init(_ID:String?,_empID:String?,_depID:String?, _woID:String?,_start:Date?,_lunch:String?, _qty:String?,_empName:String?,_type: String?,_itemID:String?,_unitPrice:String?,_totalPrice:String?,_vendor:String?,_unitCost:String?,_totalCost:String?,_chargeType:String?, _override:String?,_empPic:String?,_locked:Bool?,_addedBy:String?, _del:String?) {
        
        
        print("usage without stop")
        
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _empID != nil {
            self.empID = _empID
        }else{
            self.empID = ""
        }
        if _depID != nil {
            self.depID = _depID
        }else{
            self.depID = ""
        }
        if _woID != nil {
            self.woID = _woID
        }else{
            self.woID = ""
        }
        
        if _start != nil {
            self.start = _start
        }else{
            self.start = nil
        }
        
        if _lunch != nil {
            self.lunch = _lunch
        }else{
            self.lunch = ""
        }
        if _qty != nil {
            self.qty = _qty
        }else{
            self.qty = ""
        }
        
        if _empName != nil {
            self.empName = _empName
        }else{
            self.empName = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        if _itemID != nil {
            self.itemID = _itemID
        }else{
            self.itemID = ""
        }
        if _unitPrice != nil {
            self.unitPrice = _unitPrice
        }else{
            self.unitPrice = ""
        }
        if _totalPrice != nil {
            self.totalPrice = _totalPrice
        }else{
            self.totalPrice = ""
        }
        if _vendor != nil {
            self.vendor = _vendor
        }else{
            self.vendor = ""
        }
        if _unitCost != nil {
            self.unitCost = _unitCost
        }else{
            self.unitCost = ""
        }
        if _totalCost != nil {
            self.totalCost = _totalCost
        }else{
            self.totalCost = ""
        }
        
        if _chargeType != nil {
            self.chargeType = _chargeType
        }else{
            self.chargeType = ""
        }
        if _override != nil {
            self.override = _override
        }else{
            self.override = "1"
        }
        if _empPic != nil {
            self.empPic = _empPic
        }else{
            self.empPic = ""
        }
        if _locked != nil {
            self.locked = _locked
        }else{
            self.locked = false
        }
        if _addedBy != nil {
            self.addedBy = _addedBy
        }else{
            self.addedBy = ""
        }
        if _del != nil {
            self.del = _del
        }else{
            self.del = ""
        }
        
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
        
        
        
        print("del = \(del)")
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



