//
//  Date.swift
//  AdminMatic2
//
//  Created by Nick on 1/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//
/*
import Foundation
import UIKit
import SwiftyJSON

class Date: NSDate {
    var dateRaw: NSDate!
    var dateShort: String!
    var dateString: String!
    
    init(_dateRaw:NSDate?) {
        //print(json)
        /*if _dateRaw != nil {
         self.dateRaw = _dateRaw
         }else{
         self.dateRaw = NSDate()
         }*/
        //super.init(nibName:nil,bundle:nil)
        
        let shortFormatter = DateFormatter()
        //shortFormatter.dateFormat = "hh:mm a"
        shortFormatter.dateFormat = "hh:mm a"
        
        let stringFormatter = DateFormatter()
        stringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        
        if _dateRaw != nil {
            self.dateRaw = _dateRaw!
            //self.dateShort = shortFormatter.string(from: (self.dateRaw as! Date) as Date)
            //self.dateShort = shortFormatter.string(from: self as Date)
            
            //self.dateString = stringFormatter.string(from: self as Date)
            //dateShort = shortFormatter.string(from: self.dateRaw)
            
            //dateShort = shortFormatter.string(from: self.dateRaw as Date)
           // dateShort =  shortFormatter.stringFromDate(((self.dateRaw! as Date) as! Date) as Date)
            //dateString =  stringFormatter.string(from: self.dateRaw as! Date)
            
            dateShort =  ""
            dateString =  ""
            
            
        }else{
            //self.dateRaw = NSDate()
            dateShort =  ""
            dateString =  ""
        }
        //super.init()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 */





