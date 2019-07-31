//
//  ContractArray.swift
//  AdminMatic2
//
//  Created by Nick on 7/8/19.
//  Copyright © 2019 Nick. All rights reserved.
//


class ContractArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case contracts
        
    }
    
    var contracts: [Contract2]
    
    
    
    init(_contracts:[Contract2]) {
        self.contracts = _contracts
    }
    
}

