//
//  ItemArray.swift
//  AdminMatic2
//
//  Created by Nick on 7/24/19.
//  Copyright © 2019 Nick. All rights reserved.
//

class ItemArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case items
        
    }
    
    var items: [Item2]
    
    
    
    init(_items:[Item2]) {
        self.items = _items
    }
    
}
