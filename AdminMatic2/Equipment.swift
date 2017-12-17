//
//  Equipment.swift
//  AdminMatic2
//
//  Created by Nick on 12/12/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation

class Equipment {
    var ID: String!
    var name: String!
    var make: String!
    var model: String!
    var serial: String!
    var crew: String!
    var status: String!
    var statusName: String!
    var type: String!
    var fuelType: String!
    var engineType: String!
    var mileage: String!
    var pic: String!
    var dealer: String!
    var purchaseDate: String!

    required init(_ID:String?, _name: String?,_make:String?,  _model:String?,  _serial:String?, _crew:String?, _status:String?, _statusName:String?, _type:String?, _fuelType:String?, _engineType:String?, _mileage:String?, _pic:String?, _dealer:String?, _purchaseDate:String?) {
        //print(json)
        if _ID != nil {
            self.ID = _ID
        }else{
            self.ID = ""
        }
        if _name != nil {
            self.name = _name
        }else{
            self.name = ""
        }
        if _make != nil {
            self.make = _make
        }else{
            self.make = ""
        }
        if _model != nil {
            self.model = _model
        }else{
            self.model = ""
        }
        if _serial != nil {
            self.serial = _serial
        }else{
            self.serial = ""
        }
        if _crew != nil {
            self.crew = _crew
        }else{
            self.crew = ""
        }
        if _status != nil {
            self.status = _status
        }else{
            self.status = ""
        }
        if _statusName != nil {
            self.statusName = _statusName
        }else{
            self.statusName = ""
        }
        
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        if _fuelType != nil {
            self.fuelType = _fuelType
        }else{
            self.fuelType = ""
        }
        if _engineType != nil {
            self.engineType = _engineType
        }else{
            self.engineType = ""
        }
        if _mileage != nil {
            self.mileage = _mileage
        }else{
            self.mileage = ""
        }
        if _pic != nil {
            self.pic = _pic
        }else{
            self.pic = ""
        }
        if _dealer != nil {
            self.dealer = _dealer
        }else{
            self.dealer = ""
        }
        if _purchaseDate != nil {
            self.purchaseDate = _purchaseDate
        }else{
            self.purchaseDate = ""
        }
    }
}


