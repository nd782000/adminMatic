//
//  ImageUploadViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/15/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON
//import Nuke




class ImageUploadViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    //var delegate:ImageViewDelegate!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var delegate:ImageViewDelegate!
    var indicator: SDevIndicator!
    var backButton:UIButton!
    var selectedImage:UIImage!
    var backgroundImageView:UIImageView!
    
    var blurEffect:UIBlurEffect!
    var blurredEffectView:UIVisualEffectView!
    
    //var scrollView:UIScrollView!
    
    var imageView:UIImageView!
    //var activityView:UIActivityIndicatorView!
    
    
    
    var activeField: UITextField?
    
    //header view
    var nameView:UIView!
    var nameTxt:UITextField!
    var namePlaceHolder:String = "Name..."
    //var searchController:UISearchController!
    
    var descriptionTxtView: UITextView!
    var descriptionPlaceHolder:String = "Description..."

    
    var searchBar:UISearchBar!
    var customerTableView:TableView = TableView()
    var customersSearchResults:[String] = []
    

    
    //footer view
   // var descriptionView:UIView!
    
    var submitBtn:Button = Button(titleText: "Submit")
    
    
    var loadingView:UIView!
    
    var progressView:UIProgressView!
    var progressValue:Float!
    var progressLbl:Label!
    
    var keyBoardShown:Bool = false
    
    
    
    
    var ids = [String]()
    var names = [String]()
    
    var selectedCustID:String = "0"
    
    
    
    
   
    
    
    
    
    

    
    
    init(_image:UIImage){
        super.init(nibName:nil,bundle:nil)
        self.selectedImage = _image
        
        
        //registerForKeyboardNotifications()
        
        
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
        
        
        
        
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        Alamofire.request(API.Router.customerList(["cb":timeStamp as AnyObject])).responseJSON() {
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let customers = json["customers"] as? [[String: Any]] {
                    for customer in customers {
                        if let id = customer["ID"] as? String {
                            self.ids.append(id)
                        }
                        if let name = customer["sysName"] as? String {
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
        title = "Image Upload"
        /*
        self.scrollView = UIScrollView()
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.scrollView)
        */

        
        self.backgroundImageView = UIImageView()
        
        self.backgroundImageView.clipsToBounds = true
        self.backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        self.backgroundImageView.alpha = 0.5
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.isUserInteractionEnabled = false
        self.backgroundImageView.image = selectedImage
        self.view.addSubview(self.backgroundImageView)
        
        self.blurEffect = UIBlurEffect(style: .dark)
        self.blurredEffectView = UIVisualEffectView(effect: blurEffect)
        
        
        self.imageView = UIImageView()
        
        
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.isUserInteractionEnabled = true
        self.imageView.image = selectedImage
        self.view.addSubview(self.imageView)
        
       
        
        self.nameView = UIView()
        self.nameView.translatesAutoresizingMaskIntoConstraints = false
       // self.nameView.backgroundColor = UIColor(hex: 0x005100, op: 0.6)
        self.view.addSubview(self.nameView)
        
        print("nameTxt")
        
        //nameTxt = UITextField(frame: CGRect(20, 100, 300, 40))
        nameTxt = UITextField()
        nameTxt.placeholder = "Name..."
       
        //nameTxt.font = UIFont.systemFont(ofSize: 15)
        nameTxt.font = layoutVars.smallFont
        //nameTxt.borderStyle = UITextBorderStyle.roundedRect
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
        self.descriptionTxtView.text = descriptionPlaceHolder
        self.descriptionTxtView.textColor = UIColor.lightGray
        
        
        self.descriptionTxtView.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionTxtView.delegate = self
        self.descriptionTxtView.font = layoutVars.smallFont
        self.descriptionTxtView.returnKeyType = UIReturnKeyType.done
        self.descriptionTxtView.layer.cornerRadius = 4
        self.descriptionTxtView.clipsToBounds = true
        self.descriptionTxtView.backgroundColor = layoutVars.backgroundLight
        self.descriptionTxtView.showsHorizontalScrollIndicator = false;
        self.nameView.addSubview(self.descriptionTxtView)
        
        
        
        
        
        
        searchBar = UISearchBar()
        searchBar.placeholder = "Customer..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        //searchBar.layer.borderWidth = 1
        
        searchBar.layer.cornerRadius = 4
        searchBar.clipsToBounds = true
        searchBar.backgroundColor = UIColor.white
        searchBar.barTintColor = UIColor.clear
        
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        
        searchBar.delegate = self
        
        self.nameView.addSubview(searchBar)
        
        
        self.customerTableView.delegate  =  self
        self.customerTableView.dataSource = self
        self.customerTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "cell")
        self.customerTableView.alpha = 0.0
        self.nameView.addSubview(self.customerTableView)
        
        
        
        
        
        
       /*
        print("descriptionTxtView")
        
        
        self.descriptionView = UIView()
        self.descriptionView.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionView.backgroundColor = UIColor(hex: 0x005100, op: 0.6)
        self.view.addSubview(self.descriptionView)

        */
        
       
        
        
        
       
        
        
        
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
        
        
        print("self.blurredEffectView.frame.size.width = \(self.blurredEffectView.frame.size.width)")
        
        /*
        //auto layout group
        let scrollDictionary = [
            "scrollView":self.scrollView] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: scrollDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: scrollDictionary))
        */
        
          let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40, "navBarHeight":layoutVars.navAndStatusBarHeight] as [String : Any]
        
        //auto layout group
        let viewsDictionary = [
            "backgroundImageView":self.backgroundImageView, "imageView":self.imageView, "nameView":self.nameView, "submitBtn":self.submitBtn
            ] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[nameView]|", options: [], metrics: nil, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
       // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[submitBtn]|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[nameView]-[submitBtn(40)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
       // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[submitBtn(40)]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        //auto layout group
        let viewsDictionary2 = [
            "nameTxt":self.nameTxt, "descriptionTxt":self.descriptionTxtView,"searchBar":searchBar, "searchTable":self.customerTableView] as [String:Any]
        
        self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
        self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
        self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary2))
         self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchTable]-|", options: [], metrics: nil, views: viewsDictionary2))
        
        self.nameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameTxt(30)]-[descriptionTxt(60)]-10-[searchBar(30)][searchTable]-|", options: [], metrics: nil, views: viewsDictionary2))
        
        
        
        /*
        
        //auto layout group
        let viewsDictionary3 = [
            "descriptionTxtView":self.descriptionTxtView, "submitBtn":self.submitBtn] as [String:Any]
        
        self.descriptionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionTxtView]-|", options: [], metrics: nil, views: viewsDictionary3))
        self.descriptionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary3))
        
        self.descriptionView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[descriptionTxtView(100)][submitBtn(30)]-|", options: [], metrics: nil, views: viewsDictionary3))
        */
        
        
        
        
      
        
        
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
            
            /*
            if(descriptionString.isAlphanumeric == false && !descriptionString.isEmpty){
                
                
                let alertController = UIAlertController(title: "Bad Description", message: "Descriptions may only contain alphanumeric characters", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
 
                
                return
                
                
                
            }
*/
            
            
        }
        
        showProgressScreen()
        
        var parameters:[String:String]
        parameters = [
            "createdBy":createdBy,
            "customer": selectedCustID,
            "name": nameString,
            "desc"      : descriptionString,
            "width"      : "\(self.imageView.image!.fixedOrientation().size.width)",
            "height"      : "\(self.imageView.image!.fixedOrientation().size.height)"
        ]
        
        
        print("parameters = \(parameters)")
        
        let URL = try! URLRequest(url: "http://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php", method: .post, headers: nil)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            print("alamofire upload")
            
           
            
                multipartFormData.append(UIImageJPEGRepresentation(self.imageView.image!.fixedOrientation(), 0.85)!, withName: "pic", fileName: "swift_file.jpeg", mimeType: "image/jpg")
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
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
                        
                        
                         let image = Image(_id: JSON(json)["images"][0]["ID"].stringValue, _thumbPath: thumbPath, _rawPath: rawPath, _name: JSON(json)["images"][0]["name"].stringValue, _width: JSON(json)["images"][0]["width"].stringValue, _height: JSON(json)["images"][0]["height"].stringValue, _description: JSON(json)["images"][0]["description"].stringValue, _customer: JSON(json)["images"][0]["customer"].stringValue, _dateAdded: JSON(json)["images"][0]["dateAdded"].stringValue, _createdBy: JSON(json)["images"][0]["createdBy"].stringValue, _type: JSON(json)["images"][0]["type"].stringValue, _tags: JSON(json)["images"][0]["tags"].stringValue)
                        
                        
                         self.hideProgressScreen()
                        
                        self.delegate.refreshImages(_image: image, _scoreAdjust: JSON(json)["scoreAdjust"].intValue)
                        
                        
                        
                        
                                               
                        
                        
                        
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
         selectedCustID = "0"
         self.customerTableView.alpha = 0.0
         }else{
         self.customerTableView.alpha = 1.0
        }
        

        
        filterSearchResults()
        
        
    }
    
    
    
    
    
    /*
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchResults()
    }
 
 */
    
    func filterSearchResults(){
        customersSearchResults = []
       
            self.customersSearchResults = self.names.filter({( aCustomer: String ) -> Bool in
                return (aCustomer.lowercased().range(of: searchBar.text!.lowercased()) != nil)            })
                   self.customerTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        //shouldShowSearchResults = true
        self.customerTableView.reloadData()
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
            self.customerTableView.reloadData()
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
            return self.customersSearchResults.count
       // } else {
           // return sections[section].length
        //}
    }

    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = customerTableView.dequeueReusableCell(withIdentifier: "cell") as! CustomerTableViewCell
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        
        
        customerTableView.rowHeight = 50.0
       
                cell.nameLbl.text = self.customersSearchResults[indexPath.row]
                cell.name = self.customersSearchResults[indexPath.row]
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
        
        
        selectedCustID = currentCell.id
        
        print("selectedCustID = \(selectedCustID)")
        
        
        
        tableView.deselectRow(at: indexPath!, animated: true)
         self.customerTableView.alpha = 0.0
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
