//
//  LeadArray.swift
//  AdminMatic2
//
//  Created by Nick on 6/27/19.
//  Copyright © 2019 Nick. All rights reserved.
//

class LeadArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case leads
        
    }
    
    var leads: [Lead2]
    
    
    
    init(_leads:[Lead2]) {
        self.leads = _leads
    }
    
}

