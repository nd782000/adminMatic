//
//  Contract.swift
//  AdminMatic2
//
//  Created by Nick on 4/13/18.
//  Copyright © 2018 Nick. All rights reserved.
//
 
import Foundation

class Contract {
    var ID: String!
    var title: String!
    var status: String!
    var statusName: String!
    var chargeType: String! //1 = NC, 2 = FL, 3 = T&M
    var customer: String!
    var customerName: String!
    var notes: String!
    var salesRep: String!
    var repName: String!
    var createdBy: String!
    var createDate:String?
    var subTotal: String!
    var taxTotal: String!
    var total: String!
    var terms: String!
    var daysAged: String!
    
    var custNameAndID:String!
    
    var repSignature:String = "0"
    var customerSignature:String = "0"
    
    var repSignaturePath:String = ""
    var customerSignaturePath:String = ""
    
    
    
    var lead:Lead2?
    
    
    required init(_ID:String?, _title:String?, _status: String?, _statusName: String?, _chargeType:String?, _customer:String?, _customerName:String?, _notes:String?, _salesRep:String?, _repName:String?, _createdBy:String?, _createDate:String?, _subTotal:String?, _taxTotal:String?, _total:String?, _terms:String?, _daysAged:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _title != nil {
            self.title = _title
        }else{
            self.title = ""
        }
        if _status != nil {
            self.status = _status
        }else{
            self.status = ""
        }
        
        if _statusName != nil {
            self.statusName = _statusName
        }else{
            self.statusName = ""
        }
        if _chargeType != nil {
            self.chargeType = _chargeType
        }else{
            self.chargeType = ""
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
        if _notes != nil {
            self.notes = _notes
        }else{
            self.notes = ""
        }
        if _salesRep != nil {
            self.salesRep = _salesRep
        }else{
            self.salesRep = "0"
        }
        if _repName != nil {
            self.repName = _repName
        }else{
            self.repName = ""
        }
        if _createdBy != nil {
            self.createdBy = _createdBy
        }else{
            self.createdBy = ""
        }
        if _createDate != nil {
            self.createDate = _createDate
        }else{
            self.createDate = ""
        }
        
        if _subTotal != nil {
            self.subTotal = _subTotal
        }else{
            self.subTotal = ""
        }
        if _taxTotal != nil {
            self.taxTotal = _taxTotal
        }else{
            self.taxTotal = ""
        }
        if _total != nil {
            self.total = _total
        }else{
            self.total = ""
        }
        if _terms != nil {
            self.terms = _terms
        }else{
            self.terms = ""
        }
        if _daysAged != nil {
            self.daysAged = _daysAged
        }else{
            self.daysAged = ""
        }
        
    }
}



