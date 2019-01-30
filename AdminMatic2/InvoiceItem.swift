//
//  InvoiceItem.swift
//  AdminMatic2
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation
import SwiftyJSON
import ObjectMapper

class InvoiceItem {
    
    var ID: String!
    var name: String!
    var chargeType: String!
    //var sort: String!
    var qty: String!
    var invoiceID: String!
    var price: String!
    var servicedDate: String!
    var itemID: String!
    var totalImages: String!
    //var tasks: [InvoiceTask] = []
    var total: String!
    var type: String!
    var taxCode: String!
    
    var hideUnits: String!
    
    var custDescription: String!
    
    
    
    var invoiceTitle:String!
    
    init(_ID: String?,_chargeType: String?,_invoiceID: String?,_servicedDate: String?,_itemID: String?,_name: String?,_price: String?,_qty: String?,_totalImages: String?,_total: String?,_type: String?,_taxCode: String?,_hideUnits: String?,_custDescription: String?) {
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
        
        if _invoiceID != nil {
            self.invoiceID = _invoiceID
        }else{
            self.invoiceID = ""
        }
        
        if _servicedDate != nil {
            self.servicedDate = _servicedDate
        }else{
            self.servicedDate = ""
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
        
       
        
        if _hideUnits != nil {
            self.hideUnits = _hideUnits
        }else{
            self.hideUnits = ""
        }
        
        if _custDescription != nil {
            self.custDescription = _custDescription
        }else{
            self.custDescription = ""
        }
        
        
        
        
    }
    
    
    init(_ID: String?,_invoiceID: String?,_name: String?,_invoiceTitle: String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        
        
        
        if _invoiceID != nil {
            self.invoiceID = _invoiceID
        }else{
            self.invoiceID = ""
        }
        
        
        
        if _name != nil {
            self.name = _name
        }else{
            self.ID = ""
        }
        
        
        if _invoiceTitle != nil {
            self.invoiceTitle = _invoiceTitle
        }else{
            self.invoiceTitle = ""
        }
        
        
    }
    
    /*
    init(_ID: String?,_chargeType: String?,_invoiceID: String?,_itemID: String?,_name: String?,_price: String?,_qty: String?,_total: String?,_type: String?,_taxCode: String?,_subcontractor: String?,_hideUnits: String?,_custDescription: String?) {
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
        
        if _invoiceID != nil {
            self.invoiceID = _invoiceID
        }else{
            self.invoiceID = ""
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
        
        if _custDescription != nil {
            self.custDescription = _custDescription
        }else{
            self.custDescription = ""
        }
        
        
        
        
    }
    
    */
    
    
    
    
    
    
    
}
