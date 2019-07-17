//
//  AttachmentListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/11/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol AttachmentDelegate{
    func updateTable(_points:Int)
    
}


 

class AttachmentListViewController: ViewControllerWithMenu, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, AttachmentDelegate{
//class AttachmentListViewController: UIViewController{
    
    var layoutVars:LayoutVars = LayoutVars()
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var woDelegate:WoDelegate!
    
    //vavarndicator: SDevIndicator!
    
    var containerView:UIView!
    
    var workOrderID:String!
    var customerID:String!
    var woItemID:String!
    
    
    var json:JSON!
    
    var addAttachmentBtn: Button!
    var attachmentTableView: TableView!
    var attachmentsJson:JSON?

    
    var attachments: [Attachment] = []//data array
    
    // var attachmentViewEntered:Int = 0
    
    var editsMade:Bool = false
    
    
    init(_workOrderID:String,_customerID:String,_attachments:[Attachment]){
        super.init(nibName:nil,bundle:nil)
        self.workOrderID = _workOrderID
        self.customerID = _customerID
        self.attachments = _attachments
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Attachments"
        
        /*
        
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(AttachmentListViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        //container view for auto layout
        self.containerView = UIView()
        self.containerView.backgroundColor = layoutVars.backgroundColor
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.containerView)
        
        
        
        self.addAttachmentBtn = Button(titleText: "Add")
        
        self.addAttachmentBtn.titleLabel?.textAlignment = NSTextAlignment.center
        self.addAttachmentBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.addAttachmentBtn.addTarget(self, action: #selector(AttachmentListViewController.addAttachment), for: UIControl.Event.touchUpInside)
        self.containerView.addSubview(self.addAttachmentBtn)
        
        //employee table
        self.attachmentTableView =  TableView()
        self.attachmentTableView.delegate  =  self
        self.attachmentTableView.dataSource  =  self
        self.attachmentTableView.rowHeight = 60.0
        
        self.attachmentTableView.register(AttachmentTableViewCell.self, forCellReuseIdentifier: "cell")
        self.containerView.addSubview(self.attachmentTableView)
        
        //auto layout group
        let viewsDictionary = [
            "container":self.containerView,
            "addBtn":self.addAttachmentBtn,
            "table":self.attachmentTableView
        ]as [String : Any]
        // ////print("2")
        let metricsDictionary = ["screenWidth": self.view.frame.size.width,"screenHeight": self.view.frame.size.height,"fullWidth": self.view.frame.size.width - 20,"halfWidth": (self.view.frame.size.width - 20)/2,"inputHeight":layoutVars.inputHeight,"doubleInputHeight":layoutVars.inputHeight*2] as [String : Any]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container(screenWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container(screenHeight)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        //////print("3")
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[addBtn(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[table(fullWidth)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
        self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[addBtn(inputHeight)]-[table]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        
    }
    
    func updateTable(_points:Int){
        print("updateTable")
        //self.appDelegate.showMessage(_message: "earned \(_points) App Points!")
        
        self.editsMade = true
        getAttachments()
    }
    
    func getAttachments(){
        print("get field notes")
        
        /*
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
 */
        let parameters:[String:String]
        parameters = ["woID": self.workOrderID]
        
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
                    self.attachmentsJson = JSON(json)
                    
                    let fn = self.attachmentsJson?["attachments"]
                    
                    self.attachments = []
                    
                    //Attachments
                    print("Field Note Count = \(String(describing: fn?.count))")
                    
                    for n in 0 ..< Int((fn?.count)!) {
                        
                        
                        var attachmentImages:[Image]  = []
                        
                        
                        let imageCount = Int((fn?[n]["images"].count)!)
                        print("imageCount: \(imageCount)")
                        
                        
                        
                        
                        for i in 0 ..< imageCount {
                            
                            let fileName:String = (fn?[n]["images"][i]["fileName"].stringValue)!
                            
                            let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                            let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                            let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                            
                            //create a item object
                            print("create an image object \(i)")
                            
                            print("rawPath = \(rawPath)")
                            
                            let image = Image(_id: fn?[n]["images"][i]["ID"].stringValue,_thumbPath: thumbPath, _mediumPath: mediumPath,_rawPath: rawPath,_name: fn?[n]["images"][i]["name"].stringValue,_width: fn?[n]["images"][i]["width"].stringValue,_height: fn?[n]["images"][i]["height"].stringValue,_description: fn?[n]["images"][i]["description"].stringValue,_dateAdded: fn?[n]["images"][i]["dateAdded"].stringValue,_createdBy: fn?[n]["images"][i]["createdByName"].stringValue,_type: fn?[n]["images"][i]["type"].stringValue)
                            
                            image.customer = (fn?[n]["images"][i]["customer"].stringValue)!
                            image.tags = (fn?[n]["images"][i]["tags"].stringValue)!
                            
                            attachmentImages.append(image)
                            
                        }
                        
                        let attachment = Attachment(_ID: fn?[n]["ID"].stringValue, _note: fn?[n]["note"].stringValue, _customerID: fn?[n]["customerID"].stringValue, _workOrderID: fn?[n]["workOrderID"].stringValue, _createdBy: fn?[n]["createdBy"].stringValue, _status: fn?[n]["status"].stringValue, _images:attachmentImages)
                        
                        
                        self.attachments.append(attachment)
                         
                    }
                    
                    
                
                    self.attachmentTableView.reloadData()
                
                 
                }
        }
    }
    
    
    @objc func addAttachment(){
        //print("Add Field Note")
        
        print("making prep view")
        //print("self.customerID = \(self.customerID)")
        
        //let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Field Note", _ID: "0")
        //let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Attachment", _woID: self.workOrderID, _attachmentID: "0", _images: [])
        
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Attachment", _woID: self.workOrderID, _customerID: self.customerID, _attachmentID: "0", _images: [])
        
        
        imageUploadPrepViewController.selectedID = self.customerID
        imageUploadPrepViewController.layoutViews()
        
        imageUploadPrepViewController.woID = self.workOrderID
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.attachmentDelegate = self
        
        
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("attachments tableCount \(attachments.count)")
        return attachments.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        ////print("cellForRowAtIndexPath")
        print("attachments cellForRowAtIndexPath")
        let cell:AttachmentTableViewCell = attachmentTableView.dequeueReusableCell(withIdentifier: "cell") as! AttachmentTableViewCell
        
        
        cell.imageView?.image = nil
        cell.attachment = self.attachments[indexPath.row]
        if(self.attachments[indexPath.row].note == ""){
            cell.noteLbl.text = "No text given"
        }else{
            cell.noteLbl.text = self.attachments[indexPath.row].note
        }
        
        
        print("image count = \(self.attachments[indexPath.row].images.count)")
        
        if(self.attachments[indexPath.row].images.count == 0){
            cell.imageQtyLbl.text = "No Images"
        }else{
            if(self.attachments[indexPath.row].images.count == 1){
                cell.imageQtyLbl.text = "1 Image"
                
            }else{
                cell.imageQtyLbl.text = "\(self.attachments[indexPath.row].images.count) Images"
            }
        }

        
        //print("pic = \(self.attachments[indexPath.row].pic)")
        ////print("thumb = \(self.attachments[indexPath.row].thumb)")
        
        //print("ID = \(self.attachments[indexPath.row].ID)")
        cell.activityView.startAnimating()
        
        
        if(self.attachments[indexPath.row].images.count > 0){
            // //print("image")
            
            print("url = \(self.attachments[indexPath.row].images[0].thumbPath!)")
            if(verifyUrl("\(self.attachments[indexPath.row].images[0].thumbPath!)")){
            cell.setImageUrl(_url: "\(self.attachments[indexPath.row].images[0].thumbPath!)")
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
        
        /*
        
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Attachment", _woID: self.workOrderID, _customerID: self.customerID, _attachmentID: self.attachments[indexPath.row].ID, _images: self.attachments[indexPath.row].images)
        
        
        imageUploadPrepViewController.images = self.attachments[indexPath.row].images
        imageUploadPrepViewController.layoutViews()
        imageUploadPrepViewController.groupDescriptionTxt.text = self.attachments[indexPath.row].note
        imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
        imageUploadPrepViewController.selectedID = self.attachments[indexPath.row].customerID
        imageUploadPrepViewController.woID = self.attachments[indexPath.row].workOrderID
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.attachmentDelegate = self
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
 */
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            
            
            //print("delete attachment ID = \(attachments[indexPath.row].ID)")
            
            //cache buster
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            //, "cb":timeStamp as AnyObject
            
            Alamofire.request(API.Router.deleteAttachment(["ID":attachments[indexPath.row].ID as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
                
                response in
                //print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                //print(response.result)   // result of response serialization
                
                
                
                
            }
            
            _ = attachments.remove(at: indexPath.row)
            attachmentTableView.reloadData()
            
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
    
    
    @objc func goBack(){
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


