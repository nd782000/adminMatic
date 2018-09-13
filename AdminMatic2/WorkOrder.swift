//
//  WorkOrder.swift
//  Atlantic_Blank
//
//  Created by nicholasdigiando on 11/23/15.
//  Copyright (c) 2015 Nicholas Digiando. All rights reserved.
//

import Foundation

class WorkOrder {
    var ID: String!
    var statusId: String!
    var date: String!
    var firstItem: String!
    var statusName: String!
    var customer: String!
    var type: String!
    var progress:String!
    var title:String!
    var totalPrice:String!
    var totalCost:String!
    var totalPriceRaw:String!
    var totalCostRaw:String!
    var charge:String!
    
    var itemRemQty:String?
    
    var plowDepth:String = "NA"
    var plowPriority:String = "NA"
    var plowMonitoring:String = "NA"
    
    
    var customerName:String = ""
    var invoiceType:String = ""
    var scheduleType:String = "5"
    var department:String = "0"
    var crew:String = "0"
    var crewName:String = ""
    var rep:String = ""
    var repName:String = ""
    var notes:String = ""
    
    
    required init(_ID:String?, _statusID: String?, _date:String?, _firstItem:String?, _statusName:String?, _customer:String?, _type:String?, _progress:String?, _totalPrice:String?, _totalCost:String?, _totalPriceRaw:String?, _totalCostRaw:String?, _charge:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _statusID != nil {
            self.statusId = _statusID
        }else{
            self.statusId = ""
        }
        if _date != nil {
            self.date = _date
        }else{
            self.date = ""
        }
        
        if _firstItem != nil {
            self.firstItem = _firstItem
        }else{
            self.firstItem = ""
        }
        if _statusName != nil {
            self.statusName = _statusName
        }else{
            self.statusName = ""
        }
        if _customer != nil {
            self.customer = _customer
        }else{
            self.customer = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        if _progress != nil {
            self.progress = _progress
        }else{
            self.progress = ""
        }
        
        if _totalPrice != nil {
            self.totalPrice = _totalPrice
        }else{
            self.totalPrice = ""
        }
        
        if _totalCost != nil {
            self.totalCost = _totalCost
        }else{
            self.totalCost = ""
        }
        
        if _totalPriceRaw != nil {
            self.totalPriceRaw = _totalPriceRaw
        }else{
            self.totalPriceRaw = ""
        }
        
        if _totalCostRaw != nil {
            self.totalCostRaw = _totalCostRaw
        }else{
            self.totalCostRaw = ""
        }
        
        
        if _charge != nil {
            self.charge = _charge
        }else{
            self.charge = ""
        }
        
        if self.ID! == "0"{
            title = ""
        }else{
            title = "\(self.firstItem!)  \(self.customer!) #\(self.ID!)"
        }
        
    }
}
