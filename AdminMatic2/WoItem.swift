//
//  WoItem.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//



import Foundation

class WoItem {
    
    var ID: String!
    var type: String!
    var sort: String!
    var input: String!
    var est: String!
    var empDesc: String!
    var itemStatus: String!
    var chargeID: String!
    var act: String!
    var price: String!
    var total: String!
    var totalCost: String!
    
    var tasks: [Task] = []
    var usages: [Usage] = []
    var usageQty: String!
    var extraUsage: String!
    
    var unit: String!
    
    var vendors: [Vendor] = []
    
    
    
    
    
    
    required init(_ID: String?,_type: String?,_sort: String?,_input: String?,_est: String?,_empDesc: String?,_itemStatus: String?,_chargeID: String?,_act: String?,_price: String?,_total: String?,_totalCost: String?,_usageQty: String?,_extraUsage: String?,_unit: String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        if _sort != nil {
            self.sort = _sort
        }else{
            self.sort = ""
        }
        if _input != nil {
            self.input = _input
        }else{
            self.input = ""
        }
        if _est != nil {
            self.est = _est
        }else{
            self.est = ""
        }
        if _empDesc != nil {
            self.empDesc = _empDesc
        }else{
            self.empDesc = ""
        }
        if _itemStatus != nil {
            self.itemStatus = _itemStatus
        }else{
            self.itemStatus = ""
        }
        if _chargeID != nil {
            self.chargeID = _chargeID
        }else{
            self.chargeID = ""
        }
        if _act != nil {
            self.act = _act
        }else{
            self.act = ""
        }
        if _price != nil {
            self.price = _price
        }else{
            self.price = ""
        }
        if _total != nil {
            self.total = _total
        }else{
            self.total = ""
        }
        if _totalCost != nil {
            self.totalCost = _totalCost
        }else{
            self.totalCost = ""
        }
        if _usageQty != nil {
            self.usageQty = _usageQty
        }else{
            self.usageQty = ""
        }
        if _extraUsage != nil {
            self.extraUsage = _extraUsage
        }else{
            self.extraUsage = "0"
        }
        if _unit != nil {
            self.unit = _unit
        }else{
            self.unit = ""
        }
        
        
        
    }
}
