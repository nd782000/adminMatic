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
        
        case contractTasks
        
    }
    
    var contractTasks: [ContractTask2]
    
    
    
    init(_contractTasks:[ContractTask2]) {
        self.contractTasks = _contractTasks
    }
    
}
