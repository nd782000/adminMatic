//
//  WorkOrder2.swift
//  AdminMatic2
//
//  Created by Nick on 5/30/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class WorkOrder2: Codable {
    
    
    enum CodingKeys : String, CodingKey {
        case ID = "woID"
        case status
        case date
        //case statusName
        case customer
        case custName
        case custAddress
        case type
        case progress
        case title
        case totalPrice
        case totalCost
        case totalPriceRaw
        case totalCostRaw
        case profitValue = "profitAmount"
        case percentValue = "profit"
        case charge
        case chargeName
        case rep = "salesRep"
        case repName = "salesRepName"
        case notes
        
        case woItems = "items"
        case crews
        
        case itemRemQty = "remQty"
        
    }
    
    var ID: String
    var title:String
    var status: String
    
    var type: String
    var progress:String
    var totalPrice:String
    var totalCost:String
    var totalPriceRaw:String
    var totalCostRaw:String
    var profitValue:String
    var percentValue:String
    
    
    
    
    //optional vars
    var statusName: String?
    //var customer: Customer2?
    var customer: String?
    var custName: String?
    var custAddress: String?
    var date: String?
    var rep:String?
    var repName:String?
    var notes:String?
    var charge:String?
    var chargeName:String?
    var invoiceType:String?
    var scheduleType:String?
    var department:String?
    var crew:String?
    var crewName:String?
    var plowDepth:String?
    var plowPriority:String?
    var plowMonitoring:String?
    
    var woItems:[WoItem2]? = []
    var crews:[Crew2]? = []
    var emps:[Employee2]? = []
    
    
    var lead:Lead2?
    var contract:Contract?
    
    var titleAndID:String = ""
    var IDAndTitle:String = ""
    var customerTitleAndID:String = ""
    
    var itemRemQty:String?
    
    
    init(_ID:String, _title:String, _status: String, _type:String, _progress:String, _totalPrice:String, _totalCost:String, _totalPriceRaw:String, _totalCostRaw:String,_profitValue:String, _percentValue:String) {
    
        
        
        //print(json)
        self.ID = _ID
        self.title = _title
        self.status = _status
       
        self.type = _type
        self.progress = _progress
        self.totalPrice = _totalPrice
        self.totalCost = _totalCost
        self.totalPriceRaw = _totalPriceRaw
        self.totalCostRaw = _totalCostRaw
        self.profitValue = _profitValue
        self.percentValue = _percentValue
        
        
                self.titleAndID = "\(String(describing: self.title)) #\(self.ID)"
                self.IDAndTitle = "\(self.ID) #\(String(describing: self.title))"
                if customer != nil {
                    self.customerTitleAndID = "\(String(describing: self.custName)) \(self.titleAndID)"
                }
        
    }
    
    func setEmps(){
        print("setEmps")
        if self.crews != nil{
            for crew in self.crews!{
                print("crew")
                for emp in crew.emps{
                    print("emp")
                self.emps!.append(emp)
                }
            }
        }else{
            print("crews not set")
        }
        
    }

}
