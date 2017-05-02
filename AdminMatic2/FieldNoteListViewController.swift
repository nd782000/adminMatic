//
//  FieldNoteListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/11/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol FieldNoteDelegate{
    func updateTable(_points:Int)
    
}




class FieldNoteListViewController: ViewControllerWithMenu, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, FieldNoteDelegate{
//class FieldNoteListViewController: UIViewController{
    
    var layoutVars:LayoutVars = LayoutVars()
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var woDelegate:WoDelegate!
    
    //vavarndicator: SDevIndicator!
    
    var containerView:UIView!
    
    var workOrderID:String!
    var customerID:String!
    var woItemID:String!
    
    
    var json:JSON!
    
    var addFieldNoteBtn: Button!
    var fieldNoteTableView: TableView!
    var fieldNotesJson:JSON?

    
    var fieldNotes: [FieldNote] = []//data array
    
    // var fieldNoteViewEntered:Int = 0
    
    var editsMade:Bool = false
    
    
    init(_workOrderID:String,_customerID:String,_fieldNotes:[FieldNote]){
        super.init(nibName:nil,bundle:nil)
        self.workOrderID = _workOrderID
        self.customerID = _customerID
        self.fieldNotes = _fieldNotes
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Field Notes"
        
        
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(FieldNoteListViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        
        //container view for auto layout
        self.containerView = UIView()
        self.containerView.backgroundColor = layoutVars.backgroundColor
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.containerView)
        
        
        
        self.addFieldNoteBtn = Button(titleText: "Add")
        
        self.addFieldNoteBtn.titleLabel?.textAlignment = NSTextAlignment.center
        self.addFieldNoteBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.addFieldNoteBtn.addTarget(self, action: #selector(FieldNoteListViewController.addFieldNote), for: UIControlEvents.touchUpInside)
        self.containerView.addSubview(self.addFieldNoteBtn)
        
        //employee table
        self.fieldNoteTableView =  TableView()
        self.fieldNoteTableView.delegate  =  self
        self.fieldNoteTableView.dataSource  =  self
        self.fieldNoteTableView.rowHeight = 60.0
        
        self.fieldNoteTableView.register(FieldNoteTableViewCell.self, forCellReuseIdentifier: "cell")
        self.containerView.addSubview(self.fieldNoteTableView)
        
        //auto layout group
        let viewsDictionary = [
            "container":self.containerView,
            "addBtn":self.addFieldNoteBtn,
            "table":self.fieldNoteTableView
        ]as [String : Any]
        // ////print("2")
        let metricsDictionary = ["screenWidth": self.view.frame.size.width,"screenHeight": self.view.frame.size.height,"fullWidth": self.view.frame.size.width - 20,"halfWidth": (self.view.frame.size.width - 20)/2,"inputHeight":layoutVars.inputHeight,"doubleInputHeight":layoutVars.inputHeight*2] as [String : Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container(screenWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container(screenHeight)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        //////print("3")
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[addBtn(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[table(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[addBtn(inputHeight)]-[table]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
    }
    
    func updateTable(_points:Int){
        print("updateTable")
        self.appDelegate.showMessage(_message: "earned \(_points) App Points!")
        
        self.editsMade = true
        getFieldNotes()
    }
    
    func getFieldNotes(){
        print("get field notes")
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        let parameters = ["woID": self.workOrderID as AnyObject, "cb":timeStamp as AnyObject]
        
        print("parameters = \(parameters)")
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/fieldNotes.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("get field notes response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                print(response.request ?? "")  // original URL request
                print(response.response ?? "") // URL response
                print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                if let json = response.result.value {
                    print("Field Note Json = \(json)")
                    self.fieldNotesJson = JSON(json)
                    
                    let fn = self.fieldNotesJson?["fieldNotes"]
                    
                    self.fieldNotes = []
                    
                    //FieldNotes
                    print("Field Note Count = \(fn?.count)")
                    
                    for n in 0 ..< Int((fn?.count)!) {
                        
                        
                        var fieldNoteImages:[Image]  = []
                        
                        
                        let imageCount = Int((fn?[n]["images"].count)!)
                        print("imageCount: \(imageCount)")
                        
                        
                        
                        
                        for i in 0 ..< imageCount {
                            
                            let fileName:String = (fn?[n]["images"][i]["fileName"].stringValue)!
                            
                            let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                            let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                            
                            //create a item object
                            print("create an image object \(i)")
                            
                            print("rawPath = \(rawPath)")
                            
                            let image = Image(_id: fn?[n]["images"][i]["ID"].stringValue,_thumbPath: thumbPath,_rawPath: rawPath,_name: fn?[n]["images"][i]["name"].stringValue,_width: fn?[n]["images"][i]["width"].stringValue,_height: fn?[n]["images"][i]["height"].stringValue,_description: fn?[n]["images"][i]["description"].stringValue,_dateAdded: fn?[n]["images"][i]["dateAdded"].stringValue,_createdBy: fn?[n]["images"][i]["createdByName"].stringValue,_type: fn?[n]["images"][i]["type"].stringValue)
                            
                            image.customer = (fn?[n]["images"][i]["customer"].stringValue)!
                            image.tags = (fn?[n]["images"][i]["tags"].stringValue)!
                            
                            fieldNoteImages.append(image)
                            
                        }
                        
                        let fieldNote = FieldNote(_ID: fn?[n]["ID"].stringValue, _note: fn?[n]["note"].stringValue, _customerID: fn?[n]["customerID"].stringValue, _workOrderID: fn?[n]["workOrderID"].stringValue, _createdBy: fn?[n]["createdBy"].stringValue, _status: fn?[n]["status"].stringValue, _images:fieldNoteImages)
                        
                        
                        self.fieldNotes.append(fieldNote)
                        
                    }
                    
                    // let scoreJSON =  JSON(json)["scoreAdjust"]
                    
                    /*
                    //add appPoints
                    var points:Int = JSON(json)["scoreAdjust"].intValue
                    //print("points = \(points)")
                    if(points > 0){
                        self.appDelegate.showMessage(_message: "earned \(points) App Points!")
                    }else if(points < 0){
                        points = points * -1
                        self.appDelegate.showMessage(_message: "lost \(points) App Points!")
                        
                    }
                    */
                    
                //}
                
                    self.fieldNoteTableView.reloadData()
                
                 
                }
        }
    }
    
    
    func addFieldNote(){
        //print("Add Field Note")
        
        print("making prep view")
        print("self.customerID = \(self.customerID)")
        
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Field Note", _ID: "0")
        imageUploadPrepViewController.selectedID = self.customerID
        imageUploadPrepViewController.layoutViews()
        
        imageUploadPrepViewController.woID = self.workOrderID
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.fieldNoteDelegate = self
        
        
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("fieldNotes tableCount \(fieldNotes.count)")
        return fieldNotes.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        ////print("cellForRowAtIndexPath")
        print("fieldNotes cellForRowAtIndexPath")
        let cell:FieldNoteTableViewCell = fieldNoteTableView.dequeueReusableCell(withIdentifier: "cell") as! FieldNoteTableViewCell
        
        
        cell.imageView?.image = nil
        cell.fieldNote = self.fieldNotes[indexPath.row]
        if(self.fieldNotes[indexPath.row].note == ""){
            cell.noteLbl.text = "No text given"
        }else{
            cell.noteLbl.text = self.fieldNotes[indexPath.row].note
        }
        
        
        print("image count = \(self.fieldNotes[indexPath.row].images.count)")
        
        if(self.fieldNotes[indexPath.row].images.count == 0){
            cell.imageQtyLbl.text = "No Images"
        }else{
            if(self.fieldNotes[indexPath.row].images.count == 1){
                cell.imageQtyLbl.text = "1 Image"
                
            }else{
                cell.imageQtyLbl.text = "\(self.fieldNotes[indexPath.row].images.count) Images"
            }
        }

        
        //print("pic = \(self.fieldNotes[indexPath.row].pic)")
        ////print("thumb = \(self.fieldNotes[indexPath.row].thumb)")
        
        //print("ID = \(self.fieldNotes[indexPath.row].ID)")
        cell.activityView.startAnimating()
        
        
        if(self.fieldNotes[indexPath.row].images.count > 0){
            // //print("image")
            
            print("url = \(self.fieldNotes[indexPath.row].images[0].thumbPath!)")
            if(verifyUrl("\(self.fieldNotes[indexPath.row].images[0].thumbPath!)")){
            cell.setImageUrl(_url: "\(self.fieldNotes[indexPath.row].images[0].thumbPath!)")
            }else{
            cell.setBlankImage()
           }
            
        }else{
            print("no field note image")
            
           cell.setBlankImage()
        }
 
        
        return cell;
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Field Note", _ID: self.fieldNotes[indexPath.row].ID)
        imageUploadPrepViewController.images = self.fieldNotes[indexPath.row].images
        imageUploadPrepViewController.layoutViews()
        imageUploadPrepViewController.groupDescriptionTxt.text = self.fieldNotes[indexPath.row].note
        imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
        imageUploadPrepViewController.selectedID = self.fieldNotes[indexPath.row].customerID
        imageUploadPrepViewController.woID = self.fieldNotes[indexPath.row].workOrderID
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.fieldNoteDelegate = self
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            
            //print("delete fieldNote ID = \(fieldNotes[indexPath.row].ID)")
            
            //cache buster
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            //, "cb":timeStamp as AnyObject
            
            Alamofire.request(API.Router.deleteFieldNote(["ID":fieldNotes[indexPath.row].ID as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
                
                response in
                //print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                //print(response.result)   // result of response serialization
                
                
                //let str = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)
                //print("string = \(str)")
                ////print(error)
                
                
                
                
                
                
                
                
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    
                    
                    
                    //add appPoints
                    var points:Int = JSON(json)["scoreAdjust"].intValue
                    //print("points = \(points)")
                    if(points > 0){
                        self.appDelegate.showMessage(_message: "earned \(points) App Points!")
                    }else if(points < 0){
                        points = points * -1
                        self.appDelegate.showMessage(_message: "lost \(points) App Points!")
                        
                    }

                    
                    
                    
                    
                }
            }
            
            _ = fieldNotes.remove(at: indexPath.row)
            fieldNoteTableView.reloadData()
            
            self.editsMade = true
            
        }
    }
    
    
    
    
    
    
    func removeViews(){
        for view in containerView.subviews{
            view.removeFromSuperview()
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.containerView.frame = view.bounds
    }
    
    
    func goBack(){
        //print("goBack")
        
        _ = navigationController?.popViewController(animated: false)
        //print("self.editsMade = \(self.editsMade)")
        if(self.editsMade == true){
             //print("self.workOrderID = \(self.workOrderID)")
            self.woDelegate.refreshWo(_refeshWoID: self.workOrderID!, _newWoStatus:"na")
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


