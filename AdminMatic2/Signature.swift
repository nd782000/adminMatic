//
//  Signature.swift
//  AdminMatic2
//
//  Created by Nick on 8/13/18.
//  Copyright © 2018 Nick. All rights reserved.
//


import Foundation

class Signature {
    //var ID: String!
    var contractId: String!
    var type: String! //1 = customer, 2 = company
    var path: String!
    
    
    
    required init(_contractID: String?,_type:String?, _path:String?) {
        //print(json)
        /*
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
 */
        
        if _contractID != nil {
            self.contractId = _contractID
        }else{
            self.contractId = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        if _path != nil {
            self.path = _path
        }else{
            self.path = ""
        }
        
        
    }
}
