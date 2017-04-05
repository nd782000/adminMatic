//
//  FieldNote.swift
//  AdminMatic2
//
//  Created by Nick on 1/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class FieldNote {
    
    var ID: String!
    var note: String!
    var customerID: String!
    var workOrderID: String!
    var createdBy: String!
    var status: String!
    
    var images: [Image] = []
    
    
    
    init(_ID:String?,_note:String?,_customerID:String?, _workOrderID:String?, _createdBy:String?, _status:String?, _images:[Image]?) {
        //print(json)
        //print("_start = \(_start!.dateString)")
        //print("_start short = \(_start!.dateShort)")
        
        //print("_stop = \(_stop!.dateString)")
        //print("_stop short = \(_stop!.dateShort)")
        
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _note != nil {
            self.note = _note
        }else{
            self.note = ""
        }
        if _customerID != nil {
            self.customerID = _customerID
        }else{
            self.customerID = ""
        }
        if _workOrderID != nil {
            self.workOrderID = _workOrderID
        }else{
            self.workOrderID = ""
        }
        
        
        if _createdBy != nil {
            self.createdBy = _createdBy
        }else{
            self.createdBy = ""
        }
        if _status != nil {
            self.status = _status
        }else{
            self.status = ""
        }
        
        if(_images != nil){
            self.images = _images!
        }else{
            self.images = []
        }
        
    }
    
    
    
}




