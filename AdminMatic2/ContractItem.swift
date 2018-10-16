//
//  ContractItem.swift
//  AdminMatic2
//
//  Created by Nick on 4/17/18.
//  Copyright © 2018 Nick. All rights reserved.
//



import Foundation

class ContractItem {
    
    var ID: String!
    var name: String!
    var chargeType: String!
    //var sort: String!
    var qty: String!
    var contractID: String!
    var price: String!
    var createDate: String!
    var itemID: String!
    var totalImages: String!
    var tasks: [ContractTask] = []
    var total: String!
    var type: String!
    var taxCode: String!
    var subcontractor: String!
   
    var contractTitle:String!
    
    init(_ID: String?,_chargeType: String?,_contractID: String?,_createDate: String?,_itemID: String?,_name: String?,_price: String?,_qty: String?,_totalImages: String?,_total: String?,_type: String?,_taxCode: String?,_subcontractor: String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        
        if _chargeType != nil {
            self.chargeType = _chargeType
        }else{
            self.chargeType = ""
        }
        
        if _contractID != nil {
            self.contractID = _contractID
        }else{
            self.contractID = ""
        }
        
        if _createDate != nil {
            self.createDate = _createDate
        }else{
            self.createDate = ""
        }
        
        if _itemID != nil {
            self.itemID = _itemID
        }else{
            self.itemID = ""
        }
        
        
        if _name != nil {
            self.name = _name
        }else{
            self.ID = ""
        }
        
        if _price != nil {
            self.price = _price
        }else{
            self.price = ""
        }
        
        if _qty != nil {
            self.qty = _qty
        }else{
            self.qty = ""
        }
        
        /*
        if _sort != nil {
            self.sort = _sort
        }else{
            self.sort = ""
        }
        */
        
        
        if _totalImages != nil {
            self.totalImages = _totalImages
        }else{
            self.totalImages = ""
        }
        
        if _total != nil {
            self.total = _total
        }else{
            self.total = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        
        if _taxCode != nil {
            self.taxCode = _taxCode
        }else{
            self.taxCode = ""
        }
        
        if _subcontractor != nil {
            self.subcontractor = _subcontractor
        }else{
            self.subcontractor = ""
        }
        
        
        
        
    }
    
    
    init(_ID: String?,_contractID: String?,_name: String?,_contractTitle: String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        
        
        
        if _contractID != nil {
            self.contractID = _contractID
        }else{
            self.contractID = ""
        }
        
       
        
        if _name != nil {
            self.name = _name
        }else{
            self.ID = ""
        }
        
        
        if _contractTitle != nil {
            self.contractTitle = _contractTitle
        }else{
            self.contractTitle = ""
        }
        
        
    }
    
    
    
    
}
