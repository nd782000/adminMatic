//
//  Bug.swift
//  AdminMatic2
//
//  Created by Nick on 3/27/17.
//  Copyright © 2017 Nick. All rights reserved.
//

 
import Foundation

class Bug {
    
    var ID: String
    var title: String
    var description: String
    var status: String
    var createdBy: String
    var created: String
    
    
    required init(_title:String, _id: String, _description:String, _status:String, _createdBy:String, _created:String) {
        self.ID = _id
        self.title = _title
        self.description = _description
        self.status = _status
        self.created = _created
        self.createdBy = _createdBy
    }
}
