//
//  ImageCollectionViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/14/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
//import SwiftyJSON
//import Nuke
import DKImagePickerController

protocol ImageViewDelegate{
    func getPrevNextImage(_next:Bool)
    func refreshImages(_images:[Image], _scoreAdjust:Int)
    func showCustomerImages(_customer:String)
}
 
protocol ImageSettingsDelegate{
    func updateSettings(_uploadedBy:String,_portfolio:String,_attachment:String,_task:String,_order:String,_customer:String)
}
    
protocol ImageLikeDelegate{
    func updateLikes(_index:Int, _liked:String, _likes:String)
}


class ImageCollectionViewController: ViewControllerWithMenu, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, ImageViewDelegate, ImageSettingsDelegate, ImageLikeDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource  {
        
    var layoutVars:LayoutVars!
    var indicator: SDevIndicator!
    var totalImages:Int!
    var imageArray:[Image] = []
    var shouldShowSearchResults:Bool = false
    var searchTerm:String = "" // used to retain search when leaving this view and having to deactivate search to enable device rotation - a real pain
    var searchController:UISearchController!
    
    var tagsResultsTableView:TableView = TableView()
    var tags = [String]()
    var tagsSearchResults:[String] = []
    var selectedTag:String = ""
    
    var selectedImages:[Image] = [Image]()
    
    
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView?
    var addImageBtn:Button = Button(titleText: "Add Images")
    
    var imageSettingsBtn:Button = Button(titleText: "")
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    var currentImageIndex:Int!
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    var refresher:UIRefreshControl!
    
    //setting vars
    var uploadedBy:String = "0"
    var portfolio:String = "0"
    var attachment:String = "0"
    var task:String = "0"
    var customer:String = ""
    
    var order:String = "ID DESC"
    
    
    var lazyLoad = 0
    var limit = 100
    var offset = 0
    var batch = 0
    
    
    
    var methodStart:Date!
    var methodFinish:Date!
    
    
    
    var i:Int = 0 //number of times thia vc is displayed
    
    init(_mode:String){
        super.init(nibName:nil,bundle:nil)
        print("init _mode = \(_mode)")
        
        
        title = "Images"
 
        self.view.backgroundColor = layoutVars.backgroundColor
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
       
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       layoutVars = LayoutVars()
        
            getTags()
       
    }
    
    func getTags(){
        //print("parameters = \(parameters)")
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        methodStart = Date()
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/tags.php",method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("tags response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                //native way
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        
                        
                        let tags = json["tags"] as? [[String: Any]] {
                        
                        let tagCount = tags.count
                        print("tag count = \(tagCount)")
                        
                        for i in 0 ..< tagCount {
                            
                            
                            self.tags.append(tags[i]["name"] as! String)
                            
                        }
                    }
                    
                    self.methodFinish = Date()
                    let executionTime = self.methodFinish.timeIntervalSince(self.methodStart)
                    print("Execution time: \(executionTime)")
                    
                    
                     self.getImages()
                    
                    
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
                
                
                
                
                
                
                
               /*
                
                //swifty way
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.tagsJSON = JSON(json)
                    self.parseTagsJSON()
                    
                }
                
               // self.indicator.dismissIndicator()
                */
                
                
        }
        
        
        
    }
    
    /*
    func parseTagsJSON(){
        let jsonCount = self.tagsJSON["tags"].count
        //self.totalImages = jsonCount
        print("JSONcount: \(jsonCount)")
        
        
        for i in 0 ..< jsonCount {
            
            
            
            self.tags.append(self.tagsJSON["tags"][i]["name"].stringValue)
            
        }
        
        
        methodFinish = Date()
        let executionTime = methodFinish.timeIntervalSince(methodStart)
        print("Execution time: \(executionTime)")
        
        
        
        self.getImages()
        
        
    }
    */
    
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
       print("viewWillAppear")
       //print("imagesSearchResults.count = \(imagesSearchResults.count)")
        currentImageIndex = 0
        if(searchTerm != ""){
            searchController.isActive = true
            self.searchController.searchBar.text = searchTerm
        }
        
       
    }
    
    func getImages() {
        //remove any added views (needed for table refresh
        
        print("get images")
       
        
       
        methodStart = Date()
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        var parameters = [String:AnyObject]()
        
        
        
        if selectedTag == ""{
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "limit": self.limit as AnyObject,"offset": self.offset as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject]
        }else{
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "tag":self.selectedTag as AnyObject, "limit": self.limit as AnyObject,"offset": self.offset as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject]
            
        }
 
        
     
        
        if(self.uploadedBy != "0"){
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "uploadedBy": self.uploadedBy as AnyObject]
        }
        
        if(self.portfolio == "1"){
           
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "tag":self.selectedTag as AnyObject, "limit": self.limit as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "portfolio": self.portfolio as AnyObject]
           
        }
        
        if(self.attachment == "1"){
             parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "fieldnotes": self.attachment as AnyObject]
        }
        
        if(self.task == "1"){
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "task": self.task as AnyObject]
        }
        
        if self.customer != ""{
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "customer": self.customer as AnyObject]
        }
        
        
        
        
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/images.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                
                print("images response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                
                //native way
                
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let images = json["images"] as? [[String: Any]] {
                        
                        let imageCount = images.count
                        print("image count = \(imageCount)")
                        
                        let thumbBase:String = json["thumbBase"] as! String
                        let mediumBase:String = json["mediumBase"] as! String
                        let rawBase:String = json["rawBase"] as! String
                        
                        
                        //for image in images {
                        for i in 0 ..< imageCount {
                            
                            let thumbPath:String = "\(thumbBase)\(images[i]["fileName"] as! String)"
                            let mediumPath:String = "\(mediumBase)\(images[i]["fileName"] as! String)"
                            let rawPath:String = "\(rawBase)\(images[i]["fileName"] as! String)"
                            
                            //create a item object
                            print("create an image object \(i)")
                            
                            
                            
                            
                            let image = Image(_id: images[i]["ID"] as? String,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: images[i]["name"] as? String,_width: images[i]["width"] as? String,_height: images[i]["height"] as? String,_description: images[i]["description"] as? String,_dateAdded: images[i]["dateAdded"] as? String,_createdBy: images[i]["createdByName"] as? String,_type: images[i]["type"] as? String)
                            
                            image.customer = images[i]["customer"] as! String
                            image.customerName = images[i]["customerName"] as! String
                            image.tags = images[i]["tags"] as! String
                            image.liked =  images[i]["liked"] as! String //images[i]["liked"] as! String
                            image.likes = images[i]["likes"] as! String
                            image.index = i
                            
                            //image.liked = "1"
                            //image.likes = "26"
                            
                            self.imageArray.append(image)
                            
                            
                            
                            /*
                            if let id = customer["ID"] as? String {
                                //self.ids.append(id)
                            }
                            if let name = customer["name"] as? String {
                                //self.names.append(name)
                            }
                            
                            if let address = customer["mainAddr"] as? String {
                                //self.addresses.append(address)
                            }
 */
                            
                        }
                    }
                    
                    if(self.lazyLoad == 0){
                        self.layoutViews()
                    }else{
                        self.lazyLoad = 0
                        self.imageCollectionView?.reloadData()
                    }
                    
                    
                    
                    
                    self.methodFinish = Date()
                    let executionTime = self.methodFinish.timeIntervalSince(self.methodStart)
                    print("Execution time: \(executionTime)")
                    
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
               
                
                /*
               //swityJSON way
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.images = JSON(json)
                    self.parseJSON()
                    
                }
                
                */
                
                
                
                
                self.indicator.dismissIndicator()
        }
    }
    
    /*
    func parseJSON(){
        let jsonCount = self.images["images"].count
        self.totalImages = jsonCount
        print("JSONcount: \(jsonCount)")
        
        let thumbBase:String = self.images["thumbBase"].stringValue
        let mediumBase:String = self.images["mediumBase"].stringValue
        let rawBase:String = self.images["rawBase"].stringValue
        
        for i in 0 ..< jsonCount {
            
            let thumbPath:String = "\(thumbBase)\(self.images["images"][i]["fileName"].stringValue)"
            let mediumPath:String = "\(mediumBase)\(self.images["images"][i]["fileName"].stringValue)"
            let rawPath:String = "\(rawBase)\(self.images["images"][i]["fileName"].stringValue)"
                
            //create a item object
            print("create an image object \(i)")
            
            let image = Image(_id: self.images["images"][i]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: self.images["images"][i]["name"].stringValue,_width: self.images["images"][i]["width"].stringValue,_height: self.images["images"][i]["height"].stringValue,_description: self.images["images"][i]["description"].stringValue,_dateAdded: self.images["images"][i]["dateAdded"].stringValue,_createdBy: self.images["images"][i]["createdByName"].stringValue,_type: self.images["images"][i]["type"].stringValue)
            
            image.customer = self.images["images"][i]["customer"].stringValue
            image.customerName = self.images["images"][i]["customerName"].stringValue
            image.tags = self.images["images"][i]["tags"].stringValue
            image.liked = self.images["images"][i]["liked"].stringValue
            image.likes = self.images["images"][i]["likes"].stringValue
            image.index = i
            
            //image.liked = "1"
            //image.likes = "26"
        
            self.imageArray.append(image)
            
        }
        if(lazyLoad == 0){
            self.layoutViews()
        }else{
            lazyLoad = 0
            self.imageCollectionView?.reloadData()
        }
        
        methodFinish = Date()
        let executionTime = methodFinish.timeIntervalSince(methodStart)
        print("Execution time: \(executionTime)")
        
        
        
        
    }
    */
    
    
    
    func layoutViews(){
        
        
        
        print("layoutViews collection")
        // Close Indicator
        indicator.dismissIndicator()
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
       
            // Initialize and perform a minimum configuration to the search controller.
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.placeholder = "Search Image Tags"
            searchController.searchResultsUpdater = self
            searchController.delegate = self
            searchController.searchBar.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
        
        
        
        //workaround for ios 11 larger search bar
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        
        
        
        

            imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), collectionViewLayout: layout)
            
            
            imageCollectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            
            self.view.addSubview(imageCollectionView!)
        
        
        
        
        imageCollectionView?.dataSource = self
        imageCollectionView?.delegate = self
        imageCollectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView?.backgroundColor = UIColor.darkGray
        
        
        
        let refresher = UIRefreshControl()
        self.imageCollectionView!.alwaysBounceVertical = true
        
       
       refresher.addTarget(self, action: #selector(ImageCollectionViewController.loadData), for: .valueChanged)
        imageCollectionView!.addSubview(refresher)
        
        
        self.tagsResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.tagsResultsTableView.delegate  =  self
        self.tagsResultsTableView.dataSource = self
        self.tagsResultsTableView.register(TagTableViewCell.self, forCellReuseIdentifier: "tagCell")
        self.tagsResultsTableView.alpha = 0.0
        self.tagsResultsTableView.separatorStyle = .none
        self.tagsResultsTableView.backgroundColor = UIColor.clear
        self.view.addSubview(self.tagsResultsTableView)
        
        
        
        
        
        self.addImageBtn.addTarget(self, action: #selector(ImageCollectionViewController.addImage), for: UIControl.Event.touchUpInside)
        
        self.addImageBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width - 100, height: 50)
        self.addImageBtn.translatesAutoresizingMaskIntoConstraints = true
        self.addImageBtn.layer.borderColor = UIColor.white.cgColor
        self.addImageBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.addImageBtn)
        
        self.imageSettingsBtn.addTarget(self, action: #selector(ImageCollectionViewController.imageSettings), for: UIControl.Event.touchUpInside)
        
        self.imageSettingsBtn.frame = CGRect(x:self.view.frame.width - 50, y: self.view.frame.height - 50, width: 50, height: 50)
        self.imageSettingsBtn.translatesAutoresizingMaskIntoConstraints = true
        self.imageSettingsBtn.layer.borderColor = UIColor.white.cgColor
        self.imageSettingsBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.imageSettingsBtn)
        
        self.imageSettingsBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        

        
        
        settingsIcon.backgroundColor = UIColor.clear
        settingsIcon.contentMode = .scaleAspectFill
        settingsIcon.frame = CGRect(x: 11, y: 11, width: 28, height: 28)
        
        
        if(self.uploadedBy != "0" || self.portfolio != "0" || self.attachment != "0" || self.task != "0" || self.order != "ID DESC" || self.customer != ""){
            print("changes made")
            settingsIcon.image = settingsEditedImg
        }else{
            settingsIcon.image = settingsImg
        }

        
        
        self.imageSettingsBtn.addSubview(settingsIcon)
        
    }
    
    
   
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(portraitMode == true){
            let totalHeight: CGFloat = (self.view.frame.width / 3 - 1)
            let totalWidth: CGFloat = (self.view.frame.width / 3 - 1)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        }else{
            let totalHeight: CGFloat = (self.view.frame.width / 5 - 1)
            let totalWidth: CGFloat = (self.view.frame.width / 5 - 1)
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
         /*if(shouldShowSearchResults == false){
            return self.imageArray.count
         }else{
            return self.imagesSearchResults.count
        }*/
        
        
        return self.imageArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("making cells")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        cell.activityView.startAnimating()
        cell.imageView.image = nil
        
       
        print("name = \(self.imageArray[indexPath.row].name!)")
        
        cell.textLabel.text = " \(self.imageArray[indexPath.row].customerName)"
        
        
        
        
        
        print("thumb = \(self.imageArray[indexPath.row].thumbPath!)")
        
        //let imgURL:URL = URL(string: self.imageArray[indexPath.row].thumbPath!)!
        
        //print("imgURL = \(imgURL)")
        
        Alamofire.request(self.imageArray[indexPath.row].thumbPath!).responseImage { response in
            debugPrint(response)
            
            //print(response.request)
            //print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                cell.imageView.image = image
                cell.image = self.imageArray[indexPath.row]
                cell.activityView.stopAnimating()
                
                
                //self.employeeImage.image = image
                
                //let image2 = Image(_path: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.employee.pic!)
                //self.imageFullViewController = ImageFullViewController(_image: image2)
                //self.imageFullViewController = ImageFullViewController(_image: image)
            }
        }
        
     
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
       // print("mode = \(self.mode)")
        
        imageDetailViewController = ImageDetailViewController(_image: currentCell.image)
        imageDetailViewController.imageFullViewController.delegate = self
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        imageDetailViewController.imageLikeDelegate = self
        
      
        
        currentImageIndex = indexPath.row
        

    }
    
    /////////////// Search Methods   ///////////////////////
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResultsForSearchController \(searchController.searchBar.text)")
        filterSearchResults()
    }
    
    func filterSearchResults(){
        //print("filterSearchResults")
        
        self.tagsSearchResults = self.tags.filter({( aTag: String) -> Bool in
            return (aTag.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
        self.tagsResultsTableView.reloadData()
        //self.imageCollectionView?.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        //shouldShowSearchResults = true
        //self.imageCollectionView?.reloadData()
        
        self.tagsResultsTableView.alpha = 1.0
        self.tagsResultsTableView.reloadData()
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchTerm = ""
        
        
        self.tagsSearchResults = []
        self.tagsResultsTableView.alpha = 0.0
        self.tagsResultsTableView.reloadData()
        self.selectedTag = ""
        self.imageArray = []
        self.imageCollectionView?.reloadData()
        getImages()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        
        self.tagsResultsTableView.reloadData()
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
    }
    
    
    
    /////////////// Table Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        count = self.tagsSearchResults.count
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
       
        //print("cell for row tableViewMode = \(self.searchController.tableViewMode)")
        
        
            //print("customer name: \(self.customerNames[indexPath.row])")
            let searchString = self.searchController.searchBar.text!.lowercased()
        
            let cell:TagTableViewCell = tagsResultsTableView.dequeueReusableCell(withIdentifier: "tagCell") as! TagTableViewCell
            
            
            cell.titleLbl.text = self.tagsSearchResults[indexPath.row]
       
        
            //text highlighting
            let baseString:NSString = self.tagsSearchResults[indexPath.row] as NSString
            let highlightedText = NSMutableAttributedString(string: self.tagsSearchResults[indexPath.row])
            var error: NSError?
            let regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error1 as NSError {
                error = error1
                regex = nil
            }
            if let regexError = error {
                print("Oh no! \(regexError)")
            } else {
                for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                    highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
            }
            cell.titleLbl.attributedText = highlightedText
            
            
            return cell
        
            
            
        //}
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            let currentCell = tableView.cellForRow(at: indexPath) as! TagTableViewCell
           // self.searchController.searchBar.text = currentCell.titleLbl.text!
            self.selectedTag = currentCell.titleLbl.text!
            self.searchController.searchBar.resignFirstResponder()
            self.tagsResultsTableView.alpha = 0.0
        
            self.lazyLoad = 0
            self.limit = 100
            self.offset = 0
            self.batch = 0
            self.imageArray = []
        
        
            getImages()
        
        self.searchController.searchBar.text = currentCell.titleLbl.text!
            searchTerm = self.selectedTag
    }
    
    
    
    
    
    
    
    
    
    
    
    func willPresentSearchController(_ searchController: UISearchController){
        
        
    }
    
    
    func presentSearchController(searchController: UISearchController){
        
    }

    //refresh functions
    
    @objc func loadData()
    {
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        offset = 0
        batch = 0
        
        imageArray = []
        
        
        print("loadData")
        getImages()
        stopRefresher()         //Call this to stop refresher
    }
    
    func stopRefresher()
    {   print("stopRefresher")
    }

    
    
    
    @objc func addImage(){
        print("Add Image")
        if(searchController != nil){
            searchController.isActive = false
        }
        
        
        let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        var selectedAssets = [DKAsset]()
        

       
        multiPicker.showsCancelButton = true
        multiPicker.assetType = .allPhotos
        self.layoutVars.getTopController().present(multiPicker, animated: true) {}
        
        
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            for i in 0..<assets.count
            {
                print("looping images")
                selectedAssets.append(assets[i])
                //print(self.selectedAssets)
                
                
                //assets[i].fetchOriginalImage(completeBlock: <#T##(UIImage?, [AnyHashable : Any]?) -> Void#>)
                assets[i].fetchOriginalImage(completeBlock: { image, info in
               
                    
                    print("making image 1")
                    
                     let imageToAdd:Image = Image(_id: "0", _thumbPath: "", _mediumPath: "", _rawPath: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), _type: "")
                    
                    imageToAdd.image = image
                    
                    
                   self.selectedImages.append(imageToAdd)
                    print("selectedimages count = \(self.selectedImages.count)")
                    
                    if self.selectedImages.count == assets.count{
                        self.createPrepView()
                    }
                })
            }
            
            
            

        }
        
        
    }
    
    func createPrepView(){
        print("create prep view")
        
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        print("making prep view")
        print("selectedimages count = \(selectedImages.count)")
        
        // let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Gallery", _ID: "0", _images: selectedImages, _saveURLString: "https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php?cb=\(timeStamp)")
        
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Gallery", _images: selectedImages)
        
        
        print("url = https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php?cb=\(timeStamp)")
        
        print("self.selectedImages.count = \(selectedImages.count)")
        
        imageUploadPrepViewController.loadLinkList(_linkType: "customers", _loadScript: API.Router.customerList(["cb":timeStamp as AnyObject]))
        
        
        imageUploadPrepViewController.delegate = self
        
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
        
        
        
    }
    
    
    @objc func imageSettings(){
        print("image settings")
        
        let imageSettingsViewController = ImageSettingsViewController(_uploadedBy:self.uploadedBy,_portfolio: self.portfolio, _attachment: self.attachment, _task: self.task, _order:self.order, _customer:self.customer)
        imageSettingsViewController.imageSettingsDelegate = self
        navigationController?.pushViewController(imageSettingsViewController, animated: false )
        
        
        
    }
    
    
    func getPrevNextImage(_next:Bool){
        //print("IN  getPrevNextImage currentImageIndex = \(currentImageIndex!)")
        //if(shouldShowSearchResults == false){
            if(_next == true){
                if(currentImageIndex + 1) > (self.imageArray.count - 1){
                    currentImageIndex = 0
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                    
                    
                }else{
                    currentImageIndex = currentImageIndex + 1
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.imageArray.count - 1
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }else{
                    currentImageIndex = currentImageIndex - 1
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
            }
            
        
            imageCollectionView?.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0),
                                              at: .top,
                                              animated: false)
       
        

    }

    
    
    
    func refreshImages(_images:[Image], _scoreAdjust:Int){
        print("refreshImages")
        
        for insertImage in _images{
            
            imageArray.insert(insertImage, at: 0)
        }

        offset = 0
        batch = 0
        
        shouldShowSearchResults = false
        
        
        imageCollectionView?.reloadData()
        
        imageCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
         
 
       
        
        
    }
    
    func showCustomerImages(_customer:String){
        print("show customer images cust: \(_customer)")
        
        self.customer = _customer
        self.imageArray = []
        getImages()
        
        
    }
    
    
    
    
    func updateSettings(_uploadedBy:String,_portfolio:String, _attachment:String,_task:String,_order:String,_customer:String){
        print("update settings")
        print("_uploadedBy = \(_uploadedBy) _portfolio = \(_portfolio) _attachment = \(_attachment) _task = \(_task) _order = \(_order) _customer = \(_customer)")
        self.portfolio = _portfolio
        self.attachment = _attachment
        self.task = _task
        self.uploadedBy = _uploadedBy
        self.order = _order
        self.customer = _customer
        
        offset = 0
        batch = 0
        
        
        
        
        
        
    
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        imageArray = []
        
        
        getImages()
    }
    
    
    func updateLikes(_index:Int, _liked:String, _likes:String){
        print("update likes _liked: \(_liked)  _likes\(_likes)")
        imageArray[_index].liked = _liked
        imageArray[_index].likes = _likes
        
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //print("rotate view")
        
        guard let flowLayout = imageCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            //here you can do the logic for the cell size if phone is in landscape
            //print("landscape")
            portraitMode = false
            
        } else {
            //logic if not landscape
             //print("portrait")
            portraitMode = true
        }
        
        imageCollectionView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50)
        tagsResultsTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50)
       self.addImageBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50)
        
        
        
        flowLayout.invalidateLayout()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.bounds.maxY == scrollView.contentSize.height) {
            print("scrolled to bottom")
            lazyLoad = 1
            batch += 1
            offset = batch * limit
            getImages()
        }
    }
    
    
    
    //restores device to portrait mode when leaving
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        print("view will disappear")
        
         self.imageCollectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        if(searchController != nil){
            searchController.isActive = false
        }
        
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    func canRotate() -> Void {}
    
    
}
