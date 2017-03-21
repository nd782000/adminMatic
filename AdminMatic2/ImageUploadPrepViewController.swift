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

protocol ImageUploadPrepDelegate {
    func scrollToCell(_indexPath:IndexPath)
    func updateDescription(_index:Int, _description:String)
    func uploadComplete(_images:[Image],_scoreAdjust:Int)
}

protocol ImageDrawingDelegate{
    func updateImage(_indexPath:IndexPath, _image:UIImage)
}




class ImageUploadPrepViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate, ImageUploadPrepDelegate, ImageDrawingDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var delegate:ImageViewDelegate!  // refreshing the list
    var indicator: SDevIndicator!
    var backButton:UIButton!
    
    
    //header view
    var groupImages:Bool = true
    var groupSwitch:UISwitch = UISwitch()
    var groupSwitchLbl:Label = Label()
    var groupNameView:UIView = UIView()
    
    
    var groupDescriptionTxt: UITextView = UITextView()
    var groupDescriptionPlaceHolder:String = "Group description..."
    
    
    var groupSearchBar:UISearchBar = UISearchBar()
    var groupResultsTableView:TableView = TableView()
    var groupSearchResults:[String] = []
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView!
    
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
    
    
    //data items
    var imageType:String! //example: task, fieldnote, custImage, equipmentImage
    var ID:String! // taskID or fieldNoteID
    var images:[Image] = [Image]()
    
    var linkType:String! //equipment link
    var saveURLString: String! //php file to save/update
    
    
    var imageEdit:Bool = false
    
    
    init(_imageType:String,_ID:String,_images:[Image], _saveURLString:String, _linkType:String = ""){
        super.init(nibName:nil,bundle:nil)
        
        print("ImmageUploadPrep init")
        self.imageType = _imageType
        self.ID = _ID
        self.images = _images
       
        self.linkType = _linkType
        self.saveURLString = _saveURLString
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        print("ImmageUploadPre viewDidLoad")
        title = "Upload Prep"
        
        
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
        indicator.dismissIndicator()
        
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
        
       
        self.groupNameView.layer.borderWidth = 1.0
        self.groupNameView.backgroundColor = UIColor.lightGray
        self.groupNameView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.groupNameView)
        
        groupSwitch.isOn = groupImages
        groupSwitch.translatesAutoresizingMaskIntoConstraints = false
        groupSwitch.addTarget(self, action: #selector(ImageUploadPrepViewController.switchValueDidChange(sender:)), for: .valueChanged)
        self.groupNameView.addSubview(groupSwitch)
        
        if(groupImages == true){
            groupSwitchLbl.text = "Grouped"
            self.imageCollectionView.backgroundColor = UIColor.lightGray
        }else{
            groupSwitchLbl.text = "Seperate"
             self.imageCollectionView.backgroundColor = UIColor.darkGray
        }
        
        groupSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
        self.groupNameView.addSubview(groupSwitchLbl)
        
        
        if(groupImages == true){
            
            self.groupDescriptionTxt.text = groupDescriptionPlaceHolder
            self.groupDescriptionTxt.textColor = UIColor.lightGray
            
            self.groupDescriptionTxt.translatesAutoresizingMaskIntoConstraints = false
            self.groupDescriptionTxt.delegate = self
            self.groupDescriptionTxt.font = layoutVars.smallFont
            self.groupDescriptionTxt.returnKeyType = UIReturnKeyType.done
            self.groupDescriptionTxt.layer.cornerRadius = 4
            self.groupDescriptionTxt.clipsToBounds = true
            self.groupDescriptionTxt.backgroundColor = layoutVars.backgroundLight
            self.groupDescriptionTxt.showsHorizontalScrollIndicator = false;
            self.groupNameView.addSubview(self.groupDescriptionTxt)
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
        
        self.submitBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.saveData), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.submitBtn)
        
        
        let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40, "navBarHeight":layoutVars.navAndStatusBarHeight] as [String : Any]
        
        //auto layout group
       let viewsDictionary = [
             "groupNameView":self.groupNameView, "imageCollection":self.imageCollectionView, "searchTable":self.groupResultsTableView, "submitBtn":self.submitBtn
            ] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[groupNameView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageCollection]-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchTable]-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        if(groupImages == true){
             self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(120)]-[imageCollection]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(120)]-[searchTable]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        }else{
             self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(50)]-[imageCollection]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBarHeight-[groupNameView(50)]-[searchTable]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        }
       
        let viewsDictionary2 = ["groupSwitch":self.groupSwitch, "groupSwitchLbl":self.groupSwitchLbl, "groupDescriptionTxt":self.groupDescriptionTxt,"searchBar":groupSearchBar] as [String:Any]
        
        
         if(groupImages == true){
            
             self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupSwitch(40)]-10-[groupSwitchLbl(70)]-10-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary2))
           
            self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupDescriptionTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
            
            self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitch(30)]-[groupDescriptionTxt(60)]", options: [], metrics: nil, views: viewsDictionary2))
             self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitchLbl(30)]", options: [], metrics: nil, views: viewsDictionary2))
            self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(30)]", options: [], metrics: nil, views: viewsDictionary2))
            
            
         }else{
            
            self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupSwitch(40)]-10-[groupSwitchLbl(70)]-10-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary2))
            
            self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitch(30)]", options: [], metrics: nil, views: viewsDictionary2))
            self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitchLbl(30)]", options: [], metrics: nil, views: viewsDictionary2))
             self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(30)]", options: [], metrics: nil, views: viewsDictionary2))
        }
    }
    
    
    
    
    /////////////// CollectionView Delegate Methods   ///////////////////////
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            let totalHeight: CGFloat = 230.0
            let totalWidth: CGFloat = (self.view.frame.width - 10)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        
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
        
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("making cells")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageUploadPrepCollectionViewCell
        
        cell.backgroundColor = UIColor.darkGray
        cell.imageData = images[indexPath.row]
        cell.layoutViews()
        cell.delegate = self
        cell.indexPath = indexPath
    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        draw(_indexPath: indexPath, _image: images[indexPath.row].image!)
    }

    
    func scrollToCell(_indexPath:IndexPath) {
        print("scroll to cell _indexPath = \(_indexPath.row)")
        
        //scrolls to cell
        self.imageCollectionView.scrollToItem(at:_indexPath, at: .top, animated: true)
       

    }
    
    func uploadComplete(_images:[Image],_scoreAdjust:Int){
        print("upload complete")
        
        delegate.refreshImages(_images: _images, _scoreAdjust: _scoreAdjust)
    }
    
    
    func updateDescription(_index:Int, _description:String){
        print("update description index: \(_index) _description: \(_description)")
        self.images[_index].description = _description
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
            if(imageType == "Gallery"){
                self.selectedID = currentCell.id
            }
            tableView.deselectRow(at: indexPath, animated: true)
            self.groupResultsTableView.alpha = 0.0
            groupSearchBar.text = currentCell.name
            groupSearchBar.resignFirstResponder()
        
        for image in images{
            image.customer = selectedID
        }
    }
    

    
/////////////// Search Delegate Methods   ///////////////////////

    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        print("search edit")
        print("searchText.characters.count = \(searchText.characters.count)")
        
        
        if (searchText.characters.count == 0) {
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

    func switchValueDidChange(sender:UISwitch!)
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
    
    
    func saveData(){
        print("Save Data")
        
        var groupDescriptionString:String
        
        if(self.groupDescriptionTxt.text == groupDescriptionPlaceHolder){
            groupDescriptionString = ""
        }else{
            groupDescriptionString = self.groupDescriptionTxt.text!
            
        }
        
        for image in images{
            image.name = self.imageType
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
        
        let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_groupImages: self.groupImages, _ID:self.ID, _imageType: "Gallery", _description: groupDescriptionString, _selectedID: self.selectedID, _woID:self.woID, _images: self.images, _saveURLString: self.saveURLString)
        imageUploadProgressViewController.uploadPrepDelegate = self
        self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
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
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.groupDescriptionTxt.text.isEmpty {
            self.groupDescriptionTxt.text = groupDescriptionPlaceHolder
            self.groupDescriptionTxt.textColor = UIColor.lightGray
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

    func updateImage(_indexPath:IndexPath, _image: UIImage) {
        images[_indexPath.row].image = _image
        self.imageCollectionView.reloadData()
    }
    

    func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
