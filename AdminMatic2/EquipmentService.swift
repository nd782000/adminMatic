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
    var frequency: String!
    var instruction: String!
    var completionDate: String!
    var completionMileage: String!
    var completedBy: String!
    var notes: String!
    var status: String!
    
    
    required init(_ID:String?, _name: String?,_type:String?,  _frequency:String?,  _instruction:String?, _completionDate:String?, _completionMileage:String?, _completedBy:String?, _notes:String?, _status:String?) {
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
        if _frequency != nil {
            self.frequency = _frequency
        }else{
            self.frequency = ""
        }
        if _instruction != nil {
            self.instruction = _instruction
        }else{
            self.instruction = ""
        }
        if _completionDate != nil {
            self.completionDate = _completionDate
        }else{
            self.completionDate = ""
        }
        if _completionMileage != nil {
            self.completionMileage = _completionMileage
        }else{
            self.completionMileage = ""
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
        
    }
}



