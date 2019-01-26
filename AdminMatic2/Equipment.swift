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
    var crewName: String!
    var status: String!
    //var statusName: String!
    var type: String!
    var typeName: String!
    var fuelType: String!
    var fuelTypeName: String!
    var engineType: String!
    var engineTypeName: String!
    var mileage: String!
   // var pic: String!
    var dealer: String!
    var dealerName: String!
    var purchaseDate: String!
    var description: String!
    
    var image:Image!

    required init(_ID:String?, _name: String?,_make:String?,  _model:String?,  _serial:String?, _crew:String?, _crewName:String?, _status:String?, _type:String?, _typeName:String?, _fuelType:String?, _fuelTypeName:String?, _engineType:String?, _engineTypeName:String?, _mileage:String?,  _dealer:String?, _dealerName:String?, _purchaseDate:String?, _description:String?) {
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
        if _crewName != nil {
            self.crewName = _crewName
        }else{
            self.crewName = ""
        }
        if _status != nil {
            self.status = _status
        }else{
            self.status = ""
        }
        if _type != nil {
            self.type = _type
        }else{
            self.type = ""
        }
        if _typeName != nil {
            self.typeName = _typeName
        }else{
            self.typeName = ""
        }
        if _fuelType != nil {
            self.fuelType = _fuelType
        }else{
            self.fuelType = ""
        }
        if _fuelTypeName != nil {
            self.fuelTypeName = _fuelTypeName
        }else{
            self.fuelTypeName = ""
        }
        if _engineType != nil {
            self.engineType = _engineType
        }else{
            self.engineType = ""
        }
        if _engineTypeName != nil {
            self.engineTypeName = _engineTypeName
        }else{
            self.engineTypeName = ""
        }
        if _mileage != nil {
            self.mileage = _mileage
        }else{
            self.mileage = ""
        }
        
        if _dealer != nil {
            self.dealer = _dealer
        }else{
            self.dealer = ""
        }
        if _dealerName != nil {
            self.dealerName = _dealerName
        }else{
            self.dealerName = ""
        }
        if _purchaseDate != nil {
            self.purchaseDate = _purchaseDate
        }else{
            self.purchaseDate = ""
        }
        
        if _description != nil {
            self.description = _description
        }else{
            self.description = ""
        }
        
    }
}


