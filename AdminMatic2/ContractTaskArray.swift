//
//  ContractTaskArray.swift
//  AdminMatic2
//
//  Created by Nick on 7/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class ContractTaskArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case tasks
        
    }
    
    var tasks: [ContractTask2]
    
    
    
    init(_tasks:[ContractTask2]) {
        self.tasks = _tasks
    }
    
}
