//
//  ImageUploadPrepViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/18/17.
//  Copyright © 2017 Nick. All rights reserved.
//


//this class is the user interface to be subclassed for gallery, field note, task and equipment image upload and edits

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import DKImagePickerController


protocol ImageUploadPrepDelegate {
    func scrollToCell(_indexPath:IndexPath)
    func updateDescription(_index:Int, _description:String)
    func uploadComplete(_images:[Image],_scoreAdjust:Int)
}

protocol ImageDrawingDelegate{
    func updateImage(_indexPath:IndexPath, _image:UIImage)
}




class ImageUploadPrepViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate, ImageUploadPrepDelegate, ImageDrawingDelegate, ImageViewDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var delegate:ImageViewDelegate!  // refreshing the list
    var attachmentDelegate:AttachmentDelegate!  // refreshing the list
    var indicator: SDevIndicator!
    var backButton:UIButton!
    
    
    //header view
    var groupImages:Bool = false
    var groupSwitch:UISwitch = UISwitch()
    var groupSwitchLbl:Label = Label()
    var groupNameView:UIView = UIView()
    
    
    
    var groupNameTxt:PaddedTextField = PaddedTextField()
    var groupNamePlaceHolder:String!
    
    
    var groupDescriptionTxt: UITextView = UITextView()
    var groupDescriptionPlaceHolder:String!
    
    
    var groupSearchBar:UISearchBar = UISearchBar()
    var groupResultsTableView:TableView = TableView()
    var groupSearchResults:[String] = []
    
    
    
    
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView!
    
    
    var addImageBtn:Button = Button(titleText: "Add Image(s)")
    var submitBtn:Button = Button(titleText: "Submit")
    
    var loadingView:UIView!
    
    var progressView:UIProgressView!
    var progressValue:Float!
    var progressLbl:Label!
    
    var keyBoardShown:Bool = false
    
    
    
    //linking result arrays
    var ids = [String]()
    var names = [String]()
    var selectedID:String = ""
   
    var woID:String = ""
    var woItemID:String = ""
    var attachmentID:String = ""
    var leadID:String = ""
    var leadTaskID:String = ""
    var taskID:String = ""
    var taskStatus:String = ""
    var albumID:String = ""
    var customerID:String = ""
    
    //data items
    var imageType:String! //example: task, fieldnote, custImage, equipmentImage
    
    var images:[Image] = [Image]()  //full list of images being isplayed
    var imagesAdded:[Image] = [Image]()  // just newly added images to be uploaded
    
    var linkType:String! //equipment link
    
    var imageAdded:Bool = false
    var textEdited:Bool = false
    
    var imageEdit:Bool = false
    var keyboardHeight:CGFloat = 216
    
    var attachmentsJson:JSON?
    var attachments:[Attachment] = []
    let attachmentCount:Int = 0
    
    
    var tasksJson:JSON?
    var tasks:[Task] = []
    let taskCount:Int = 0
    
    var currentImageIndex:Int!
    var imageDetailViewController:ImageDetailViewController!
    
    var points:Int = 0
    

    //init for wo attachments
    init(_imageType:String,_woID:String,_customerID:String,_attachmentID:String,_images:[Image]){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for attachments")
        self.imageType = _imageType
        self.attachmentID = _attachmentID
        self.woID = _woID
        self.customerID = _customerID
        self.images = _images
    }
    
    //init for tasks
    init(_imageType:String,_taskID:String,_customerID:String,_images:[Image]){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for tasks")
        self.imageType = _imageType
        self.taskID = _taskID
        self.customerID = _customerID
        self.images = _images
    }
    
    //init for lead tasks
    init(_imageType:String,_leadID:String,_leadTaskID:String,_customerID:String,_images:[Image]){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for lead tasks")
        self.imageType = _imageType
        self.leadID = _leadID
        self.leadTaskID = _leadTaskID
        self.customerID = _customerID
        self.images = _images
        //self.saveURLString = _saveURLString
    }
    
    //init for customer
    init(_imageType:String,_customerID:String,_images:[Image]){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for customers")
        self.imageType = _imageType
        self.customerID = _customerID
        self.images = _images
        self.imagesAdded = _images
        //self.linkType = _linkType
    }
    
    //init for gallery
    init(_imageType:String, _linkType:String = "",_images:[Image]){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for gallery")
        self.imageType = _imageType
        self.linkType = _linkType
        self.images = _images
        self.imagesAdded = _images
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        print("ImmageUploadPrep viewDidLoad imageType = \(self.imageType)")
        
       
        
        switch imageType {
        case "Gallery":
                title = "Upload to Gallery"
            break
        case "Customer":
                title = "Upload Customer Image"
            break
        case "Attachment":
                title = "Add/Update Attachment"
            break
        case "Task":
                title = "Add/Update Task"
            break
        case "Lead Task":
                title = "Add/Update Lead Task"
            break
        
            
        case .none:
            print("bad switch case")
        case .some(_):
            print("bad switch case")
        }

        
        
        
        
        
        view.backgroundColor = UIColor.darkGray
        
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: layoutVars.fullHeight))
        
        
        //custom back button
        backButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ImageUploadPrepViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
    }
    
    
    
    
    func loadLinkList(_linkType:String, _loadScript:API.Router){
        print("load link list")
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
    
        
        Alamofire.request(_loadScript).responseJSON() {
            
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let results = json[_linkType] as? [[String: Any]] {
                    for result in results {
                        if let id = result["ID"] as? String {
                            self.ids.append(id)
                        }
                        if let name = result["name"] as? String {
                            self.names.append(name)
                        }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            self.layoutViews()
        }
    }
    
    

    func layoutViews(){
        
        print("layoutViews")
        if(indicator != nil){
            indicator.dismissIndicator()
        }
        
         currentImageIndex = 0
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.groupNameView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        groupSwitch.removeTarget(self, action: #selector(ImageUploadPrepViewController.switchValueDidChange(sender:)), for: .valueChanged)
    
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50), collectionViewLayout: layout)
        self.imageCollectionView.delegate  =  self
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.register(ImageUploadPrepCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imageCollectionView!)

        self.imageCollectionView.alwaysBounceVertical = true
        self.imageCollectionView.backgroundColor = UIColor.darkGray
        
       
        self.groupNameView.backgroundColor = UIColor.lightGray
        self.groupNameView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.groupNameView)
        
        
        groupSwitch.isOn = groupImages
        groupSwitch.translatesAutoresizingMaskIntoConstraints = false
        groupSwitch.addTarget(self, action: #selector(ImageUploadPrepViewController.switchValueDidChange(sender:)), for: .valueChanged)
        self.groupNameView.addSubview(groupSwitch)
        
        
        
      
        
        if(self.imageType == "Gallery"){
            print("gallery")
            
            groupSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
            self.groupNameView.addSubview(groupSwitchLbl)
            groupSwitchLbl.text = "Album"
            
           
        
            groupNamePlaceHolder = "Album Name..."
            
            if(groupImages == true){
                
                self.groupNameTxt.placeholder = groupNamePlaceHolder
                self.groupNameTxt.translatesAutoresizingMaskIntoConstraints = false
                self.groupNameTxt.delegate = self
                self.groupNameTxt.font = layoutVars.smallFont
                self.groupNameTxt.returnKeyType = UIReturnKeyType.done
                self.groupNameTxt.layer.cornerRadius = 4
                self.groupNameTxt.clipsToBounds = true
                self.groupNameTxt.backgroundColor = layoutVars.backgroundLight
                self.groupNameView.addSubview(self.groupNameTxt)
            }
            
            groupSearchBar.placeholder = "Customer..."
            groupSearchBar.translatesAutoresizingMaskIntoConstraints = false
            groupSearchBar.layer.cornerRadius = 4
            groupSearchBar.clipsToBounds = true
            groupSearchBar.backgroundColor = UIColor.white
            groupSearchBar.barTintColor = UIColor.clear
            groupSearchBar.searchBarStyle = UISearchBarStyle.minimal
            groupSearchBar.delegate = self
            self.groupNameView.addSubview(groupSearchBar)
            
            if(self.ids.count == 0){
                groupSearchBar.isUserInteractionEnabled = false
            }
            
            self.groupResultsTableView.delegate  =  self
            self.groupResultsTableView.dataSource = self
            //might want to change to custom linkCell class
            self.groupResultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "linkCell")
            self.groupResultsTableView.alpha = 0.0
            self.view.addSubview(self.groupResultsTableView)
            
            
            
            self.addImageBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.addImages), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.addImageBtn)
            
            
            self.submitBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.pickImageUploadSize), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.submitBtn)
            
        }else{
            print("attachment / task / lead task / customer")
            
                groupDescriptionPlaceHolder = "\(imageType!) description..."
            
            
                self.groupDescriptionTxt.text = groupDescriptionPlaceHolder
                self.groupDescriptionTxt.textColor = UIColor.lightGray
                
                self.groupDescriptionTxt.translatesAutoresizingMaskIntoConstraints = false
                self.groupDescriptionTxt.delegate = self
                self.groupDescriptionTxt.font = layoutVars.smallFont
                self.groupDescriptionTxt.returnKeyType = UIReturnKeyType.done
                self.groupDescriptionTxt.layer.cornerRadius = 4
                self.groupDescriptionTxt.clipsToBounds = true
                self.groupDescriptionTxt.backgroundColor = layoutVars.backgroundLight
                self.groupNameView.addSubview(self.groupDescriptionTxt)
                
                 print("group images")
            
            if(self.woID != "0" || self.taskID != "0" || self.leadTaskID != "0"){
                self.groupDescriptionTxt.isEditable = true
            }else{
                self.groupDescriptionTxt.isEditable = false
            }
            
            self.addImageBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.addImages), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.addImageBtn)
            

            
            self.submitBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.pickImageUploadSize), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.submitBtn)
             print("end")
            
        }
        
        
        
        
        //when to hide or show btns
        if(self.attachmentID == "0" || self.taskID == "0" || self.leadTaskID == "0" || self.imageType == "Customer" || self.imageType == "Gallery"){
        //if(self.woID != "0" && self.imageType != "Customer"){
            //self.addImageBtn.isHidden = false
            print("new item")
            //self.submitBtn.titleLabel?.text = "Submit Image(s)"
            self.submitBtn.setTitle("Submit", for: UIControlState())
        }else{
            //self.addImageBtn.isHidden = true
            print("existing item")
            self.submitBtn.setTitle("Update", for: UIControlState())
            
        }
        
        
        
        
        
        
        setConstraints()
        
        
    }
    
    
    func setConstraints(){
        print("set constraints")
        
        let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40, "navBarHeight":layoutVars.navAndStatusBarHeight, "keyboardHeight":self.keyboardHeight] as [String : Any]
        
        
         if(self.imageType == "Gallery"){
            
            //auto layout group
            let viewsDictionary = [
                "groupNameView":self.groupNameView, "imageCollection":self.imageCollectionView, "searchTable":self.groupResultsTableView, "addImageBtn":self.addImageBtn, "submitBtn":self.submitBtn
                ] as [String:Any]
            
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[groupNameView]|", options: [], metrics: nil, views: viewsDictionary))
            //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topImageView]|", options: [], metrics: nil, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageCollection]-|", options: [], metrics: nil, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchTable]-|", options: [], metrics: nil, views: viewsDictionary))
             self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[addImageBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            
            
            if(groupImages == true){
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(90)]-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                
                
                
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(90)]-[searchTable]-keyboardHeight-|", options: [], metrics: sizeVals, views: viewsDictionary))
                
                
            }else{
                if(self.imageType != "Customer"){
                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(50)]-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                    
                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(50)]-[searchTable]-keyboardHeight-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }else{
                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                    
                   // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(50)]-[searchTable]-keyboardHeight-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }
               
            }
            
            let viewsDictionary2 = ["groupSwitch":self.groupSwitch, "groupSwitchLbl":self.groupSwitchLbl, "groupNameTxt":self.groupNameTxt,"searchBar":groupSearchBar] as [String:Any]
            
            
            if(groupImages == true){
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupSwitch(50)]-20-[groupSwitchLbl(70)]-10-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary2))
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupNameTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitch(30)]-[groupNameTxt(30)]", options: [], metrics: nil, views: viewsDictionary2))
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitchLbl(30)]", options: [], metrics: nil, views: viewsDictionary2))
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(30)]", options: [], metrics: nil, views: viewsDictionary2))
                
                
            }else{
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupSwitch(40)]-10-[groupSwitchLbl(70)]-10-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary2))
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitch(30)]", options: [], metrics: nil, views: viewsDictionary2))
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitchLbl(30)]", options: [], metrics: nil, views: viewsDictionary2))
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(30)]", options: [], metrics: nil, views: viewsDictionary2))
            }
            
            
            
            
                
                
                
         }else{
            //field notes and tasks
            //auto layout group
            let viewsDictionary = [
                "groupNameView":self.groupNameView, "imageCollection":self.imageCollectionView, "addImageBtn":self.addImageBtn, "submitBtn":self.submitBtn
                ] as [String:Any]
            
            if(self.imageType != "Customer"){
                self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[groupNameView]|", options: [], metrics: nil, views: viewsDictionary))
                //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topImageView]|", options: [], metrics: nil, views: viewsDictionary))
            }
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageCollection]-|", options: [], metrics: nil, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
             self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[addImageBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            
            
            if(images.count > 0){
                if(self.imageType != "Customer"){
                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(90)]-[imageCollection]-[addImageBtn]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }else{
                     self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[imageCollection]-[addImageBtn]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }
                
               
            }else{
                if(self.imageType != "Customer"){

                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(90)]", options: [], metrics: sizeVals, views: viewsDictionary))
                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-130-[imageCollection]-[addImageBtn]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }else{
                    
                    //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(90)]", options: [], metrics: sizeVals, views: viewsDictionary))
                    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-90-[imageCollection]-[addImageBtn]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                    
                }
                
            }
            
        if(self.imageType != "Customer"){
            let viewsDictionary2 = ["groupDescriptionTxt":self.groupDescriptionTxt] as [String:Any]
            
            
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupDescriptionTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupDescriptionTxt(70)]", options: [], metrics: nil, views: viewsDictionary2))
            }
        }
        
       
        
    }
    
    
    /////////////// CollectionView Delegate Methods   ///////////////////////
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(self.images.count > 0){
            let totalHeight: CGFloat = 310.0
            let totalWidth: CGFloat = (self.view.frame.width - 10)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        }else{
            let totalHeight: CGFloat = 50.0
            let totalWidth: CGFloat = (self.view.frame.width - 10)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if(self.images.count > 0){
            return self.images.count
        /*}else{
            return 1
        }*/
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("making cells")
        
        
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageUploadPrepCollectionViewCell
        
        cell.backgroundColor = UIColor.lightGray
       // if(self.images.count > 0){
            cell.imageData = images[indexPath.row]
            
            print("cell image = \(cell.imageData.thumbPath)")
            cell.layoutViews()
            cell.delegate = self
            cell.indexPath = indexPath
            cell.setText()
            //cell.activityView.startAnimating()
            
       /* }else{
            
            if(self.ID == "0"){
                //self.addImagesLbl.isHidden = true
                cell.layoutViewsAdd()
            }
        }*/
        
    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
            //print("show full image view")
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageUploadPrepCollectionViewCell
        
        if(self.images[indexPath.row].ID != "0" && self.images[indexPath.row].ID != ""){
            print("createdBy = \(currentCell.imageData.createdBy)")
            
            imageDetailViewController = ImageDetailViewController(_image: currentCell.imageData)
            imageDetailViewController.imageFullViewController.delegate = self
            imageCollectionView?.deselectItem(at: indexPath, animated: true)
            navigationController?.pushViewController(imageDetailViewController, animated: false )
            imageDetailViewController.delegate = self
            
            currentImageIndex = indexPath.row
           return
        }
        
        
            
            
            
            let actionSheet = UIAlertController(title: "Edit Image Options", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            actionSheet.addAction(UIAlertAction(title: "Drawing", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
               self.draw(_indexPath: indexPath, _image: self.images[indexPath.row].image!)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cropping", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                self.crop(_indexPath: indexPath, _image: self.images[indexPath.row].image!)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                self.close(_indexPath: indexPath)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert:UIAlertAction!) -> Void in
            }))
            
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.present(actionSheet, animated: true, completion: nil)

                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = nav.popoverPresentationController as UIPopoverPresentationController!
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover?.sourceView = self.view
                popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                self.present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                self.present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }

            
            
            
        
        
    }
    
    @objc func addImages(){
        print("add images")
        
        print("imageType = \(self.imageType)")
        
        let n: Int! = self.navigationController?.viewControllers.count
        print("add images 2")
        switch (self.imageType) {
            
       
            
        case "Attachment":
            
            print("add images attachment")
            if(self.navigationController?.viewControllers[n-3] is ScheduleViewController){
                let myUIViewController = self.navigationController?.viewControllers[n-3] as! ScheduleViewController
                
                if(myUIViewController.searchController != nil){
                    myUIViewController.searchController.isActive = false
                }
            }
            break
            
        case "Task":
            
            print("add images task")
            if(self.navigationController?.viewControllers[n-4] is ScheduleViewController){
                print("add images task in if")
                let myUIViewController = self.navigationController?.viewControllers[n-4] as! ScheduleViewController
                
                if(myUIViewController.searchController != nil){
                    myUIViewController.searchController.isActive = false
                }
            }
            break
            
        case "Customer":
            let myUIViewController = self.navigationController?.viewControllers[n-3] as! CustomerListViewController
            
            if(myUIViewController.searchController != nil){
                myUIViewController.searchController.isActive = false
            }
            break
            
        default://home
            print("add images 3")
            break
            
        }
        //disable sesarch to prevent double modal present issue
        
        
        
        
        
        
        
        
        let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        
        print("add images 4")
        
        var selectedAssets = [DKAsset]()
        //var selectedImages:[Image] = [Image]()
        
        
        multiPicker.showsCancelButton = true
        multiPicker.assetType = .allPhotos
        
       
        
        self.present(multiPicker, animated: true) {}
        
        
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            self.imageAdded = true
            
            for i in 0..<assets.count
            {
                print("looping images")
                selectedAssets.append(assets[i])
                //print(self.selectedAssets)
                
                assets[i].fetchOriginalImage(true, completeBlock: { image, info in
                    
                    
                    print("making image")
                    
                    let imageToAdd:Image = Image(_id: "0", _thumbPath: "", _mediumPath: "", _rawPath: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), _type: "")
                    
                    imageToAdd.image = image
                    
                    
                    self.images.append(imageToAdd)
                    self.imagesAdded.append(imageToAdd)
                    
                })
            }
            
            self.imageCollectionView.reloadData()
            
            
            let lastItem = self.collectionView(self.imageCollectionView, numberOfItemsInSection: 0) - 1
            let indexPath: NSIndexPath = NSIndexPath.init(item: lastItem, section: 0)
            
            self.imageCollectionView.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
            
            
        }
    }

    
    func scrollToCell(_indexPath:IndexPath) {
        print("scroll to cell _indexPath = \(_indexPath.row)")
        
        
        
        
        let attributes:UICollectionViewLayoutAttributes = self.imageCollectionView.layoutAttributesForItem(at: _indexPath)!
        
        print("cell y location = \(attributes.frame.minY)")
        //scrolls to cell
        // print("currentScrollPosition = \(currentScrollPosition)")
        self.imageCollectionView.setContentOffset(CGPoint(x: 0, y: attributes.frame.midY), animated: true)
    }
    
    func uploadComplete(_images:[Image],_scoreAdjust:Int){
        print("upload complete")

        if(self.imageType == "Gallery" || self.imageType == "Customer"){
            delegate.refreshImages(_images: _images, _scoreAdjust: _scoreAdjust)
        }else if(self.imageType == "Task" || self.imageType == "Lead Task"){
            attachmentDelegate.updateTable(_points: (_scoreAdjust + points))
        }else{//attachments
            attachmentDelegate.updateTable(_points: (_scoreAdjust + points))
        }
        
        
    }
    
    
    func updateDescription(_index:Int, _description:String){
        print("update description index: \(_index) _description: \(_description)")
        self.images[_index].description = _description
    }
    
    
     
    
    
    func getPrevNextImage(_next:Bool){
        //print("IN  getPrevNextImage currentImageIndex = \(currentImageIndex!)")
        
            if(_next == true){
                if(currentImageIndex + 1) > (self.images.count - 1){
                    currentImageIndex = 0
                    imageDetailViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                    
                    
                }else{
                    currentImageIndex = currentImageIndex + 1
                    imageDetailViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.images.count - 1
                    imageDetailViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }else{
                    currentImageIndex = currentImageIndex - 1
                    imageDetailViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
            }
        
       
            imageCollectionView?.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0),
                                              at: .top,
                                              animated: false)
        
        
    }
    
    
    
    
    func refreshImages(_images:[Image], _scoreAdjust:Int){
        print("refreshImages")
        /*
        
        for insertImage in _images{
            
            imageArray.insert(insertImage, at: 0)
        }
        
        
        shouldShowSearchResults = false
        
        imageCollectionView?.reloadData()
        
        imageCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
        
        
        
        print("scoreAdjust")
        
        print("scoreAdjust = \(_scoreAdjust)")
        
        //add appPoints
        var points:Int = _scoreAdjust
        
        print("points = \(points)")
        
        if(points > 0){
            self.appDelegate.showMessage(_message: "earned \(points) App Points!")
        }else if(points < 0){
            points = points * -1
            self.appDelegate.showMessage(_message: "lost \(points) App Points!")
            
        }
        
        
        */
    }
    
    
    
    
    
/////////////// TableView Delegate Methods   ///////////////////////

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
            return self.groupSearchResults.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
            let cell = groupResultsTableView.dequeueReusableCell(withIdentifier: "linkCell") as! CustomerTableViewCell
            groupResultsTableView.rowHeight = 50.0
            cell.nameLbl.text = self.groupSearchResults[indexPath.row]
            cell.name = self.groupSearchResults[indexPath.row]
            if let i = self.names.index(of: cell.nameLbl.text!) {
                cell.id = self.ids[i]
            } else {
                cell.id = ""
            }
            cell.iconView.image = nil
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
            selectedID = currentCell.id
        print("select cust")
        if(imageType == "Gallery"){
                for image in images{
                    print("set image cust \(selectedID)")
                    image.customer = selectedID
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)
            self.groupResultsTableView.alpha = 0.0
            groupSearchBar.text = currentCell.name
            groupSearchBar.resignFirstResponder()
    }
    

    
/////////////// Search Delegate Methods   ///////////////////////

    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        print("search edit")
        print("searchText.count = \(searchText.count)")
        
        
        if (searchText.count == 0) {
        self.groupResultsTableView.alpha = 0.0
         }else{
        self.groupResultsTableView.alpha = 1.0
          }
        
        filterSearchResults()
    }
    

    
    func filterSearchResults(){
        groupSearchResults = []
        
        self.groupSearchResults = self.names.filter({( aCustomer: String ) -> Bool in
            return (aCustomer.lowercased().range(of: groupSearchBar.text!.lowercased()) != nil)            })
        self.groupResultsTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.groupResultsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.groupResultsTableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        self.groupResultsTableView.alpha = 0.0
    }

    @objc func switchValueDidChange(sender:UISwitch!)
    {
        print("switchValueDidChange groupImages = \(groupImages)")
        
        if (sender.isOn == true){
            print("on")
            groupImages = true
        }
        else{
            print("off")
            groupImages = false
        }
        layoutViews()
    }
    

    @objc func pickImageUploadSize(){
        
        if(imagesAdded.count == 0){
            self.saveData()
        }else{
            let actionSheet = UIAlertController(title: "Pick an Image Size", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            
            actionSheet.addAction(UIAlertAction(title: "Full 100%", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                  //print("show cam 1")
                self.saveData()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Medium 75%", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
               
                
                for image in self.imagesAdded{
                    image.image = image.image?.resized(withPercentage: 0.75)
                }
                
                
                self.saveData()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Small 50%", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                
               
                for image in self.imagesAdded{
                    image.image = image.image?.resized(withPercentage: 0.5)
                }
                self.saveData()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.present(actionSheet, animated: true, completion: nil)
                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = nav.popoverPresentationController as UIPopoverPresentationController!
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover?.sourceView = self.view
                popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                self.present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                self.present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }
            
        }
    }
    
    
    func saveData(){
        print("Save Data")
        
        
        for image in imagesAdded{
            image.name = self.imageType
        }
        
        if(self.imageType == "Gallery"){
        print("Gallery")
        
            if(groupImages == true){
                
                print("grouped")
                var groupNameString:String
                
                if(self.groupNameTxt.text == groupNamePlaceHolder){
                    groupNameString = ""
                }else{
                    groupNameString = self.groupNameTxt.text!
                    
                }
               
                
                let parameters = ["name": groupNameString as AnyObject,"description": "" as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                
                layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/new/album.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("new album response = \(response)")
                }
                
                .responseJSON(){
                    response in
                    
                    print(response.request ?? "")  // original URL request
                    print(response.response ?? "") // URL response
                    print(response.data ?? "")     // server data
                    print(response.result)   // result of response serialization
                    
                    ////print("JSON 1 \(json)")
                    if let json = response.result.value {
                        print("Album Json = \(json)")
                        let albumJson = JSON(json)
                        
                        let albumID = albumJson["newID"].stringValue
                        
                        print("albumID = \(albumID)")
                        for image in self.imagesAdded{
                            image.albumID = albumID
                            image.customer = self.selectedID
                        }
                        
                        let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: self.imagesAdded)
                        imageUploadProgressViewController.uploadPrepDelegate = self
                        self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                        
                    }
                    
                    self.indicator.dismissIndicator()
                    
                }
                
                /*
                 print("groupImages = \(groupImages)")
                 print("ID = \(ID)")
                 print("groupDescriptionString = \(groupDescriptionString)")
                 print("selectedID = \(selectedID)")
                 print("woID = \(woID)")
                 print("images.count = \(images.count)")
                 print("saveURLString = \(saveURLString)")
                 */
                
               
            }else{
                //seperate images, no album
                print("seperate")
               // print("imagesadded.count = \(imagesAdded.count)")
                let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: self.imagesAdded)
                imageUploadProgressViewController.uploadPrepDelegate = self
                self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                
                
            }
            
        }else{
            //tasks, lead tasks, wo attachments and customer
            print("tasks, lead tasks, wo attachments and customer")
            
            //for image in images{
               // image.customer = self.selectedID
            //}
            
            
                print("grouped")
                var groupDescString:String
                
                if(self.groupDescriptionTxt.text == groupDescriptionPlaceHolder){
                    groupDescString = ""
                    
                    if(imagesAdded.count == 0){
                        let alertController = UIAlertController(title: "Add Text or Image", message: "Write a description or add an image to submit.", preferredStyle: UIAlertControllerStyle.alert)
                       
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            print("OK")
                        }
                        
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                }else{
                    groupDescString = self.groupDescriptionTxt.text
                    
                }
            
               /* //cache buster
                let now = Date()
                let timeInterval = now.timeIntervalSince1970
                let timeStamp = Int(timeInterval)
            */
            
            if(self.imageType == "Attachment"){
                
                //let parameters = ["ID":"0", "note": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "custID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":"0" as AnyObject] as [String : Any]
                
                var parameters = [String : Any]()
                if(self.attachmentID == "0"){
                    //new leadTask needs to create leadTask ID first
                    //parameters = ["taskID":"0", "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                    parameters = ["ID":"0", "note": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "custID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":"0" as AnyObject] as [String : Any]
                }else{
                    //parameters = ["taskID":self.leadTaskID, "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                    parameters = ["ID":self.attachmentID, "note": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "custID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":"0" as AnyObject] as [String : Any]
                }
                
                
                
                print("parameters = \(parameters)")
                
                layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/fieldnote.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("new field note response = \(response)")
                    }
                    
                    .responseJSON(){
                        response in
                        
                        ////print("JSON 1 \(json)")
                        if let json = response.result.value {
                            print("Field Note Json = \(json)")
                            self.attachmentsJson = JSON(json)
                            
                            let attachmentID = self.attachmentsJson?["newID"].stringValue
                            
                            print("attachmentID = \(String(describing: attachmentID))")
                            for image in self.imagesAdded{
                                image.leadTaskID = attachmentID!
                                image.customer = self.selectedID
                                image.woID = self.woID
                            }
                            
                            /*
                            //add appPoints
                             self.points = JSON(json)["scoreAdjust"].intValue
                            //print("points = \(points)")
                            if(self.points > 0){
                               // self.appDelegate.showMessage(_message: "earned \(points) App Points!")
                            }else if(self.points < 0){
                                self.points = self.points * -1
                                //self.appDelegate.showMessage(_message: "lost \(points) App Points!")
                                
                            }
 */
                            
                            
                        }
                        
                        if(self.imagesAdded.count > 0){
                            let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: self.imagesAdded)
                            imageUploadProgressViewController.uploadPrepDelegate = self
                            self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                        }else{
                            if((self.attachmentDelegate) != nil){
                                self.attachmentDelegate.updateTable(_points: self.points)
                            }
                            self.imageAdded = false
                            self.textEdited = false
                            self.goBack()
                            
                        }
                        
                        
                }
            }else if(self.imageType == "Task"){
                //tasks
                var parameters = [String : Any]()
                if(self.taskID == "0"){
                    //new leadTask needs to create leadTask ID first
                    //parameters = ["taskID":"0", "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                     parameters = ["ID":"0", "task": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "woItemID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":"1" as AnyObject] as [String : Any]
                }else{
                    //parameters = ["taskID":self.leadTaskID, "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                     parameters = ["ID":self.taskID, "task": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "woItemID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":self.taskStatus as AnyObject] as [String : Any]
                }
                
                
                
                
                print("parameters = \(parameters)")
                layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/task.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("new task response = \(response)")
                    }
                    
                    .responseJSON(){
                        response in
                        
                        ////print("JSON 1 \(json)")
                        if let json = response.result.value {
                            print("Task Json = \(json)")
                            self.tasksJson = JSON(json)
                            
                            let taskID = self.tasksJson?["newID"].stringValue
                            
                           // print("taskID = \(String(describing: taskID) ?? <#default value#>)")
                            for image in self.imagesAdded{
                                image.taskID = taskID!
                                image.customer = self.customerID
                                image.woID = self.woID
                            }
                            
                            //add appPoints
                            self.points = (self.tasksJson?["scoreAdjust"].intValue)!
                            //print("points = \(points)")
                            if(self.points > 0){
                               // self.appDelegate.showMessage(_message: "earned \(points) App Points!")
                            }else if(self.points < 0){
                                self.points = self.points * -1
                                //self.appDelegate.showMessage(_message: "lost \(points) App Points!")
                            }
                        }
                        if(self.imagesAdded.count > 0){
                            let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: self.imagesAdded)
                            imageUploadProgressViewController.uploadPrepDelegate = self
                            self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                        }else{
                            if((self.attachmentDelegate) != nil){
                                self.attachmentDelegate.updateTable(_points: self.points)
                            }
                            self.imageAdded = false
                            self.textEdited = false
                            self.goBack()
                        }
                }
            }else if(self.imageType == "Lead Task"){
                //Lead Task
                var parameters = [String : Any]()
               
                 if(self.leadTaskID == "0"){
                    //new leadTask needs to create leadTask ID first
                    parameters = ["taskID":"0", "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                }else{
                    parameters = ["taskID":self.leadTaskID, "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                }
 
                
                    print("parameters = \(parameters)")
                    layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/leadTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                        .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                        .responseString { response in
                            print("new task response = \(response)")
                        }
                        
                        .responseJSON(){
                            response in
                            
                            ////print("JSON 1 \(json)")
                            if let json = response.result.value {
                                print("Task Json = \(json)")
                                self.tasksJson = JSON(json)
                                
                                let newLeadTaskID = self.tasksJson?["leadTaskID"].stringValue
                                
                                // print("taskID = \(String(describing: taskID) ?? <#default value#>)")
                                for image in self.imagesAdded{
                                    // image.taskID = taskID!
                                    image.leadTaskID = newLeadTaskID!
                                    image.customer = self.customerID
                                    //image.woID = self.woID
                                }
                                
                                //add appPoints
                                self.points = (self.tasksJson?["scoreAdjust"].intValue)!
                                //print("points = \(points)")
                                if(self.points > 0){
                                    // self.appDelegate.showMessage(_message: "earned \(points) App Points!")
                                }else if(self.points < 0){
                                    self.points = self.points * -1
                                    //self.appDelegate.showMessage(_message: "lost \(points) App Points!")
                                }
                            }
                            if(self.imagesAdded.count > 0){
                                let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: self.imagesAdded)
                                imageUploadProgressViewController.uploadPrepDelegate = self
                                self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                            }else{
                                if((self.attachmentDelegate) != nil){
                                    self.attachmentDelegate.updateTable(_points: self.points)
                                }
                                self.imageAdded = false
                                self.textEdited = false
                                self.goBack()
                            }
                    }
                
            
            
            
          
            }else{
                //Customer
                
                if(groupImages == true){
                    
                    print("grouped")
                    var groupNameString:String
                    
                    if(self.groupNameTxt.text == groupNamePlaceHolder){
                        groupNameString = ""
                    }else{
                        groupNameString = self.groupNameTxt.text!
                        
                    }
                    
                    /*
                    //cache buster
                    let now = Date()
                    let timeInterval = now.timeIntervalSince1970
                    let timeStamp = Int(timeInterval)
                    //, "cb":timeStamp as AnyObject
 */
                    
                    let parameters = ["name": groupNameString as AnyObject,"description": "" as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                    
                    layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/new/album.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                        .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                        .responseString { response in
                            print("new album response = \(response)")
                        }
                        
                        .responseJSON(){
                            response in
                            
                            print(response.request ?? "")  // original URL request
                            print(response.response ?? "") // URL response
                            print(response.data ?? "")     // server data
                            print(response.result)   // result of response serialization
                            
                            ////print("JSON 1 \(json)")
                            if let json = response.result.value {
                                print("Album Json = \(json)")
                                let albumJson = JSON(json)
                                
                                let albumID = albumJson["newID"].stringValue
                                
                                print("albumID = \(albumID)")
                                for image in self.imagesAdded{
                                    image.albumID = albumID
                                    image.customer = self.customerID
                                }
                                
                                let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: self.imagesAdded)
                                imageUploadProgressViewController.uploadPrepDelegate = self
                                self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                                
                            }
                            
                            self.indicator.dismissIndicator()
                            
                    }
                    
                    /*
                     print("groupImages = \(groupImages)")
                     print("ID = \(ID)")
                     print("groupDescriptionString = \(groupDescriptionString)")
                     print("selectedID = \(selectedID)")
                     print("woID = \(woID)")
                     print("images.count = \(images.count)")
                     print("saveURLString = \(saveURLString)")
                     */
                    
                    
                }else{
                    //seperate images, no album
                    print("seperate")
                    
                    for image in self.imagesAdded{
                        image.customer = self.customerID
                    }
                    
                    
                    let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: self.imagesAdded)
                    imageUploadProgressViewController.uploadPrepDelegate = self
                    self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                    
                    
                }
                
                
                
              
            }
            

            
            if(self.indicator != nil){
                self.indicator.dismissIndicator()

            }
            
                
            }
        
    }
    
    func showProgressScreen(){
        print("showProgressScreen")
        self.view.isUserInteractionEnabled = false
        self.submitBtn.isUserInteractionEnabled = false
        self.backButton.isUserInteractionEnabled = false
        self.progressView.alpha = 1.0
        UIView.animate(withDuration: 0.75, animations: {() -> Void in
            self.loadingView.alpha = 1
        })
    }
    
    func hideProgressScreen(){
        print("hideProgressScreen")
        UIView.animate(withDuration: 0.5,  animations: {
            self.progressView.alpha = 0.0
            
        }, completion: {(finished:Bool) in
            self.goBack()
        })
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            groupDescriptionTxt.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.groupDescriptionTxt.textColor == UIColor.lightGray {
            self.groupDescriptionTxt.text = nil
            self.groupDescriptionTxt.textColor = UIColor.black
            self.textEdited = true
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.groupDescriptionTxt.text.isEmpty {
            self.groupDescriptionTxt.text = groupDescriptionPlaceHolder
            self.groupDescriptionTxt.textColor = UIColor.lightGray
            self.textEdited = false
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        self.view.endEditing(true)
        return false
    }
    
    
    

    func draw(_indexPath:IndexPath,_image:UIImage){
        let imageDrawingViewController = ImageDrawingViewController(_indexPath:_indexPath, _image:_image)
        imageDrawingViewController.delegate = self
        navigationController?.pushViewController(imageDrawingViewController, animated: false )
        imageEdit = true;
    }
    
    func crop(_indexPath:IndexPath,_image:UIImage){
        let imageCroppingViewController = ImageCroppingViewController(_indexPath:_indexPath, _image:_image)
        imageCroppingViewController.delegate = self
        navigationController?.pushViewController(imageCroppingViewController, animated: false )
        imageEdit = true;
    }
    
    
    func close(_indexPath:IndexPath){
        
        
        if(images.count > 1){
            images.remove(at: _indexPath.row)
            self.imageCollectionView.reloadData()
            
            
            
            
        }else{
            
            if(self.imageType == "Gallery"){
                
                let alertController = UIAlertController(title: "Cancel Upload?", message: "", preferredStyle: UIAlertControllerStyle.alert)
                let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    self.goBack()
                }
                
                let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                images.remove(at: _indexPath.row)
                self.imageCollectionView.reloadData()
            }
            
            
            
            
            
            
            
        }
        
        imagesAdded = []
        for image in self.images{
            if(image.ID == "0" || image.ID == ""){
                imagesAdded.append(image)
            }
        }
    }
    
 
 
    
    
    

    func updateImage(_indexPath:IndexPath, _image: UIImage) {
        images[_indexPath.row].image = _image
        self.imageCollectionView.reloadData()
    }
    
    

    @objc func goBack(){
        print("go back")
        
        if(self.imageAdded == true || self.textEdited == true){
            let alertController = UIAlertController(title: "Go back without Submitting?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                _ = self.navigationController?.popViewController(animated: false)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: false)
        }
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
