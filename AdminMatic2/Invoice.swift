//
//  Invoice.swift
//  AdminMatic2
//
//  Created by Nick on 10/6/18.
//  Copyright © 2018 Nick. All rights reserved.
//
 

import Foundation

class Invoice {
    var ID: String!
    var date: String!
    var totalPrice:String!
    var customer:String!
    var customerName:String!
    var paid:String!
    
    
    var title:String?
    var chargeType:String?
    var repName:String?
    var notes:String?
    var subTotal:String?
    var taxTotal:String?
    var lead:Lead?
    var contract:Contract?
    
    
    //var customer: String!
    //var title:String!
    //var totalCost:String!
    //var totalPriceRaw:String!
    //var totalCostRaw:String!
    //var charge:String!
    //var invoiceType:String = ""
    //var rep:String = ""
    //var repName:String = ""
    //var notes:String = ""
    //var custAndPrice:String?
    
    
    required init(_ID:String?, _date:String?, _customer:String?, _customerName:String?, _totalPrice:String?, _paid:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        
        if _date != nil {
            self.date = _date
        }else{
            self.date = ""
        }
        
        if _customer != nil {
            self.customer = _customer
        }else{
            self.customer = ""
        }
       
        if _customerName != nil {
            self.customerName = _customerName
        }else{
            self.customerName = ""
        }
        
        if _totalPrice != nil {
            self.totalPrice = _totalPrice
        }else{
            self.totalPrice = ""
        }
        
       
        if _paid != nil {
            self.paid = _paid
        }else{
            self.paid = ""
        }
        
       
        
    }
    
    /*
    required init(_ID:String?, _date:String?, _customer:String?, _totalPrice:String?, _totalCost:String?, _totalPriceRaw:String?, _totalCostRaw:String?, _charge:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        
        if _date != nil {
            self.date = _date
        }else{
            self.date = ""
        }
        
        
        if _customer != nil {
            self.customer = _customer
        }else{
            self.customer = ""
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
            title = "\(self.customer!) #\(self.ID!)"
        }
        
    }
 */
    
}
