//
//  ImageUploadProgressViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/20/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView
 
import Foundation
import UIKit
import Alamofire
//import AlamofireImage
import SwiftyJSON
//import Nuke


protocol ImageUploadProgressDelegate {
    func returnImage(_indexPath:IndexPath,_image:Image2?,_scoreAdjust:Int)
    
}


class ImageUploadProgressViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, ImageUploadProgressDelegate{
    
    var layoutVars:LayoutVars = LayoutVars()
    /////////////////////////////////
    //number of images to upload at once, must fit within table view
    let imageBatchQty:Int = 5
    /////////////////////////////////
    
    //data vars
    var groupImages:Bool!
    var imageType:String! //example: task, fieldnote, custImage, equipmentImage
    var groupDescription:String!
    var images:[Image2] = [Image2]()
    var uiImages:[UIImage] = [UIImage]()
    var imageBatchOffset:Int = 1
    var imagesBatch:[Image2] = [Image2]() //temp image array for uploading
    var uiImagesBatch:[UIImage] = [UIImage]()
    var i = 1//index of image being uploaded
    //var saveURLString: String = "https://www.atlanticlawnandgarden.com/cp/app/functions/new/image.php" //php file to save/update
    var uploadedImages:[Image2] = [Image2]() //upload successes that will go back to collectionView
    var scoreAdjust:Int = 0
    var uploadPrepDelegate:ImageUploadPrepDelegate!
    
    
    var employeeView:UIView!
    var employeeImageView:UIImageView = UIImageView()
    var employeeLabel:GreyLabel!
    var progressLabel:InfoLabel!
    var imageTableView:TableView = TableView()
    
   // var topImage:Bool!
    
    
    init(_imageType: String, _images: [Image2], _uiImages: [UIImage]){
        self.imageType = _imageType
        self.images = _images
        self.uiImages = _uiImages
        
        print("_images.count \(_images.count)")
        
        print("_uiImages.count \(_uiImages.count)")
        //self.topImage = _topImage
        super.init(nibName:nil,bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Uploading..."
        
        //custom back button
        /*
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(ImageUploadProgressViewController.cancel), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Cancel", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.cancel))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        navigationItem.rightBarButtonItem  = nil
        
        view.backgroundColor = layoutVars.backgroundColor
        self.layoutViews()
    }
    
    
    func layoutViews(){
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.employeeView = UIView()
        self.employeeView.backgroundColor = layoutVars.backgroundColor
        self.employeeView.translatesAutoresizingMaskIntoConstraints = false
        
        Alamofire.request("https://atlanticlawnandgarden.com/uploads/general/thumbs/"+(appDelegate.loggedInEmployee?.pic)!).responseImage { response in
            debugPrint(response)
            
            //print(response.request)
           // print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
                self.employeeImageView.image = image
            }
        }
        
        
        
        Alamofire.request("https://atlanticlawnandgarden.com/uploads/general/thumbs/"+(appDelegate.loggedInEmployee?.pic)!).responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.response!)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
                self.employeeImageView.image = image
                
                //self.activityView.stopAnimating()
                
            }
        }
        
        
        
        
        
        
        employeeImageView.contentMode = .scaleAspectFill
        employeeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.employeeView.addSubview(self.employeeImageView)
        
        self.employeeLabel = GreyLabel()
        self.employeeLabel?.font = layoutVars.buttonFont
        if(images.count == 1){
            self.employeeLabel?.text = "Uploading \(images.count) Photo by \(appDelegate.loggedInEmployee!.fname!) "
        }else{
            self.employeeLabel?.text = "Uploading \(images.count) Photos by \(appDelegate.loggedInEmployee!.fname!) "

        }
         
        self.employeeView?.addSubview(self.employeeLabel!)
        self.progressLabel = InfoLabel()
        self.employeeView?.addSubview(self.progressLabel!)
        safeContainer.addSubview(self.employeeView!)
    //gets first batch of images to upload
        getBatch()
        
        
        self.imageTableView.delegate  =  self
        self.imageTableView.dataSource = self
        self.imageTableView.register(ImageUploadProgressTableViewCell.self, forCellReuseIdentifier: "cell")
         self.imageTableView.alwaysBounceVertical = false
        
        safeContainer.addSubview(self.imageTableView)
        //auto layout group
        let viewsDictionary = ["employeeView":self.employeeView,
            "tableView":self.imageTableView
            ]  as [String : Any]
        
        let sizeVals = ["fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth ,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - 10]  as [String : Any]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[employeeView]|", options: [], metrics: sizeVals, views: viewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[employeeView(80)][tableView]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        let viewsDictionary2 = ["employeePic":self.employeeImageView,
                               "employeeLbl":self.employeeLabel,
                               "progressLbl":self.progressLabel
            ]  as [String : Any]
        
        self.employeeView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[employeePic(60)]-10-[employeeLbl]-10-|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.employeeView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[employeePic(60)]-10-[progressLbl]-10-|", options: [], metrics: sizeVals, views: viewsDictionary2))

        self.employeeView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[employeePic(60)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.employeeView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[employeeLbl(30)]-[progressLbl(25)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary2))
        
        
    }
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    func getBatch(){
        print("get batch")
        imagesBatch = []
        uiImagesBatch = []
        
        if((self.imageBatchOffset * self.imageBatchQty) < self.images.count){
            self.progressLabel?.text = "loading image \(self.i) - \((self.imageBatchOffset * self.imageBatchQty)) of \(self.images.count)"
        }else{
            self.progressLabel?.text = "loading image \(self.i) - \(self.images.count) of \(self.images.count)"
        }
        
        print("self.imageBatchOffset = \(self.imageBatchOffset)")
        print("(self.imageBatchOffset * self.imageBatchQty) = \((self.imageBatchOffset * self.imageBatchQty))")
        for index in self.i...(self.imageBatchOffset * self.imageBatchQty){
            print("adding index \(index) to batch")
            if((images.count + 1) > index){
                imagesBatch.append(images[index-1])
                uiImagesBatch.append(uiImages[index-1])
            }
           
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.imagesBatch.count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = imageTableView.dequeueReusableCell(withIdentifier: "cell") as! ImageUploadProgressTableViewCell
            imageTableView.rowHeight = 60.0
            cell.imageData = self.imagesBatch[indexPath.row]
            cell.uiImage = self.uiImagesBatch[indexPath.row]
            cell.indexPath = indexPath
            //cell.topImage = self.topImage
            cell.layoutViews()
            cell.upload()
            cell.uploadDelegate = self
        return cell
    }
    
    
    
    func returnImage(_indexPath:IndexPath,_image:Image2?, _scoreAdjust:Int){
        print("return image i = \(i)")
        if(_image != nil){
            self.uploadedImages.append(_image!)
            self.scoreAdjust += _scoreAdjust
            print("scoreAdjust = \(scoreAdjust)")
        }
         i += 1
        
        if(i > (imageBatchQty * imageBatchOffset)){
            self.imageBatchOffset += 1
            getBatch()
            imageTableView.reloadData()
        }
        
        
        if(i > self.images.count){
            self.uploadPrepDelegate.uploadComplete(_images: self.uploadedImages, _scoreAdjust: self.scoreAdjust)
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: false)
            i = 1

        }

    }
    
    @objc func cancel(){
        
        
        let alertController = UIAlertController(title: "All uploads didn't Finish", message: "Leave this page?", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("Yes")
            self.uploadPrepDelegate.uploadComplete(_images: self.uploadedImages, _scoreAdjust: self.scoreAdjust)
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: false)
            self.i = 1

        }
        
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            print("No")
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        
        self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
