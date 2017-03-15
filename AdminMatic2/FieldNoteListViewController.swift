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
    func updateTable(_fieldNotes:[FieldNote])
    
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
    
    func updateTable(_fieldNotes:[FieldNote]){
        //print("updateTable")
        
        self.editsMade = true
        
        self.fieldNotes = _fieldNotes
        self.fieldNoteTableView.reloadData()
        
        
    }
    
    
    
    func addFieldNote(){
        //print("Add Field Note")
        let fieldNote:FieldNote = FieldNote(_ID: "0", _note: "", _customerID: self.customerID, _workOrderID: self.workOrderID, _createdBy: self.appDelegate.loggedInEmployee!.ID!, _status: "0", _pic: "0", _thumb: "0")
        
        let fieldNoteViewController = FieldNoteViewController(_fieldNote: fieldNote)
        //self.startTxtField.delegate = self
        fieldNoteViewController.delegate = self
        navigationController?.pushViewController(fieldNoteViewController, animated: false )
        //fieldNoteViewController.timesVisible = fieldNoteViewEntered // a gimp work around
        //fieldNoteViewEntered = 1;
        
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return fieldNotes.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        ////print("cellForRowAtIndexPath")
        let cell:FieldNoteTableViewCell = fieldNoteTableView.dequeueReusableCell(withIdentifier: "cell") as! FieldNoteTableViewCell
        
        
        cell.imageView?.image = nil
        cell.fieldNote = self.fieldNotes[indexPath.row]
        if(self.fieldNotes[indexPath.row].note == ""){
            cell.noteLbl.text = "No text given"
        }else{
            cell.noteLbl.text = self.fieldNotes[indexPath.row].note
        }
        
        ////print("pic = \(self.fieldNotes[indexPath.row].pic)")
        ////print("thumb = \(self.fieldNotes[indexPath.row].thumb)")
        
        //print("ID = \(self.fieldNotes[indexPath.row].ID)")
        
        if(self.fieldNotes[indexPath.row].pic != "0"){
            // //print("image")
            
            //check if url is good, image may have been deleted
            //if(verifyUrl("http://atlanticlawnandgarden.com/uploads/general/thumbs/\(self.fieldNotes[indexPath.row].thumb!)")){
            //print("url verified http://atlanticlawnandgarden.com/uploads/general/thumbs/\(self.fieldNotes[indexPath.row].thumb!)")
            cell.setImageUrl(_url: "http://atlanticlawnandgarden.com/uploads/general/thumbs/\(self.fieldNotes[indexPath.row].thumb!)")
            //}else{
            // cell.setBlankImage()
            // }
            
        }else{
            ////print("no image")
            
            cell.setBlankImage()
        }
        return cell;
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let fieldNote:FieldNote = FieldNote(_ID: self.fieldNotes[indexPath.row].ID, _note: self.fieldNotes[indexPath.row].note, _customerID: self.fieldNotes[indexPath.row].customerID, _workOrderID: self.fieldNotes[indexPath.row].workOrderID, _createdBy: self.fieldNotes[indexPath.row].createdBy, _status: self.fieldNotes[indexPath.row].status, _pic: self.fieldNotes[indexPath.row].pic, _thumb: self.fieldNotes[indexPath.row].thumb)
        
        let fieldNoteViewController = FieldNoteViewController(_fieldNote: fieldNote)
        navigationController?.pushViewController(fieldNoteViewController, animated: false )
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
                
                
                let str = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)
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


