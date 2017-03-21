//
//  ImageUploadViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/15/17.
//  Copyright © 2017 Nick. All rights reserved.
//




//this class is the user interface to be subclassed for gallery, field note, task and equipment image upload and edits

import Foundation
import UIKit
import Alamofire
import SwiftyJSON




class ImageUploadViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var delegate:ImageViewDelegate!
    var indicator: SDevIndicator!
    var backButton:UIButton!
    
    var backgroundImageView:UIImageView!
    
    var blurEffect:UIBlurEffect!
    var blurredEffectView:UIVisualEffectView!
    
    
    var imageView:UIImageView!
    
    
    
    var activeField: UITextField?
    
    //header view
    var nameView:UIView!
    var nameTxt:UITextField!
    var namePlaceHolder:String = "Name..."
    
    var descriptionTxtView: UITextView!
    var descriptionPlaceHolder:String = "Description..."

    
    var searchBar:UISearchBar!
    var resultsTableView:TableView = TableView()
    var searchResults:[String] = []
    
    var submitBtn:Button = Button(titleText: "Submit")
    
    var loadingView:UIView!
    
    var progressView:UIProgressView!
    var progressValue:Float!
    var progressLbl:Label!
    
    var keyBoardShown:Bool = false
    
    
    
    //linking result arrays
    var ids = [String]()
    var names = [String]()
    
    
    
    
    
   //data items
    var imageType:String //example: task, fieldnote, custImage, equipmentImage
    var ID:String // taskID or fieldNoteID
    //var image:UIImage? // could be nil
    var images:[UIImage] = [UIImage]()
    var imageID:String // defaults to "0"
    var imageName:String //defaults to ""
    var imageDescription: String //defaults to ""
    var custID: String //defaults to "0"
    var woID: String //defaults to "0"
    var linkType:String //equipment link
    var linkID:String  // defaults to ""
    var saveURLString: String //php file to save/update
    var imageIndex: Int //defaults to "0"
    
    
    init(_imageType:String,_ID:String,_images:[UIImage], _saveURLString:String, _imageID:String = "0", _imageName:String = "", _imageDescription:String = "", _custID:String = "0", _woID:String = "0", _linkType:String = "", _linkID:String = "", _imageIndex:Int = 0){
       
        self.imageType = _imageType
        self.ID = _ID
        self.images = _images
        self.imageID = _imageID
        self.imageName = _imageName
        self.imageDescription = _imageDescription
        self.custID = _custID
        self.woID = _woID
        self.linkType = _linkType
        self.saveURLString = _saveURLString
        self.linkID = _linkID
        self.imageIndex = _imageIndex
        
        super.init(nibName:nil,bundle:nil)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.darkGray
        
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: layoutVars.fullHeight))
        
        
        //custom back button
        backButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        
        
        
    //to be added at and after init
        
     // saveURL   "http://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php"
    /*
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        self.loadLinkList(_linkType: "customers", _loadScript: API.Router.customerList(["cb":timeStamp as AnyObject]))
        */
    }
    
    
    
    
    func loadLinkList(_linkType:String, _loadScript:API.Router){
        print("load link list")
        
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        
        
        
        
       // Alamofire.request(API.Router.customerList(["cb":timeStamp as AnyObject])).responseJSON() {
        
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
        
        indicator.dismissIndicator()
        title = "\(self.imageType) Upload"
        

        
        self.backgroundImageView = UIImageView()
        
        self.backgroundImageView.clipsToBounds = true
        self.backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        self.backgroundImageView.alpha = 0.5
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.isUserInteractionEnabled = false
        //if(self.image != nil){
        if(self.images.count > 0){
            self.backgroundImageView.image = images[0]
        }
        
        self.view.addSubview(self.backgroundImageView)
        
        self.blurEffect = UIBlurEffect(style: .dark)
        self.blurredEffectView = UIVisualEffectView(effect: blurEffect)
        
        
        self.imageView = UIImageView()
        
        
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.isUserInteractionEnabled = true
        
        if(self.images.count > 0){
        //if(self.image != nil){
            self.imageView.image = images[0]
        }
        
        self.view.addSubview(self.imageView)
        
       
        
        self.nameView = UIView()
        self.nameView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.nameView)
        
        print("nameTxt")
        
        nameTxt = UITextField()
        
        if(self.imageName == ""){
            nameTxt.placeholder = "Name..."
        }else{
            nameTxt.text = self.imageName
        }
        
       
        nameTxt.font = layoutVars.smallFont
        nameTxt.layer.cornerRadius = 4
        nameTxt.clipsToBounds = true
        nameTxt.autocorrectionType = UITextAutocorrectionType.no
        nameTxt.keyboardType = UIKeyboardType.default
        nameTxt.returnKeyType = UIReturnKeyType.done
        nameTxt.clearButtonMode = UITextFieldViewMode.whileEditing;
        nameTxt.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        nameTxt.delegate = self
        nameTxt.backgroundColor = layoutVars.backgroundLight
        nameTxt.translatesAutoresizingMaskIntoConstraints = false
        self.nameView.addSubview(nameTxt)
 
        
        
        
        
        self.descriptionTxtView = UITextView()
        
        if(self.imageDescription == ""){
            self.descriptionTxtView.text = descriptionPlaceHolder
            self.descriptionTxtView.textColor = UIColor.lightGray

        }else{
            self.descriptionTxtView.text = self.imageDescription
        }
        
        
        
        self.descriptionTxtView.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionTxtView.delegate = self
        self.descriptionTxtView.font = layoutVars.smallFont
        self.descriptionTxtView.returnKeyType = UIReturnKeyType.done
        self.descriptionTxtView.layer.cornerRadius = 4
        self.descriptionTxtView.clipsToBounds = true
        self.descriptionTxtView.backgroundColor = layoutVars.backgroundLight
        self.descriptionTxtView.showsHorizontalScrollIndicator = false;
        self.nameView.addSubview(self.descriptionTxtView)
        
        
        self.submitBtn.addTarget(self, action: #selector(ImageUploadViewController.saveData), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.submitBtn)
        
        
        
        
        self.progressView = UIProgressView()
        self.progressView.tintColor = layoutVars.buttonColor1
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(self.progressView)
        
        self.progressLbl = Label(text: "Uploading...", valueMode: false)
        self.progressLbl.font = self.progressLbl.font.withSize(20)
        self.progressLbl.translatesAutoresizingMaskIntoConstraints = false
        self.progressLbl.textAlignment = NSTextAlignment.center
        self.loadingView.addSubview(self.progressLbl)

        
        

        
        
        
        self.blurredEffectView.frame = self.view.bounds
        self.backgroundImageView.addSubview(self.blurredEffectView)
        
        
        
        let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40, "navBarHeight":layoutVars.navAndStatusBarHeight] as [String : Any]
        
        //auto layout group
        let viewsDictionary = [
            "backgroundImageView":self.backgroundImageView, "imageView":self.imageView, "nameView":self.nameView, "submitBtn":self.submitBtn
            ] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[nameView]|", options: [], metrics: nil, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[nameView]-[submitBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        
        //auto layout group
        let viewsDictionary2 = [
            "nameTxt":self.nameTxt, "descriptionTxt":self.descriptionTxtView] as [String:Any]
        
        self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
        self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
        
        
        self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameTxt(30)]-[descriptionTxt(60)]", options: [], metrics: nil, views: viewsDictionary2))
        
        
        
        
        
        
        if(self.ids.count > 0){
            print("adding search bar")
            searchBar = UISearchBar()
            searchBar.placeholder = "Customer..."
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            
            
            searchBar.layer.cornerRadius = 4
            searchBar.clipsToBounds = true
            searchBar.backgroundColor = UIColor.white
            searchBar.barTintColor = UIColor.clear
            
            searchBar.searchBarStyle = UISearchBarStyle.minimal
            
            searchBar.delegate = self
            
            self.nameView.addSubview(searchBar)
            
            
            self.resultsTableView.delegate  =  self
            self.resultsTableView.dataSource = self
            
            //might want to change to custom linkCell class
            self.resultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "cell")
            
            
            self.resultsTableView.alpha = 0.0
            self.nameView.addSubview(self.resultsTableView)
            
            
            let viewsDictionary3 = ["searchBar":searchBar, "searchTable":self.resultsTableView] as [String:Any]
            
            
            self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary3))
            
            self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchTable]-|", options: [], metrics: nil, views: viewsDictionary3))
            
            
             self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-110-[searchBar(30)][searchTable]-|", options: [], metrics: nil, views: viewsDictionary3))
            
        }

    
        let progressDictionary = [
            "bar":self.progressView,
            "label":self.progressLbl
            ] as [String : Any]
        
        
        self.loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[bar]-15-|", options: [], metrics: sizeVals, views: progressDictionary))
        self.loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[label]-15-|", options: [], metrics: sizeVals, views: progressDictionary))
        
        self.loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[label(height)]-4-[bar(4)]", options: [], metrics: sizeVals, views: progressDictionary))
        
        self.loadingView.backgroundColor = UIColor.white
        self.loadingView.alpha = 0
        self.view.addSubview(loadingView)
        
        
       // NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
       // NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }
    
    
    
    
    
    
    func saveData(){
        print("Save Data")
        
        var createdBy:String = ""
        
        if(appDelegate.loggedInEmployee?.ID == ""){
            createdBy = "0"
        }else{
            createdBy = (appDelegate.loggedInEmployee?.ID)!
        }
        
        
        var nameString:String
        
        if(self.nameTxt.text == self.namePlaceHolder){
            nameString = ""
        }else{
            nameString = self.nameTxt.text!
            
            if(nameString.isAlphanumeric == false && !nameString.isEmpty){
                let alertController = UIAlertController(title: "Bad Name", message: "Names may only contain alphanumeric characters", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        var descriptionString:String
        
        if(self.descriptionTxtView.text == descriptionPlaceHolder){
            descriptionString = ""
        }else{
            descriptionString = self.descriptionTxtView.text!
            
        }
        
        showProgressScreen()
        
        var parameters:[String:String]
        parameters = [
            "ID":ID,
            "status":"0",
            "createdBy":createdBy,
            "name":nameString,
            "desc":descriptionString,
            "custID":custID,
            "woID":woID
        ]

        print("parameters = \(parameters)")
        
        let URL = try! URLRequest(url: self.saveURLString, method: .post, headers: nil)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            print("alamofire upload")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            for (image) in self.images {
                if  let imageData = UIImageJPEGRepresentation(image, 0.85) {
                    multipartFormData.append(imageData, withName: "pic", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
                }
            }
            print("multipartFormData = \(multipartFormData)")
        }, with: URL, encodingCompletion: { (result) in
            
            print("result = \(result)")
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                    
                    self.progressView.alpha = 1.0
                    DispatchQueue.main.async() {
                        self.progressView.setProgress(Float(Progress.fractionCompleted), animated: true)
                        
                        if  (Progress.fractionCompleted == 1.0) {
                            print("upload finished")
                           
                        }
                    }
                    
                })
                
                upload.responseJSON { response in
                    print(response.request ?? "")  // original URL request
                    print(response.response ?? "") // URL response
                    print(response.data ?? "")     // server data
                    print(response.result)   // result of response serialization
                    
                    if let result = response.result.value {
                        let json = result as! NSDictionary
                        print("return image json = \(json)")
                        
                        let thumbBase = JSON(json)["thumbBase"].stringValue
                        let rawBase = JSON(json)["rawBase"].stringValue
                        
                        let thumbPath = "\(thumbBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                        let rawPath = "\(rawBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                        
                        print("name = \(JSON(json)["images"][0]["name"].stringValue)")
                        print("thumbPath = \(thumbPath)")
                        
                         let image = Image(_id: JSON(json)["images"][0]["ID"].stringValue, _thumbPath: thumbPath, _rawPath: rawPath, _name: JSON(json)["images"][0]["name"].stringValue, _width: JSON(json)["images"][0]["width"].stringValue, _height: JSON(json)["images"][0]["height"].stringValue, _description: JSON(json)["images"][0]["description"].stringValue, _customer: JSON(json)["images"][0]["customer"].stringValue, _woID: JSON(json)["images"][0]["woID"].stringValue, _dateAdded: JSON(json)["images"][0]["dateAdded"].stringValue, _createdBy: JSON(json)["images"][0]["createdBy"].stringValue, _type: JSON(json)["images"][0]["type"].stringValue, _tags: JSON(json)["images"][0]["tags"].stringValue)
                        
                        self.hideProgressScreen()
                    
                        //may need index of image in list so we can update list
                       // self.delegate.refreshImages(_imageIndex:self.imageIndex,_image: image, _scoreAdjust: JSON(json)["scoreAdjust"].intValue)
                    
                    }
                }
                
                upload.responseString { response in
                    debugPrint("RESPONSE: \(response)")
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        })
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
        
        
        //self.progressLbl.text = "Image Uploaded. Thanks"
        
        
        UIView.animate(withDuration: 0.5,  animations: {
            self.progressView.alpha = 0.0
            
        }, completion: {(finished:Bool) in
            // the code you put here will be compiled once the animation finishes
            //self.resetForm()
            self.goBack()
        })
    }
    
    
    
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            //nameTxt.resignFirstResponder()
            descriptionTxtView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        
        if self.descriptionTxtView.textColor == UIColor.lightGray {
            self.descriptionTxtView.text = nil
            self.descriptionTxtView.textColor = UIColor.black
        }
    }
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
       
        if self.descriptionTxtView.text.isEmpty {
            self.descriptionTxtView.text = descriptionPlaceHolder
            self.descriptionTxtView.textColor = UIColor.lightGray
        }
    }

    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        self.view.endEditing(true)
        return false
    }
    
    
    /*
    func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            // tableView.contentInset.bottom = keyboardFrame.height
            if(!keyBoardShown){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    // var fabricTopFrame = self.fabricTop.frame
                    self.view.frame.origin.y -= keyboardFrame.height
                    
                    
                }, completion: { finished in
                    // print("Napkins opened!")
                })
            }
            
            
        }
        keyBoardShown = true
    }
    
    
    func keyboardDidHide(notification: NSNotification) {
        print("keyboardDidHide")
        keyBoardShown = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            // var fabricTopFrame = self.fabricTop.frame
            self.view.frame.origin.y = 0
            
            
        }, completion: { finished in
            //print("Napkins opened!")
        })
        
    }
    
 
 */
    
    /*
    func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    */
    
    
    
    /*
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    */
    
    
    
    
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        //filteredData = data.filter({$0.rangeOfString(searchText).location != NSNotFound})
        //tableView.reloadData()
        
        print("search edit")
        print("searchText.characters.count = \(searchText.characters.count)")
        //self.customerTableView.alpha = 1.0
        
        
         if (searchText.characters.count == 0) {
         print("search empty")
         linkID = "0"
         self.resultsTableView.alpha = 0.0
         }else{
         self.resultsTableView.alpha = 1.0
        }
        

        
        filterSearchResults()
        
        
    }
    
    
    
    
    
    /*
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchResults()
    }
 
 */
    
    func filterSearchResults(){
        searchResults = []
       
            self.searchResults = self.names.filter({( aCustomer: String ) -> Bool in
                return (aCustomer.lowercased().range(of: searchBar.text!.lowercased()) != nil)            })
                   self.resultsTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        //shouldShowSearchResults = true
        self.resultsTableView.reloadData()
        /*
        
        self.customerTableView.alpha = 1.0
        
        
        if (searchBar.text?.characters.count == 0) {
            print("search empty")
            selectedCustID = "0"
            self.customerTableView.alpha = 0.0
        }else{

        
        
            print("search edit")
            print("searchBar.text?.characters.count = \(searchBar.text?.characters.count)")
            self.customerTableView.alpha = 1.0
        }
 */
        /*
        if (searchBar.text?.characters.count == 0) {
           print("search empty")
            selectedCustID = "0"
            self.customerTableView.alpha = 0.0
        }else{
            self.customerTableView.alpha = 1.0
        }
        */
        
        
        
    }
    /*
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       // shouldShowSearchResults = false
        self.customerTableView.reloadData()
         self.customerTableView.alpha = 0.0
    }
 */
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //if !shouldShowSearchResults {
            //shouldShowSearchResults = true
            self.resultsTableView.reloadData()
       // }
        searchBar.resignFirstResponder()
    }
    
    /////////////// TableView Delegate Methods   ///////////////////////
    /*func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowSearchResults{
            return 1
        }else{
            return sections.count
        }
    }
 */
    
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //print("titleForHeaderInSection")
        if shouldShowSearchResults{
            return nil
        }else{
            if(sections[section].title == "#"){
                return "    # \(self.totalCustomers)  Customers Found"
            }else{
                return "    " + sections[section].title //hack way of indenting section text
                
            }
        }
        
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]?{
        print("sectionIndexTitlesForTableView 1")
        if shouldShowSearchResults{
            return nil
        }else{
            //print("sectionIndexTitlesForTableView \(sections.map { $0.title })")
            return sections.map { $0.title }
            
        }
    }
    
    
 
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //print("heightForHeaderInSection")
        if shouldShowSearchResults{
            return 0
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    
    
    
     
 
  */
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection")
        //if shouldShowSearchResults{
            return self.searchResults.count
       // } else {
           // return sections[section].length
        //}
    }

    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = resultsTableView.dequeueReusableCell(withIdentifier: "cell") as! CustomerTableViewCell
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        
        
        resultsTableView.rowHeight = 50.0
       
                cell.nameLbl.text = self.searchResults[indexPath.row]
                cell.name = self.searchResults[indexPath.row]
                if let i = self.names.index(of: cell.nameLbl.text!) {
                    //print("\(cell.nameLbl.text!) is at index \(i)")
                   
                    cell.id = self.ids[i]
                } else {
                   // cell.address = ""
                    cell.id = ""
                }
        
        cell.iconView.image = nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! CustomerTableViewCell
        
        
        linkID = currentCell.id
        
        if(imageType == "Gallery"){
            custID = currentCell.id
        }
        
        print("selectedCustID = \(linkID)")
        
        
        
        tableView.deselectRow(at: indexPath!, animated: true)
         self.resultsTableView.alpha = 0.0
        searchBar.text = currentCell.name
        searchBar.resignFirstResponder()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
       // deregisterFromKeyboardNotifications()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
