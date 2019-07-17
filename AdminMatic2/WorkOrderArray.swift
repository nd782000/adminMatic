//
//  WorkOrderArray.swift
//  AdminMatic2
//
//  Created by Nick on 7/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation


class WorkOrderArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case workOrders
        
    }
    
    var workOrders: [WorkOrder2]
    
    
    
    init(_workOrders:[WorkOrder2]) {
        self.workOrders = _workOrders
    }
    
}
