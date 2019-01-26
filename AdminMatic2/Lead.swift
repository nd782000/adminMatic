//
//  Lead.swift
//  AdminMatic2
//
//  Created by Nick on 11/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

 
import Foundation

class Lead {
    var ID: String!
    var statusId: String!
    var scheduleType: String! //0 = ASAP, 1 = FIRM
    var date: String!// send as YYYY-MM-DD
    var time: String!// send as HH:MM 24 hr time
    var statusName: String!
    var customer: String!
    var customerName: String!
    var urgent: String!
    var description: String!
    var rep: String!
    var repName: String!
    var deadline: String!
    var requestedByCust: String!
    var createdBy: String!
    var daysAged: String!
    
    var dateNice:String?
   // var dateRaw:String?
    
    var custNameAndID:String!
    
    var zone:Zone!
    
    var custNameAndZone:String!
    
    var tasksArray:[Task] = []
    
    
    required init(_ID:String?, _statusID: String?,_scheduleType:String?,  _date:String?,  _time:String?, _statusName:String?, _customer:String?, _customerName:String?, _urgent:String?, _description:String?, _rep:String?, _repName:String?, _deadline:String?, _requestedByCust:String?, _createdBy:String?, _daysAged:String?) {
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
        if _scheduleType != nil {
            self.scheduleType = _scheduleType
        }else{
            self.scheduleType = ""
        }
        if _date != nil {
            self.date = _date
        }else{
            self.date = ""
        }
        if _time != nil {
            self.time = _time
        }else{
            self.time = ""
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
        if _customerName != nil {
            self.customerName = _customerName
        }else{
            self.customerName = ""
        }
        if _urgent != nil {
            self.urgent = _urgent
        }else{
            self.urgent = "0"
        }
        if _description != nil {
            self.description = _description
        }else{
            self.description = ""
        }
        if _rep != nil {
            self.rep = _rep
        }else{
            self.rep = ""
        }
        if _repName != nil {
            self.repName = _repName
        }else{
            self.repName = ""
        }
        if _deadline != nil {
            self.deadline = _deadline
        }else{
            self.deadline = ""
        }
        if _requestedByCust != nil {
            self.requestedByCust = _requestedByCust
        }else{
            self.requestedByCust = "0"
        }
        if _createdBy != nil {
            self.createdBy = _createdBy
        }else{
            self.createdBy = ""
        }
        if _daysAged != nil {
            self.daysAged = _daysAged
        }else{
            self.daysAged = ""
        }
        
    }
}

