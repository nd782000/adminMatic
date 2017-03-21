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

class ImageCollectionViewController: ViewControllerWithMenu, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, ImageViewDelegate, UINavigationControllerDelegate  {
        
    var layoutVars:LayoutVars = LayoutVars()
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
    var addImageBtn:Button = Button(titleText: "Add Image")
    var currentImageIndex:Int!
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    var refresher:UIRefreshControl!
    
    init(){
        super.init(nibName:nil,bundle:nil)
        //  //println("init equipId = \(equipId) equipName = \(equipName)")
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
        getImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       print("viewWillAppear")
       // //print("imagesSearchResults.count = \(imagesSearchResults.count)")
        currentImageIndex = 0
        if(searchTerm != ""){
            searchController.isActive = true
            self.searchController.searchBar.text = searchTerm
        }
    }
    
    func getImages() {
        //remove any added views (needed for table refresh
        
        print("get images")
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)

        Alamofire.request(API.Router.images(["cb":timeStamp as AnyObject])).responseJSON(){ response in
            print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                print("JSON: \(json)")
                self.images = JSON(json)
                self.parseJSON()
                
            }
        }
        
        
    }
    
    
    func parseJSON(){
        let jsonCount = self.images["images"].count
        self.totalImages = jsonCount
        print("JSONcount: \(jsonCount)")
        
        let thumbBase:String = self.images["thumbBase"].stringValue
        let rawBase:String = self.images["rawBase"].stringValue
        
        for i in 0 ..< jsonCount {
            
            
            let thumbPath:String = "\(thumbBase)\(self.images["images"][i]["fileName"].stringValue)"
            let rawPath:String = "\(rawBase)\(self.images["images"][i]["fileName"].stringValue)"
                
            //create a item object
            print("create an image object \(i)")
            let image = Image(_id: self.images["images"][i]["ID"].stringValue,_thumbPath: thumbPath,_rawPath: rawPath,_name: self.images["images"][i]["name"].stringValue,_width: self.images["images"][i]["width"].stringValue,_height: self.images["images"][i]["height"].stringValue,_description: self.images["images"][i]["description"].stringValue,_customer: self.images["images"][i]["customer"].stringValue,_woID:"0",_dateAdded: self.images["images"][i]["dateAdded"].stringValue,_createdBy: self.images["images"][i]["createdByName"].stringValue,_type: self.images["images"][i]["type"].stringValue,_tags: self.images["images"][i]["tags"].stringValue)
            
            self.imageArray.append(image)
            
        }
        
        self.layoutViews()
        
    }
    
    
    
    func layoutViews(){
        
        print("layoutViews collection")
        // Close Indicator
        indicator.dismissIndicator()
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Images"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        
        
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: layoutVars.navAndStatusBarHeight, width: self.view.frame.width, height: self.view.frame.height - (layoutVars.navAndStatusBarHeight + 50)), collectionViewLayout: layout)
        imageCollectionView?.dataSource = self
        imageCollectionView?.delegate = self
        imageCollectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView?.backgroundColor = UIColor.darkGray
        self.view.addSubview(imageCollectionView!)
        
        
        let refresher = UIRefreshControl()
        self.imageCollectionView!.alwaysBounceVertical = true
        
       
       refresher.addTarget(self, action: #selector(ImageCollectionViewController.loadData), for: .valueChanged)
        imageCollectionView!.addSubview(refresher)
        
        
        
        
        self.addImageBtn.addTarget(self, action: #selector(ImageCollectionViewController.addImage), for: UIControlEvents.touchUpInside)
        
        self.addImageBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50)
        self.addImageBtn.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(self.addImageBtn)
        
        
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
            //print("name = \(self.imageArray[indexPath.row].name!)")
            cell.textLabel.text = " \(self.imageArray[indexPath.row].name!)"
            cell.image = self.imageArray[indexPath.row]
            cell.activityView.startAnimating()
            
            
            
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
        
        //print("name = \(currentCell.image.name)")
        
        
        
        
        
         imageDetailViewController = ImageDetailViewController(_image: currentCell.image,_saveURLString:"https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php")
        imageDetailViewController.imageFullViewController.delegate = self
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        
        searchTerm = self.searchController.searchBar.text!
        imagesSearchResults2 = imagesSearchResults
        
        searchController.isActive = false
        
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
            return ("\(aImage.name!)\(aImage.tags!)".lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
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
        print("loadData")
        getImages()
        stopRefresher()         //Call this to stop refresher
    }
    
    func stopRefresher()
    {   print("stopRefresher")
    }

    
    
    
    func addImage(){
        print("Add Image")
        searchController.isActive = false
        
        let multiPicker = DKImagePickerController()
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
                    let imageToAdd:Image = Image(_id: "0", _thumbPath: "", _rawPath: "", _name: "", _width: "200", _height: "200", _description: "", _customer: "0", _woID: "0", _dateAdded: "", _createdBy: self.appDelegate.loggedInEmployee?.ID, _type: "", _tags: "")
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

    
    
    
    //restores device to portrait mode when leaving
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    func canRotate() -> Void {}
    
    
   
    
}
