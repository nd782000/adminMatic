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

/*
protocol ImageViewDelegate{
    func getPrevNextImage(_next:Bool)-> Image
    func refreshImages(_image:Image)
    }
 */

protocol ImageViewDelegate{
    func getPrevNextImage(_next:Bool)
    func refreshImages(_image:Image, _scoreAdjust:Int)
}



class ImageCollectionViewController: ViewControllerWithMenu, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, ImageViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate  {
    
    var indicator: SDevIndicator!
    var totalImages:Int!
    var images: JSON!
    var imageArray:[Image] = []
    var imagesSearchResults:[Image] = []
    var imagesSearchResults2:[Image] = []

    var shouldShowSearchResults:Bool = false
    var searchTerm:String = "" // used to retain search when leaving this view and having to deactivate search to enable device rotation - a real pain
    var searchController:UISearchController!
    var imageCollectionView: UICollectionView?
    var layoutVars:LayoutVars = LayoutVars()
    
    var addImageBtn:Button = Button(titleText: "Add Image")
    
    var currentImageIndex:Int!
    
    let picker = UIImagePickerController()
    var imagePicked:Bool = false
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
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
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        getImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ////print("viewWillAppear")
       // //print("imagesSearchResults.count = \(imagesSearchResults.count)")
        
        ////print("searchTerm = \(searchTerm)")
        
        currentImageIndex = 0
        
        if(searchTerm != ""){
            
            
            searchController.isActive = true
            //searchController.delegate = self
            
            self.searchController.searchBar.text = searchTerm
            //print("there are search results")
            
        }
    }
    
    func getImages() {
        //remove any added views (needed for table refresh
        
        //print("get images")
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject

        Alamofire.request(API.Router.images(["cb":timeStamp as AnyObject])).responseJSON(){ response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                //print("JSON: \(json)")
                self.images = JSON(json)
                self.parseJSON()
                
            }
        }
        
        
    }
    
    
    func parseJSON(){
        let jsonCount = self.images["images"].count
        self.totalImages = jsonCount
        //print("JSONcount: \(jsonCount)")
        
        let thumbBase:String = self.images["thumbBase"].stringValue
        let rawBase:String = self.images["rawBase"].stringValue
        
        for i in 0 ..< jsonCount {
            
            
            let thumbPath:String = "\(thumbBase)\(self.images["images"][i]["fileName"].stringValue)"
            let rawPath:String = "\(rawBase)\(self.images["images"][i]["fileName"].stringValue)"
                
            //create a item object
            let image = Image(_id: self.images["images"][i]["ID"].stringValue,_thumbPath: thumbPath,_rawPath: rawPath,_name: self.images["images"][i]["name"].stringValue,_width: self.images["images"][i]["width"].stringValue,_height: self.images["images"][i]["height"].stringValue,_description: self.images["images"][i]["description"].stringValue,_customer: self.images["images"][i]["customer"].stringValue,_dateAdded: self.images["images"][i]["dateAdded"].stringValue,_createdBy: self.images["images"][i]["createdByName"].stringValue,_type: self.images["images"][i]["type"].stringValue,_tags: self.images["images"][i]["tags"].stringValue)
            
            self.imageArray.append(image)
            
        }
        
        self.layoutViews()
        
    }
    
    
    
    func layoutViews(){
        
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
        
        
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50), collectionViewLayout: layout)
        imageCollectionView?.dataSource = self
        imageCollectionView?.delegate = self
        imageCollectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView?.backgroundColor = UIColor.darkGray
        self.view.addSubview(imageCollectionView!)
        
        
        let refresher = UIRefreshControl()
        self.imageCollectionView!.alwaysBounceVertical = true
        //refresher.tintColor = UIColor.redColor()
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
               // cell.imageView.han
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
         imageDetailViewController = ImageDetailViewController(_image: currentCell.image)
        imageDetailViewController.imageFullViewController.delegate = self
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        
        searchTerm = self.searchController.searchBar.text!
        imagesSearchResults2 = imagesSearchResults
        
        //searchController.delegate = nil
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
        //print("loadData")
        getImages()
        stopRefresher()         //Call this to stop refresher
    }
    
    func stopRefresher()
    {   //print("stopRefresher")
        refresher.endRefreshing()
    }

    
    
    
    
    
    
    func addImage(){
        //print("Add Image")
        searchController.isActive = false
         self.showActionSheet()
    }
    
    
    func showActionSheet() {
        //print("showActionSheet")
        
        
       // if self.presentedViewController == nil {
            
            
            let actionSheet = UIAlertController(title: "Upload an Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                //print("show cam 1")
                self.camera()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Library", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                self.library()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert:UIAlertAction!) -> Void in
            }))
            
            self.present(actionSheet, animated: true, completion: nil)
        
        /*
        }else{
            self.dismiss(animated: true, completion: {
                let actionSheet = UIAlertController(title: "Add Picture to Field Note", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                actionSheet.view.backgroundColor = UIColor.white
                actionSheet.view.layer.cornerRadius = 5;
                
                actionSheet.addAction(UIAlertAction(title: "Take New Picture", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                    //print("show cam 1")
                    self.camera()
                }))
                
                actionSheet.addAction(UIAlertAction(title: "From Camera Roll", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                    self.library()
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert:UIAlertAction!) -> Void in
                }))
                
                self.present(actionSheet, animated: true, completion: nil)
            })
            
        }*/
        
    }
    
    func camera()
    {
        //print("Camera")
        
        self.picker.sourceType = UIImagePickerControllerSourceType.camera
        self.picker.cameraCaptureMode = .photo
        self.picker.allowsEditing = true
        self.picker.delegate = self
        
        
        _ = [self .present(self.picker, animated: true , completion: nil)]
        
    }
    
    func library()
    {
        //print("photoLibrary")
        self.picker.delegate = self;
        self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        _ = [self .present(self.picker, animated: true , completion: nil)]
        
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print("didFinishPickingMediaWithInfo")
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            //print("image not nil")
            
            let imageUploadViewController:ImageUploadViewController = ImageUploadViewController(_image: (info[UIImagePickerControllerOriginalImage] as? UIImage)!)
            
            //self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            self.imagePicked = true
            
            imageUploadViewController.delegate = self
            
             navigationController?.pushViewController(imageUploadViewController, animated: false )
            
            
            /*
            self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            self.imagePicked = true
            self.imageEdit = true
            UIView.animate(withDuration: 0.75, animations: {() -> Void in
                self.drawButton.alpha = 1
                self.drawButton.isEnabled = true
            })
 */
        } else{
            //print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    //cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        if(searchTerm != ""){
            
            
            searchController.isActive = true
            //searchController.delegate = self
            
            self.searchController.searchBar.text = searchTerm
            //print("there are search results")
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    func getPrevNextImage(_next:Bool) -> Image{
        //print("getPrevNextImage currentImageIndex = \(currentImageIndex)")
        if(shouldShowSearchResults == false){
            if(_next == true){
                if(currentImageIndex + 1) > (self.imageArray.count - 1){
                    currentImageIndex = 0
                    return self.imageArray[currentImageIndex]
                }
                currentImageIndex = currentImageIndex + 1
                return self.imageArray[currentImageIndex]

            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.imageArray.count - 1
                    return self.imageArray[currentImageIndex]
                }
                currentImageIndex = currentImageIndex - 1
                return self.imageArray[currentImageIndex]
            }
        }else{
            if(_next == true){
                if(currentImageIndex + 1) > (self.imagesSearchResults2.count - 1){
                    currentImageIndex = 0
                    return self.imagesSearchResults2[currentImageIndex]
                }
                currentImageIndex = currentImageIndex + 1
                return self.imagesSearchResults2[currentImageIndex]
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.imagesSearchResults2.count - 1
                    return self.imagesSearchResults2[currentImageIndex]
                }
                currentImageIndex = currentImageIndex - 1
                return self.imagesSearchResults2[currentImageIndex]
            }        }
        
    }
 */
    
    
    
    func getPrevNextImage(_next:Bool){
        //print("IN  getPrevNextImage currentImageIndex = \(currentImageIndex!)")
        if(shouldShowSearchResults == false){
            if(_next == true){
                if(currentImageIndex + 1) > (self.imageArray.count - 1){
                    currentImageIndex = 0
                   // return self.imageArray[currentImageIndex]
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                    
                    
                }else{
                    currentImageIndex = currentImageIndex + 1
                    //return self.imageArray[currentImageIndex]
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.imageArray.count - 1
                    //return self.imageArray[currentImageIndex]
                    imageDetailViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }else{
                    currentImageIndex = currentImageIndex - 1
                    //return self.imageArray[currentImageIndex]
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
                   // return self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }else{
                    currentImageIndex = currentImageIndex + 1
                    //return self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.imagesSearchResults2.count - 1
                    //return self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    imageDetailViewController.imageFullViewController.image = self.imagesSearchResults2[currentImageIndex]
                    imageDetailViewController.imageFullViewController.layoutViews()
                }else{
                    currentImageIndex = currentImageIndex - 1
                    //return self.imagesSearchResults2[currentImageIndex]
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

    
    
    
    func refreshImages(_image:Image, _scoreAdjust:Int){
        //print("refreshImages")
        imageArray.insert(_image, at: 0)
        shouldShowSearchResults = false
        //imageCollectionView?.reloadData()
        
       
        
        //layout.sectionInset = UIEdgeInsets(top: layoutVars.navAndStatusBarHeight, left: 0, bottom: 50, right: 0)
        
        //imageCollectionView?.frame = CGRect(x: 0, y: layoutVars.navAndStatusBarHeight, width: self.view.frame.width, height: self.view.frame.height - layoutVars.navAndStatusBarHeight - 50)
        
        imageCollectionView?.reloadData()
        
        imageCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
        
        
        
         //layoutViews()
        
        //getImages()
        
        //[self.myCollectionVC.collectionView setContentInset:UIEdgeInsetsMake(topMargin, 0, 0, 0)]
        
       // imageCollectionView?.setNeedsUpdateConstraints()
        
        
        //self.hideProgressScreen()
        
        //add appPoints
        var points:Int = _scoreAdjust
        
        //print("points = \(points)")
        
        if(points > 0){
            self.appDelegate.showMessage(_message: "earned \(points) App Points!")
        }else if(points < 0){
            points = points * -1
            self.appDelegate.showMessage(_message: "lost \(points) App Points!")
            
        }

        
        
    }
    
    /*
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Your Processing
        //print("viewWillTransition")
        imageCollectionView?.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        imageCollectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50)
        //imageView.frame = CGRect(x:0, y:0, width:scrollView.frame.width, height:scrollView.frame.height)
    }
    */
    /*
    func rotated() {
        /*
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            //print("Landscape")
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            //print("Portrait")
        }
          imageCollectionView?.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        imageCollectionView?.reloadData()
 */
        
    }
*/
    
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
    
    
    
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageCollectionView?.reloadData()
    }
 */
    
}
