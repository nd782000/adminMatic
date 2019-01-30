//
//  ItemViewController.swift
//  AdminMatic2
//
//  Created by Nick on 12/5/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import MapKit
import CoreLocation

 

class ItemViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    
    
    var item:Item!
    var itemJSON: JSON!
    var itemVendorArray:[Vendor] = []
    
    
    var itemWorkOrderArray:[WorkOrder] = []
    //extra item properties, item object doesn't have'
   
    //item info
    var itemView:UIView!
    var itemLbl:GreyLabel!
    var priceUnitLbl:GreyLabel!
    var descriptionLbl:GreyLabel!
    var typeLbl:GreyLabel!
    var taxLbl:GreyLabel!
    
   
    //details view
    var detailsView:UIView!
    
    let controlItems = ["Locate","Vendors","Work Orders"]
    var segmentedControl:SegmentedControl!
    
    var locateView:MKMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var foundLocation:Bool = false

    
    
    var tableViewMode:String = "VENDOR"
    var vendorTableView:TableView!
    var workOrderTableView:TableView!
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    
    
    
    
    init(_item:Item){
        super.init(nibName:nil,bundle:nil)
        self.item = _item
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Item"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(ItemViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        getItemData(_id: self.item.ID!)
        
        
    }
    
    
    func getItemData(_id:String){
        
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        //self.tasksArray = []
        let parameters:[String:String]
        parameters = ["itemID": self.item.ID as AnyObject] as! [String : String]
        print("parameters = \(parameters)")
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/item.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("lead response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    
                    /*
                    
                    //native way
                    
                    do {
                        if let data = response.data,
                            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let item = json["item"] as? [[String: Any]] {
                            
                            //let itemCount = item.count
                            //print("item count = \(itemCount)")
                            
                            
                            
                            self.item.description = item[0]["description"] as? String
                            self.item.taxable = item[0]["tax"] as? String
                            self.item.typeID = item[0]["type"] as? String
                            self.item.totalRemainingQty = item[0]["remQty"] as? String
                            
                            let vendorCount = Int((item[0]["vendors"].count))
                            print("vendorCount: \(vendorCount)")
                            for i in 0 ..< vendorCount {
                                let vendor = Vendor(_name: item["vendors"][i]["name"] as? String, _id: item["vendors"][i]["vendorID"] as? String, _address: item["vendors"][i]["adname"] as? String, _phone: item["vendors"][i]["phone"] as? String, _website: item["vendors"][i]["website"] as? String, _balance: item["vendors"][i]["balance"] as? String, _lng: item["vendors"][i]["address"][0]["lng"] as? String, _lat: item["vendors"][i]["address"][0]["lat"] as? String)
                                vendor.itemCost = item["vendors"][i]["cost"] as? String
                                vendor.itemPreffered = item["vendors"][i]["preffered"] as? String
                                itemVendorArray.append(vendor)
                            }
                            
                            let workOrderCount = Int((item["workOrders"].count))
                            print("workOrderCount: \(workOrderCount)")
                            for n in 0 ..< workOrderCount {
                                let workOrder = WorkOrder(_ID: item["workOrders"][n]["ID"] as? String, _statusID: item["workOrders"][n]["status"] as? String, _date: "", _firstItem: item["workOrders"][n]["title"] as? String, _statusName: "", _customer: item["workOrders"][n]["custName"] as? String, _type: "", _progress: "", _totalPrice: "", _totalCost: "", _totalPriceRaw: "", _totalCostRaw: "", _charge: "", _title: item["workOrders"][n]["title"] as? String, _customerName: item["workOrders"][n]["customerName"] as? String)
                                workOrder.itemRemQty = item["workOrders"][n]["remQty"] as? String
                                itemWorkOrderArray.append(workOrder)
                            }
                            
                            
                            
                            
                            
                            
                            
                           
                        }
                        
                        

                        
                        self.indicator.dismissIndicator()
                        
                        
                        self.layoutViews()
                        
                        
                        
                        
                        
                    } catch {
                        print("Error deserializing JSON: \(error)")
                    }
                    
                    */
                    
                    
                    
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    
                    
                    print("JSON: \(json)")
                    self.itemJSON = JSON(json)
                    self.parseItemJSON()
                    
                    
                    
                }
                
        }
        
        
       
    }
    
    
    
    func parseItemJSON(){
        
        //itemLbl.text = self.itemJSON["item"]["item"].stringValue
       // priceUnitLbl.text = self.itemJSON["item"]["price"].stringValue  self.itemJSON["item"]["unit"].stringValue
        
        item.description = self.itemJSON["item"]["description"].stringValue
        item.taxable = self.itemJSON["item"]["tax"].stringValue
        item.typeID = self.itemJSON["item"]["type"].stringValue
        item.totalRemainingQty = self.itemJSON["item"]["remQty"].stringValue
        
        let vendorCount = Int((self.itemJSON["item"]["vendors"].count))
        print("vendorCount: \(vendorCount)")
        for i in 0 ..< vendorCount {
            let vendor = Vendor(_name: self.itemJSON["item"]["vendors"][i]["name"].stringValue, _id: self.itemJSON["item"]["vendors"][i]["vendorID"].stringValue, _address: self.itemJSON["item"]["vendors"][i]["adname"].stringValue, _phone: self.itemJSON["item"]["vendors"][i]["phone"].stringValue, _website: self.itemJSON["item"]["vendors"][i]["website"].stringValue, _balance: self.itemJSON["item"]["vendors"][i]["balance"].stringValue, _lng: self.itemJSON["item"]["vendors"][i]["address"][0]["lng"].stringValue, _lat: self.itemJSON["item"]["vendors"][i]["address"][0]["lat"].stringValue)
            vendor.itemCost = self.itemJSON["item"]["vendors"][i]["cost"].stringValue
            vendor.itemPreffered = self.itemJSON["item"]["vendors"][i]["preffered"].stringValue
            itemVendorArray.append(vendor)
        }
        
        let workOrderCount = Int((self.itemJSON["item"]["workOrders"].count))
        print("workOrderCount: \(workOrderCount)")
        for n in 0 ..< workOrderCount {
            let workOrder = WorkOrder(_ID: self.itemJSON["item"]["workOrders"][n]["ID"].stringValue, _statusID: self.itemJSON["item"]["workOrders"][n]["status"].stringValue, _date: "", _firstItem: self.itemJSON["item"]["workOrders"][n]["title"].stringValue, _statusName: "", _customer: self.itemJSON["item"]["workOrders"][n]["custName"].stringValue, _type: "", _progress: "", _totalPrice: "", _totalCost: "", _totalPriceRaw: "", _totalCostRaw: "", _charge: "", _title: self.itemJSON["item"]["workOrders"][n]["title"].stringValue, _customerName: self.itemJSON["item"]["workOrders"][n]["customerName"].stringValue)
           workOrder.itemRemQty = self.itemJSON["item"]["workOrders"][n]["remQty"].stringValue
            itemWorkOrderArray.append(workOrder)
        }
        
        
        
        
       
        
        layoutViews()
    }
    
    
    
    
    
    
    
    
    
    func layoutViews(){
        print("item view layoutViews")
        //////////   containers for different sections
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.itemView = UIView()
        //self.itemView.layer.borderColor = layoutVars.borderColor
        //self.itemView.layer.borderWidth = 1.0
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.itemView)
        
        
        
        
        
        self.detailsView = UIView()
        self.detailsView.backgroundColor = layoutVars.backgroundColor
        
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.detailsView)
        
        
        
        print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemView,
            "view2":self.detailsView] as [String : Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": 24,"fullHeight":layoutVars.fullHeight - 270] as [String : Any]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view1(120)]-[view2]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        ///////////   item contact section   /////////////
        
        print("item view layoutViews 2")
        //name
        self.itemLbl = GreyLabel()
        self.itemLbl.text = self.item.name
        self.itemLbl.font = layoutVars.largeFont
        self.itemLbl.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.itemLbl)
        
        //price / unit
        self.priceUnitLbl = GreyLabel()
        self.priceUnitLbl.text = "$\(self.item.price!)/\(self.item.units!)"
        self.priceUnitLbl.font = layoutVars.smallBoldFont
        self.priceUnitLbl.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.priceUnitLbl)
        
        //description
        self.descriptionLbl = GreyLabel()
        if(item.description == ""){
            self.descriptionLbl.text = "No description provided"
        }else{
            self.descriptionLbl.text = item.description
        }
        
        self.descriptionLbl.font = layoutVars.buttonFont
        self.descriptionLbl.adjustsFontSizeToFitWidth = true
        
        self.descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.descriptionLbl)
        
        //type
        self.typeLbl = GreyLabel()
        //if(item.typeID == "1"){
            self.typeLbl.text = item.type
        //}else{
            //self.typeLbl.text = "Material Type"
        //}
        self.typeLbl.font = layoutVars.smallFont
        self.typeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.typeLbl)
        
        //tax
        self.taxLbl = GreyLabel()
        if(item.taxable == "1"){
            self.taxLbl.text = "Taxable"
        }else{
            self.taxLbl.text = "Non Taxable"
        }
        self.taxLbl.font = layoutVars.smallFont
        self.taxLbl.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.addSubview(self.taxLbl)
       
        
        let itemsViewsDictionary = [
            "itemLbl":self.itemLbl,
            "priceUnitLbl":self.priceUnitLbl,
            "descriptionLbl":self.descriptionLbl,
            "typeLbl":self.typeLbl,
            "taxLbl":self.taxLbl
        ] as [String:Any]
       
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[itemLbl]-[priceUnitLbl(120)]-|", options: [], metrics: sizeVals, views: itemsViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLbl]-|", options: [], metrics: sizeVals, views: itemsViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[typeLbl]-[taxLbl(120)]-|", options: [], metrics: sizeVals, views: itemsViewsDictionary))
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[itemLbl(40)][descriptionLbl(56)][typeLbl(20)]", options: [], metrics: sizeVals, views: itemsViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[priceUnitLbl(40)][descriptionLbl(56)][taxLbl(20)]", options: [], metrics: sizeVals, views: itemsViewsDictionary))
        
        
        
        ///////////   Item Details Section   /////////////
        
            //material type
            segmentedControl = SegmentedControl(items: controlItems)
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: #selector(self.switchViews(sender:)), for: .valueChanged)
            self.detailsView.addSubview(segmentedControl)
            
            
            //map
            locateView = MKMapView()
            locateView.translatesAutoresizingMaskIntoConstraints = false
            self.detailsView.addSubview(locateView)
            
           
            
            //showMapLocations()
            
            if(item.typeID != "1" && itemVendorArray.count != 0){
                
                for vendor in itemVendorArray {
                    if(vendor.lat != ""){
                    
                    
                    
                        locateView.setCenter(CLLocationCoordinate2D(latitude: Double(vendor.lat)!,longitude:
                            Double(vendor.lng)!), animated: true)
                    
                    
                    
                        let location = CLLocationCoordinate2D(
                            latitude: Double(vendor.lat)!,
                            longitude: Double(vendor.lng)!
                        )
                    
                        let span = MKCoordinateSpan.init(latitudeDelta: 0.5, longitudeDelta: 0.5)
                        let region = MKCoordinateRegion(center: location, span: span)
                    
                        locateView.setRegion(region, animated: true)
                    
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location
                        annotation.title = "$\(String(describing: vendor.itemCost!))/\(self.item.units!)"
                        annotation.subtitle = vendor.name
                    
                        locateView.addAnnotation(annotation)
                        
                    
                    }
                }
                
                locateView.showsUserLocation = true
                locateView.showAnnotations(locateView.annotations, animated: true)
                
                var zoomRect:MKMapRect = MKMapRect.null
                for  annotation in locateView.annotations {
                    let annotationPoint:MKMapPoint = MKMapPoint.init(annotation.coordinate)
                    let pointRect:MKMapRect = MKMapRect.init(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0);
                    if (zoomRect.isNull) {
                        zoomRect = pointRect;
                    } else {
                        zoomRect = zoomRect.union(pointRect);
                    }
                }
                
                
                
                
                
                
                
                if (CLLocationManager.locationServicesEnabled())
                {
                    print("location available")
                    locationManager = CLLocationManager()
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                }else{
                    print("location not available")
                    
                    locateView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets.init(top: 50, left: 50, bottom: 50, right: 50), animated: true)
                }
        }
        
        
            
            
            
            
            
            
            
            
            
        //vendor table
        tableViewMode = "VENDOR"
        vendorTableView = TableView()
        vendorTableView.delegate  =  self
        vendorTableView.dataSource = self
        vendorTableView.register(VendorTableViewCell.self, forCellReuseIdentifier: "vendorCell")
        vendorTableView.rowHeight = 50.0
        self.detailsView.addSubview(vendorTableView)
        
        vendorTableView.alpha = 0.0
            
        
        //work order table
        tableViewMode = "WORKORDER"
        workOrderTableView = TableView()
        workOrderTableView.delegate  =  self
        workOrderTableView.dataSource = self
        workOrderTableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: "workOrderCell")
        workOrderTableView.rowHeight = 50.0
        
        
        self.detailsView.addSubview(workOrderTableView)
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.detailsView.addSubview(self.countView)
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        self.countLbl.adjustsFontSizeToFitWidth = true
        self.countView.addSubview(self.countLbl)
        
        countLblText(_type: "WORKORDER")
        

        
        //auto layout group
        let itemDetailsViewsDictionary = [
            "segmentedControl":segmentedControl,
            "locateView":locateView,
            "vendorTableView":vendorTableView,
            "workOrderTableView":workOrderTableView,
            "countView":countView
        ] as [String : Any]
        
        
        //material type
            self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[segmentedControl]-|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
            self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[locateView]-|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
            self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[vendorTableView]-|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
            self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[workOrderTableView]-|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
            self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[countView]-|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))

        
            //material type
            self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[segmentedControl(35)]-[locateView]-|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
            self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[segmentedControl(35)]-[vendorTableView][countView(30)]-|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
            self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[segmentedControl(35)]-[workOrderTableView][countView(30)]-|", options: [], metrics: sizeVals, views: itemDetailsViewsDictionary))
        
            //labor type
        
       // print("item.typeID = \(item.typeID)")
        if(item.typeID == "1"){
            segmentedControl.isEnabled = false
            segmentedControl.selectedSegmentIndex = 2
            locateView.alpha = 0.0
            vendorTableView.alpha = 0.0
            workOrderTableView.alpha = 1.0
            countView.alpha = 1.0
        }else{
            if(itemVendorArray.count == 0){
                print("no vendors")
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Vendors", _message: "We do not have any registered vendors in our system.")
                segmentedControl.isEnabled = false
                segmentedControl.selectedSegmentIndex = 2
                locateView.alpha = 0.0
                vendorTableView.alpha = 0.0
                workOrderTableView.alpha = 1.0
                countView.alpha = 1.0
            }else{
                locateView.alpha = 1.0
                vendorTableView.alpha = 0.0
                workOrderTableView.alpha = 0.0
                countView.alpha = 0.0
            }
            
            
        }
        
        let viewsDictionary2 = [
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
        
    }
    
  
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("monitoring")
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        print("didUpdateLocations \(foundLocation)")
        if(foundLocation == false){
            var zoomRect:MKMapRect = MKMapRect.null
            for  annotation in locateView.annotations {
                let annotationPoint:MKMapPoint = MKMapPoint.init(annotation.coordinate)
                let pointRect:MKMapRect = MKMapRect.init(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0);
                if zoomRect.isNull {
                    zoomRect = pointRect;
                } else {
                    zoomRect = zoomRect.union(pointRect);
                }
            }
            
            locateView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets.init(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            foundLocation = true
        }
    }
    
    
    
    @objc func switchViews(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("locate view")
            locateView.alpha = 1.0
            vendorTableView.alpha = 0.0
            workOrderTableView.alpha = 0.0
            tableViewMode = ""
            self.countLbl.text = ""
            countView.alpha = 0.0
            break
        case 1:
            print("vendor view")
            locateView.alpha = 0.0
            vendorTableView.alpha = 1.0
            workOrderTableView.alpha = 0.0
            tableViewMode = "VENDOR"
            vendorTableView.reloadData()
            countLblText(_type: "VENDOR")
            countView.alpha = 1.0
            break
        case 2:
            print("work order view")
            locateView.alpha = 0.0
            vendorTableView.alpha = 0.0
            workOrderTableView.alpha = 1.0
            tableViewMode = "WORKORDER"
            workOrderTableView.reloadData()
            countLblText(_type: "WORKORDER")
            countView.alpha = 1.0
            break
        default:
            break
        }
    }
    
    
    func countLblText(_type:String){
        if(_type == "WORKORDER"){
            if(self.itemWorkOrderArray.count == 0){
                self.countLbl.text = "No workorders found with \(item.name!)"
            }else{
                var workOrderString:String
                var remainingQty:String
                if(self.itemWorkOrderArray.count > 1){
                    workOrderString = "Work Orders"
                }else{
                    workOrderString = "Work Order"
                }
                if(Float(self.item.totalRemainingQty!)! == 0){
                    remainingQty = "0 \(self.item.units!)s"
                }else if (Float(self.item.totalRemainingQty!)! > 1){
                    remainingQty = "\(self.item.totalRemainingQty!) \(self.item.units!)s"
                }else{
                    remainingQty = "\(self.item.totalRemainingQty!) \(self.item.units!)"
                }
                
                
                self.countLbl.text = "\(self.itemWorkOrderArray.count) \(workOrderString) with  \(remainingQty) Remaining"
            }
        }else{
            
            if(self.itemVendorArray.count == 0){
                self.countLbl.text = "No Vendors Found with \(item.name!)"
            }else{
                var vendorString:String
                
                if(self.itemVendorArray.count > 1){
                    vendorString = "Vendors"
                }else{
                    vendorString = "Vendor"
                }
                
                self.countLbl.text = "\(self.itemVendorArray.count) \(vendorString) Found with \(item.name!)"
            }
            
        }
        
    }
    
    
    
    
    
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print("numberOfRowsInSection")
        print("numberOfRowsInSection \(self.tableViewMode)")
        
        var count:Int!
        switch self.tableViewMode{
        case "VENDOR":
            count = self.itemVendorArray.count
            break
        case "WORKORDER":
            count = self.itemWorkOrderArray.count
            break
        default:
            count = self.itemVendorArray.count
            
        }
        
        return count
        
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cellForRowAt \(self.tableViewMode)")
        switch self.tableViewMode{
        case "VENDOR":
            let cell = vendorTableView.dequeueReusableCell(withIdentifier: "vendorCell") as! VendorTableViewCell
            cell.id = itemVendorArray[indexPath.row].ID
           // print("vendor name = \(itemVendorArray[indexPath.row].name)")
            cell.name = itemVendorArray[indexPath.row].name
            cell.nameLbl.text = itemVendorArray[indexPath.row].name
            cell.itemCostLbl.text = "$\(itemVendorArray[indexPath.row].itemCost!)/\(self.item.units!)"
            if(itemVendorArray[indexPath.row].itemPreffered == "1"){
                cell.setPreffered()
            }
            
            return cell
            
        case "WORKORDER":
            let cell = workOrderTableView.dequeueReusableCell(withIdentifier: "workOrderCell") as! ScheduleTableViewCell
            
            cell.workOrder = self.itemWorkOrderArray[indexPath.row]
            cell.layoutViews(_scheduleMode: "ITEM")
            cell.setStatus(status: self.itemWorkOrderArray[indexPath.row].statusId)
            cell.customerLbl.text = "\(self.itemWorkOrderArray[indexPath.row].title!)  \(self.itemWorkOrderArray[indexPath.row].customer!)"
            cell.remainingQtyLbl.text = "Remaining Qty.: \(String(describing: self.itemWorkOrderArray[indexPath.row].itemRemQty!)) \(self.item.units!)"
            
            return cell
            
        default:
            let cell = vendorTableView.dequeueReusableCell(withIdentifier: "vendorCell") as! VendorTableViewCell
            cell.prepareForReuse()
            
            return cell
            
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow;
        
        
        switch self.tableViewMode{
        case "VENDOR":
            
            let currentCell = tableView.cellForRow(at: indexPath!) as! VendorTableViewCell;
            let vendorViewController = VendorViewController(_vendorID: currentCell.id)
            navigationController?.pushViewController(vendorViewController, animated: false )
            
        case "WORKORDER":
            let currentCell = tableView.cellForRow(at: indexPath!) as! ScheduleTableViewCell;
            let workOrderViewController = WorkOrderViewController(_workOrderID: currentCell.workOrder.ID)
            navigationController?.pushViewController(workOrderViewController, animated: false )
            
            //workOrderViewController.scheduleDelegate = self
            //workOrderViewController.scheduleIndex = indexPath?.row
            
        default:
            let currentCell = tableView.cellForRow(at: indexPath!) as! VendorTableViewCell;
            let vendorViewController = VendorViewController(_vendorID: currentCell.id)
            navigationController?.pushViewController(vendorViewController, animated: false )
            
        }
        
        
        
        
        tableView.deselectRow(at: indexPath!, animated: true)
        
    }
    
    
    
    
     
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
