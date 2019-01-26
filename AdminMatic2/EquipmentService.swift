//
//  EquipmentService.swift
//  AdminMatic2
//
//  Created by Nick on 12/15/17.
//  Copyright © 2017 Nick. All rights reserved.
//
 
import Foundation

class EquipmentService {
    
    var ID: String!
    var name: String! //Oil Change, Coolant Flush, Etc.
    var type: String! //Repeat or One Time
    var typeName: String!
    var frequency: String!
    var instruction: String!
    var creationDate: String!
    var createdBy: String!
    var completionDate: String!
    var completionMileage: String!
    var completedBy: String!
    var notes: String!
    var status: String!
    
    var equipmentID: String!
    var currentValue: String! //Current Mileage or Engine Hours
    var nextValue: String! //Mileage or Engine Hours for Next Service
    
    var serviceDue:Bool = false
    
    
    required init(_ID:String?, _name: String?,_type:String?,_typeName:String?,  _frequency:String?,  _instruction:String?, _creationDate:String?, _createdBy:String?, _completionDate:String?, _completionMileage:String?, _completedBy:String?, _notes:String?, _status:String?, _currentValue:String?, _nextValue:String?, _equipmentID:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = "0"
        }
        if _typeName != nil {
            self.typeName = _typeName
        }else{
            self.typeName = ""
        }
        
        if _frequency != nil {
            self.frequency = _frequency
        }else{
            self.frequency = "0"
        }
        if _instruction != nil {
            self.instruction = _instruction
        }else{
            self.instruction = ""
        }
        if _creationDate != nil {
            self.creationDate = _creationDate
        }else{
            self.creationDate = ""
        }
        if _createdBy != nil {
            self.createdBy = _createdBy
        }else{
            self.createdBy = ""
        }
        if _completionDate != nil {
            self.completionDate = _completionDate
        }else{
            self.completionDate = ""
        }
        if _completionMileage != nil {
            self.completionMileage = _completionMileage
        }else{
            self.completionMileage = "0"
        }
        if _completedBy != nil {
            self.completedBy = _completedBy
        }else{
            self.completedBy = ""
        }
        if _notes != nil {
            self.notes = _notes
        }else{
            self.notes = ""
        }
        
        if _status != nil {
            self.status = _status
        }else{
            self.status = ""
        }
        if _currentValue != nil {
            self.currentValue = _currentValue
        }else{
            self.currentValue = "0"
        }
        if _nextValue != nil {
            self.nextValue = _nextValue
        }else{
            self.nextValue = "0"
        }
        if _equipmentID != nil {
            self.equipmentID = _equipmentID
        }else{
            self.equipmentID = ""
        }
        
    }
}



