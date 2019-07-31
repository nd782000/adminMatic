//
//  ContractItem2.swift
//  AdminMatic2
//
//  Created by Nick on 7/8/19.
//  Copyright © 2019 Nick. All rights reserved.
//




import Foundation
import ObjectMapper

class ContractItem2:Codable {
    
    
    enum CodingKeys : String, CodingKey {
        case ID
        case name
        case chargeType
        case qty
        case contractID
        case itemID
        case price
        case createDate
        case totalImages
        case tasks
        case total
        case type
        case taxCode = "taxType"
        case subcontractor
        case hideUnits
        case contractTitle
        
    }

    var ID: String
    var name: String
    var chargeType: String
    var qty: String
    var contractID: String
    var itemID: String
    var tasks: [ContractTask2] = []
    
    
    var price: String?
    var createDate: String?
    var totalImages: String?
    
    var total: String?
    var type: String?
    var taxCode: String?
    var subcontractor: String?
    var hideUnits: String?
    var contractTitle:String?
    
    
    init(_ID: String,_chargeType: String,_contractID: String,_itemID: String,_name: String,_qty: String) {
        //print(json)
       
        self.ID = _ID
        self.chargeType = _chargeType
        self.contractID = _contractID
        self.itemID = _itemID
        self.name = _name
        self.qty = _qty
        
    }
    
    /*
    init(_ID: String?,_chargeType: String?,_contractID: String?,_createDate: String?,_itemID: String?,_name: String?,_price: String?,_qty: String?,_totalImages: String?,_total: String?,_type: String?,_taxCode: String?,_subcontractor: String?,_hideUnits: String?) {
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
            self.total = "0.00"
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
        
        if _hideUnits != nil {
            self.hideUnits = _hideUnits
        }else{
            self.hideUnits = ""
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
    
    
    init(_ID: String?,_chargeType: String?,_contractID: String?,_itemID: String?,_name: String?,_price: String?,_qty: String?,_total: String?,_type: String?,_taxCode: String?,_subcontractor: String?,_hideUnits: String?) {
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
        
        
        
        if _total != nil {
            self.total = _total
        }else{
            self.total = "0.00"
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
        
        if _hideUnits != nil {
            self.hideUnits = _hideUnits
        }else{
            self.hideUnits = ""
        }
        
        
        
        
    }
    
    */
    
    
    
    
    
    
}
