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
import SwiftyJSON
import Nuke
import DKImagePickerController

protocol ImageViewDelegate{
    func getPrevNextImage(_next:Bool)
    func refreshImages(_images:[Image], _scoreAdjust:Int)
}

protocol ImageSettingsDelegate{
    func updateSettings(_uploadedBy:String,_portfolio:String,_fieldNote:String,_task:String,_order:String)
}
    
protocol ImageLikeDelegate{
    func updateLikes(_index:Int, _liked:String, _likes:String)
}


class ImageCollectionViewController: ViewControllerWithMenu, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, ImageViewDelegate, ImageSettingsDelegate, ImageLikeDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate  {
        
    var layoutVars:LayoutVars!
    var indicator: SDevIndicator!
    var totalImages:Int!
    var images: JSON!
    var imageArray:[Image] = []
    var imagesSearchResults:[Image] = []
    var imagesSearchResults2:[Image] = []
    var shouldShowSearchResults:Bool = false
    var searchTerm:String = "" // used to retain search when leaving this view and having to deactivate search to enable device rotation - a real pain
    var searchController:UISearchController!
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView?
    var addImageBtn:Button = Button(titleText: "Add Images")
    
    var imageSettingsBtn:Button = Button(titleText: "")
    
    var currentImageIndex:Int!
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    var refresher:UIRefreshControl!
    
    //setting vars
    var uploadedBy:String = "0"
    var portfolio:String = "0"
    var fieldNote:String = "0"
    var task:String = "0"
    
    var order:String = "ID DESC"
    
    
    var lazyLoad = 0
    var limit = 100
    var offset = 0
    var batch = 0
    
    
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    
    var i:Int = 0 //number of times thia vc is displayed
    
    init(_mode:String){
        super.init(nibName:nil,bundle:nil)
        print("init _mode = \(_mode)")
        /*
        self.mode = _mode
        
        
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy"
       
        
        self.year = formatter.string(from: date)
        
        print("year = \(year)")
        
        formatter.dateFormat = "MM"
        
        
        self.month = formatter.string(from: date)

        print("month = \(month)")
       */
            
       /* switch (_mode) {
            case "Top Image":
                
                title = "Top Image"
               
                break;
                
            default://home
                //print("Show  Home Screen")
 
                
                break;
            }
 */
        
        title = "Images"
 
        self.view.backgroundColor = layoutVars.backgroundColor
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        /*
        //monthPickerView.datePickerMode = UIDatePickerMode.date
        monthFormatter.dateFormat = "MM"
        
        let now = Date()
        self.month = monthFormatter.string(from: now)
        monthFormatter.dateFormat = "yyyy"
        self.year = monthFormatter.string(from: now)
        
        */
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       layoutVars = LayoutVars()
        
        //if(self.mode != "Top Image"){
            getImages()
       // }
       
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
       print("viewWillAppear")
       //print("imagesSearchResults.count = \(imagesSearchResults.count)")
        currentImageIndex = 0
        if(searchTerm != ""){
            searchController.isActive = true
            self.searchController.searchBar.text = searchTerm
        }
        
        /*if(self.mode == "Top Image"){
            getImages()
        }
        */
    }
    
    func getImages() {
        //remove any added views (needed for table refresh
        
        print("get images")
       /* for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        imageArray = []
 */
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        var parameters = [String:AnyObject]()
        
       // if(self.mode == "Top Image"){
            //parameters = ["month": self.month as AnyObject, "year": self.year as AnyObject, "topImage": "1" as AnyObject, "cb":timeStamp as AnyObject]
       // }else{
        
        
        //parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "portfolio": self.portfolio as AnyObject, "fieldnotes": self.fieldNote as AnyObject, "cb":timeStamp as AnyObject]
       // }
         parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject]
        
        if(self.uploadedBy != "0"){
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "uploadedBy": self.uploadedBy as AnyObject]
        }
        
        if(self.portfolio == "1"){
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "portfolio": self.portfolio as AnyObject]
        }
        
        if(self.fieldNote == "1"){
             parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "fieldnotes": self.fieldNote as AnyObject]
        }
        
        if(self.task == "1"){
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "cb":timeStamp as AnyObject, "task": self.task as AnyObject]
        }
        
        
        
        
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/images.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("images response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.images = JSON(json)
                    self.parseJSON()
                    
                }
                
                self.indicator.dismissIndicator()
        }
    }
    
    
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
        
    }
    
    
    
    func layoutViews(){
        
        
        
        print("layoutViews collection")
        // Close Indicator
        indicator.dismissIndicator()
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        //self.likeView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        //var now:String!
        
        // if(self.mode != "Top Image"){
            // Initialize and perform a minimum configuration to the search controller.
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.placeholder = "Search Images"
            searchController.searchResultsUpdater = self
            searchController.delegate = self
            searchController.searchBar.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
            navigationItem.titleView = searchController.searchBar
       // }
        
        /*
        if(self.mode == "Top Image"){
            print("top image mode")
            //var topImageViewHeight:Int = 50
            //self.topImageView.frame = CGRect(x:0, y:layoutVars.navAndStatusBarHeight, width: self.view.frame.width, height: 100)
            
            
            
            
            
            
            imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: layoutVars.navAndStatusBarHeight + 50, width: self.view.frame.width, height: self.view.frame.height - (layoutVars.navAndStatusBarHeight + 50 + 50)), collectionViewLayout: layout)
            
            
            imageCollectionView?.contentInset = UIEdgeInsets(top: layoutVars.navAndStatusBarHeight + 50, left: 0.0, bottom: 0.0, right: 0.0)
            self.view.addSubview(imageCollectionView!)
            
            
            self.topImageView.backgroundColor = UIColor.lightGray
            self.topImageView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.topImageView)
            
            
            monthLbl.translatesAutoresizingMaskIntoConstraints = false
            self.topImageView.addSubview(monthLbl)
            monthLbl.text = "Month"
            
            
            
            
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            
            monthPickerView = MonthYearPickerView()
            
            
            
            self.monthTxtField = PaddedTextField()
            //self.monthTxtField.frame = CGRect(x:100, y:5, width: self.view.frame.width-100, height: 40)
            self.monthTxtField.returnKeyType = UIReturnKeyType.next
            self.monthTxtField.delegate = self
            self.monthTxtField.tag = 8
            self.monthTxtField.inputView = self.monthPickerView
            self.monthTxtField.attributedPlaceholder = NSAttributedString(string:"\(self.month!)/\(self.year!)",attributes:[NSForegroundColorAttributeName: layoutVars.buttonColor1])
            self.topImageView.addSubview(self.monthTxtField)
            
            
            
            
            let monthToolBar = UIToolbar()
            monthToolBar.barStyle = UIBarStyle.default
            monthToolBar.barTintColor = UIColor(hex:0x005100, op:1)
            monthToolBar.sizeToFit()
            let setMonthButton = UIBarButtonItem(title: "Set Month", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ImageCollectionViewController.handleMonthPicker))
            monthToolBar.setItems([spaceButton, setMonthButton], animated: false)
            monthToolBar.isUserInteractionEnabled = true
            monthTxtField.inputAccessoryView = monthToolBar
            
            
            
            
            let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40, "navBarHeight":layoutVars.navAndStatusBarHeight] as [String : Any]
            
            
            
            //auto layout group
            let viewsDictionary = [
                "topImageView":topImageView] as [String:Any]
            
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topImageView]|", options: [], metrics: nil, views: viewsDictionary))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[topImageView(50)]", options: [], metrics: sizeVals, views: viewsDictionary))
            
            //auto layout group
            let viewsDictionary2 = [
                "monthLbl":monthLbl, "monthTxtField":monthTxtField] as [String:Any]
            
            
            self.topImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[monthLbl]-[monthTxtField(160)]-|", options: [], metrics: nil, views: viewsDictionary2))
            
            self.topImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[monthLbl(40)]", options: [], metrics: sizeVals, views: viewsDictionary2))
            
            self.topImageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[monthTxtField(40)]", options: [], metrics: sizeVals, views: viewsDictionary2))
            
            
            
            
            
            
            


        }else{
 */
            imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: layoutVars.navAndStatusBarHeight, width: self.view.frame.width, height: self.view.frame.height - (layoutVars.navAndStatusBarHeight + 50)), collectionViewLayout: layout)
            
            
            imageCollectionView?.contentInset = UIEdgeInsets(top: layoutVars.navAndStatusBarHeight, left: 0.0, bottom: 0.0, right: 0.0)
            
            self.view.addSubview(imageCollectionView!)
       // }
        
        
        
        
        imageCollectionView?.dataSource = self
        imageCollectionView?.delegate = self
        imageCollectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView?.backgroundColor = UIColor.darkGray
        
        
        
        let refresher = UIRefreshControl()
        self.imageCollectionView!.alwaysBounceVertical = true
        
       
       refresher.addTarget(self, action: #selector(ImageCollectionViewController.loadData), for: .valueChanged)
        imageCollectionView!.addSubview(refresher)
        
        
        
        
        self.addImageBtn.addTarget(self, action: #selector(ImageCollectionViewController.addImage), for: UIControlEvents.touchUpInside)
        
        self.addImageBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width - 100, height: 50)
        self.addImageBtn.translatesAutoresizingMaskIntoConstraints = true
        self.addImageBtn.layer.borderColor = UIColor.white.cgColor
        self.addImageBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.addImageBtn)
        
        self.imageSettingsBtn.addTarget(self, action: #selector(ImageCollectionViewController.imageSettings), for: UIControlEvents.touchUpInside)
        
        self.imageSettingsBtn.frame = CGRect(x:self.view.frame.width - 50, y: self.view.frame.height - 50, width: 50, height: 50)
        self.imageSettingsBtn.translatesAutoresizingMaskIntoConstraints = true
        self.imageSettingsBtn.layer.borderColor = UIColor.white.cgColor
        self.imageSettingsBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.imageSettingsBtn)
        
        self.imageSettingsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        

        
        
        settingsIcon.backgroundColor = UIColor.clear
        settingsIcon.contentMode = .scaleAspectFill
        settingsIcon.frame = CGRect(x: 11, y: 11, width: 28, height: 28)
        
        //settingsIcon.image = settingsImg
        
        if(self.uploadedBy != "0" || self.portfolio != "0" || self.fieldNote != "0" || self.task != "0" || self.order != "ID DESC"){
            print("changes made")
            settingsIcon.image = settingsEditedImg
        }else{
            settingsIcon.image = settingsImg
        }

        
        
        self.imageSettingsBtn.addSubview(settingsIcon)
        
    }
    
    
    /*
    
    func handleMonthPicker()
    {
        //print("handle start picker")
        self.monthTxtField.resignFirstResponder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        
        let dateFormatterDB = DateFormatter()
        dateFormatterDB.dateFormat = "yyyy-MM-dd"
        
        
        //self.monthTxtField.text = "\(monthPickerView.month)/\(monthPickerView.year)"
        //startDate = dateFormatter.string(from: startPickerView.date)
       // startDateDB = dateFormatterDB.string(from: startPickerView.date)
        //getPerformance()
        self.month = "\(monthPickerView.month)"
        self.year = "\(monthPickerView.year)"
        getImages()
       
 
    }
    
    */
    
    
    
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
         if(shouldShowSearchResults == false){
            return self.imageArray.count
         }else{
            return self.imagesSearchResults.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("making cells")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        cell.activityView.startAnimating()
        cell.imageView.image = nil
        
         //print("name = \(self.imageArray)")
        
        if(shouldShowSearchResults == false){
            print("name = \(self.imageArray[indexPath.row].name!)")
           // cell.textLabel.text = " \(self.imageArray[indexPath.row].name!)"
            
            cell.textLabel.text = " \(self.imageArray[indexPath.row].customerName)"
            
            
            cell.image = self.imageArray[indexPath.row]
            cell.activityView.startAnimating()
            
            print("thumb = \(self.imageArray[indexPath.row].thumbPath!)")
            
            let imgURL:URL = URL(string: self.imageArray[indexPath.row].thumbPath!)!
            
            //print("imgURL = \(imgURL)")
            
            
            
            Nuke.loadImage(with: imgURL, into: cell.imageView){ [weak view] in
                //print("nuke loadImage")
                cell.imageView?.handle(response: $0, isFromMemoryCache: $1)
                cell.activityView.stopAnimating()
                
            }
            
            
            
            
        }else{
            cell.textLabel.text = " \(self.imagesSearchResults[indexPath.row].name!)"
            cell.image = self.imagesSearchResults[indexPath.row]
            cell.activityView.startAnimating()
            let imgURL:URL = URL(string: self.imagesSearchResults[indexPath.row].thumbPath!)!
            Nuke.loadImage(with: imgURL, into: cell.imageView){ [weak view] in
                cell.imageView?.handle(response: $0, isFromMemoryCache: $1)
                cell.activityView.stopAnimating()
            }

            
            
        }
        
        //print("view width = \(imageCollectionView?.frame.width)")
        //print("cell width = \(cell.frame.width)")
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
       // print("mode = \(self.mode)")
        
        imageDetailViewController = ImageDetailViewController(_image: currentCell.image,_saveURLString:"https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php")
        imageDetailViewController.imageFullViewController.delegate = self
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        imageDetailViewController.imageLikeDelegate = self
        
        
        if(searchController != nil){
            searchTerm = self.searchController.searchBar.text!
            imagesSearchResults2 = imagesSearchResults
            
            searchController.isActive = false
        }
        
        
        currentImageIndex = indexPath.row
        

    }
    
    /////////////// Search Methods   ///////////////////////
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResultsForSearchController \(searchController.searchBar.text)")
        filterSearchResults()
    }
    
    func filterSearchResults(){
        //print("filterSearchResults")
        
        self.imagesSearchResults = self.imageArray.filter({( aImage: Image) -> Bool in
            return ("\(aImage.name!)\(aImage.tags)".lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
        self.imageCollectionView?.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.imageCollectionView?.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchTerm = ""
        
        //print("searchBarCancelButtonClicked")
        shouldShowSearchResults = false
        self.imagesSearchResults = []
        self.imageCollectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //print("searchBarSearchButtonClicked")
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.imageCollectionView?.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
    }
    
    func willPresentSearchController(_ searchController: UISearchController){
        
        
    }
    
    
    func presentSearchController(searchController: UISearchController){
        
    }

    //refresh functions
    
    func loadData()
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

    
    
    
    func addImage(){
        print("Add Image")
        if(searchController != nil){
            searchController.isActive = false
        }
        
        
        let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        var selectedAssets = [DKAsset]()
        var selectedImages:[Image] = [Image]()

       
        multiPicker.showsCancelButton = true
        multiPicker.assetType = .allPhotos
        self.present(multiPicker, animated: true) {}
        
        
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            for i in 0..<assets.count
            {
                print("looping images")
                selectedAssets.append(assets[i])
                //print(self.selectedAssets)
                
                assets[i].fetchOriginalImage(true, completeBlock: { image, info in
               
                    
                    print("making image")
                    //let imageToAdd:Image = Image(_id: "0", _thumbPath: "", _rawPath: "", _name: "", _width: "200", _height: "200", _description: "", _customer: "0", _woID: "0", _dateAdded: "", _createdBy: self.appDelegate.loggedInEmployee?.ID, _type: "", _tags: "")
                    
                     let imageToAdd:Image = Image(_id: "0", _thumbPath: "", _mediumPath: "", _rawPath: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId), _type: "")
                    
                    imageToAdd.image = image
                    
                    
                   selectedImages.append(imageToAdd)
                
                })
            }
            
            //cache buster
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            let timeStamp = Int(timeInterval)

            print("making prep view")
            print("selectedimages count = \(selectedImages.count)")
            
            let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Gallery", _ID: "0", _images: selectedImages, _saveURLString: "https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php?cb=\(timeStamp)")
            
            
            print("url = https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php?cb=\(timeStamp)")
            
            print("self.selectedImages.count = \(selectedImages.count)")
            
            imageUploadPrepViewController.loadLinkList(_linkType: "customers", _loadScript: API.Router.customerList(["cb":timeStamp as AnyObject]))
            
            
            imageUploadPrepViewController.delegate = self
            
            self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
            

        }
        
        
    }
    
    
    func imageSettings(){
        print("image settings")
        
        let imageSettingsViewController = ImageSettingsViewController(_uploadedBy:self.uploadedBy,_portfolio: self.portfolio, _fieldNote: self.fieldNote, _task: self.task, _order:self.order)
        imageSettingsViewController.imageSettingsDelegate = self
        navigationController?.pushViewController(imageSettingsViewController, animated: false )
        
        
        
    }
    
    
    func getPrevNextImage(_next:Bool){
        //print("IN  getPrevNextImage currentImageIndex = \(currentImageIndex!)")
        if(shouldShowSearchResults == false){
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
        }else{
            if(_next == true){
                if(currentImageIndex + 1) > (self.imagesSearchResults2.count - 1){
                    currentImageIndex = 0
                    imageDetailViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }else{
                    currentImageIndex = currentImageIndex + 1
                    imageDetailViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.imagesSearchResults2.count - 1
                    imageDetailViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }else{
                    currentImageIndex = currentImageIndex - 1
                    imageDetailViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
            }
        }
        //print("OUT  getPrevNextImage currentImageIndex = \(currentImageIndex!)")
        
        if(shouldShowSearchResults == false){
            imageCollectionView?.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0),
                                              at: .top,
                                              animated: false)
        }
        

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
        
 
        //self.getImages()
        
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

        
        
    }
    
    func updateSettings(_uploadedBy:String,_portfolio:String, _fieldNote:String,_task:String,_order:String){
        print("update settings")
        print("_uploadedBy = \(_uploadedBy) _portfolio = \(_portfolio) _fieldNote = \(_fieldNote) _task = \(_task) _order = \(_order)")
        self.portfolio = _portfolio
        self.fieldNote = _fieldNote
        self.task = _task
        self.uploadedBy = _uploadedBy
        self.order = _order
        
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
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            //here you can do the logic for the cell size if phone is in landscape
            //print("landscape")
            portraitMode = false
            
        } else {
            //logic if not landscape
             //print("portrait")
            portraitMode = true
        }
        
        imageCollectionView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50)
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
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    func canRotate() -> Void {}
    
   

    
    
   
    
    
    
    
    
   
    
}
