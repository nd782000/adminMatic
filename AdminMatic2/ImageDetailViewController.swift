//
//  ImageDetailViewController.swift
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


class ImageDetailViewController: UIViewController, UIDocumentInteractionControllerDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var delegate:ImageViewDelegate!
    var imageLikeDelegate:ImageLikeDelegate!
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    var image:Image!
    var backgroundImageView:UIImageView!
    
    var blurEffect:UIBlurEffect!
    var blurredEffectView:UIVisualEffectView!
    
    var imageView:UIImageView!
    var activityView:UIActivityIndicatorView!
    
    var textView:UIView!
    
    var likeBtn:Button = Button(titleText: "")
    var likesImageView:UIImageView = UIImageView()
    var likesBtn:Button!
    
   // var liked = "0
    //var likes = 0

    //var createdByLbl:Label!
    //var customerLbl:Label!
    var customerBtn:Button!
    //var dateAddedLbl:Label!
    var descriptionLbl:UITextView!
    var tagsLbl:Label!
    
    
    
    
    //var saveURLString:String!
    
    var ID:String //elementID to possibly edit
    
   // var editButton:Button = Button()
    
    
    var viewsDictionary:[String:Any] = [:]
    var viewsDictionary2:[String:Any] = [:]
    var viewsDictionary3:[String:Any] = [:]
    
    
    
    var imageFullViewController:ImageFullViewController!
    
   // var mode:String = ""
    
    //var likesView:UIView = UIView()
    
    /*
    var plusVoteBtn:Button = Button(titleText: "+")
    var minusVoteBtn:Button = Button(titleText: "-")
    var myVotesValueLbl:Label = Label()
    var totalVotesLbl:Label = Label()
    var totalVotesValueLbl:Label = Label()
    */
    
    var documentController: UIDocumentInteractionController!
    
    
    init(_image:Image, _ID:String = "0"){
        
        self.image = _image
        //self.mode = _mode
        self.ID = _ID
        
        self.imageFullViewController = ImageFullViewController(_image: _image)
        
        super.init(nibName:nil,bundle:nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.darkGray
        
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ImageDetailViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        self.layoutViews()
    }
    
    func layoutViews(){
    
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        if(self.textView != nil){
            self.textView.subviews.forEach({ $0.removeFromSuperview() })
        }
       // if(self.likesView != nil){
          //  self.likesView.subviews.forEach({ $0.removeFromSuperview() })
       // }
        if(self.backgroundImageView != nil){
            self.backgroundImageView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        //if(self.mode == "Top Image"){
           // print("detail view for Top Image")
        //}
        
        
        
        
        title = self.image.name
        
        self.backgroundImageView = UIImageView()
        
        self.backgroundImageView.clipsToBounds = true
        self.backgroundImageView.contentMode = UIViewContentMode.scaleAspectFill
        self.backgroundImageView.alpha = 0.5
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.isUserInteractionEnabled = false
        self.backgroundImageView.image = nil
        
        self.blurEffect = UIBlurEffect(style: .dark)
        self.blurredEffectView = UIVisualEffectView(effect: blurEffect)
        
        
        self.imageView = UIImageView()
        
        
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.isUserInteractionEnabled = true
        self.imageView.image = nil
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ImageDetailViewController.showFullScreenImage))
        self.imageView.addGestureRecognizer(tap)
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ImageDetailViewController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.imageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ImageDetailViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.imageView.addGestureRecognizer(swipeLeft)
        
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        
        
        
        self.textView = UIView()
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.backgroundColor = UIColor(hex: 0x005100, op: 0.6)
        
        self.likeBtn = Button(titleText: "")
        self.likeBtn.backgroundColor = UIColor.clear
        
        if(self.image.liked == "0"){
            self.likesImageView.image = UIImage(named:"unLiked.png")
        }else{
            self.likesImageView.image = UIImage(named:"liked.png")
        }
        
        likesImageView.contentMode = .scaleAspectFill
        likesImageView.translatesAutoresizingMaskIntoConstraints = false
        self.likeBtn.addTarget(self, action: #selector(ImageDetailViewController.handleLike), for: UIControlEvents.touchUpInside)
        
      
        /*
        self.likesBtn.text = "x\(self.image.likes)"
        self.likesBtn.layer.opacity = 1.0
        self.likesBtn.textColor = UIColor(hex: 0xffffff, op: 1.0)
        */
        
        self.likesBtn = Button()
        self.likesBtn.translatesAutoresizingMaskIntoConstraints = false
        self.likesBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.likesBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.likesBtn.backgroundColor = UIColor.clear
        self.likesBtn.titleLabel?.textColor = UIColor.white
        
        //self.likesBtn.setTitle("x\(self.image.likes) Likes", for: UIControlState.normal)
        
        if self.image.likes == "1"{
            self.likesBtn.setTitle("x\(self.image.likes) Like", for: UIControlState.normal)
        }else{
            self.likesBtn.setTitle("x\(self.image.likes) Likes", for: UIControlState.normal)
        }
        
        self.likesBtn.addTarget(self, action: #selector(ImageDetailViewController.showLikesList), for: UIControlEvents.touchUpInside)
        
        if self.image.likes == "0"{
            self.likesBtn.isEnabled = false
        }
        
        
        
        self.customerBtn = Button()
        self.customerBtn.translatesAutoresizingMaskIntoConstraints = false
        self.customerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        self.customerBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.customerBtn.backgroundColor = UIColor.clear
        self.customerBtn.titleLabel?.textColor = UIColor.white
        
        self.customerBtn.setTitle(image.customerName, for: UIControlState.normal)
        self.customerBtn.addTarget(self, action: #selector(ImageDetailViewController.showCustomerView), for: UIControlEvents.touchUpInside)
        
        
        //self.customerView.addSubview(self.allContactsBtn)
        
        
        
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        let date = dateFormatter.date(from: self.image.dateAdded)!
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MM/dd/yyyy"

            
        let addedByDate = shortDateFormatter.string(from: date)
        
        
        //self.dateAddedLbl = Label(text:  "\(addedByDate)")
       // self.dateAddedLbl.textAlignment = NSTextAlignment.right
       
        //self.dateAddedLbl.textColor = UIColor.white
        //self.textView.addSubview(self.dateAddedLbl)
        
        self.descriptionLbl = UITextView()
        self.descriptionLbl.text = "Uploaded by \(self.image.createdBy!) on \(addedByDate) - \(self.image.description!)"

        //self.descriptionLbl.text = "\(self.image.customerName)     \(self.image.description!)"
        self.descriptionLbl.backgroundColor = UIColor(hex: 0xffffff, op: 0.1)
        self.descriptionLbl.layer.cornerRadius = 4.0
        self.descriptionLbl.textColor = UIColor.white
        self.descriptionLbl.font = layoutVars.textFieldFont
        self.descriptionLbl.isEditable = false
        
        self.descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.tagsLbl = Label(text: self.image.tags)
        self.tagsLbl.textColor = UIColor.white

        activityView.startAnimating()
        
         let imgUrl = URL(string: image.mediumPath)
        
        print("image url = \(image.mediumPath)")
        
        Nuke.loadImage(with: imgUrl!, into: imageView){
            self.imageView?.handle(response: $0, isFromMemoryCache: $1)
            self.backgroundImageView.image = self.imageView.image
            self.activityView.stopAnimating()
            let shareBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(ImageDetailViewController.share))
            self.navigationItem.rightBarButtonItem = shareBtn
            
            
        }
            self.blurredEffectView.frame = self.view.bounds
            self.backgroundImageView.addSubview(self.blurredEffectView)
        
       
        
        
        
        
        
        
        
        viewsDictionary = [
            "backgroundImageView":self.backgroundImageView, "imageView":self.imageView, "textView":self.textView
            ] as [String:Any]
        
        viewsDictionary2 = ["likeBtn":self.likeBtn, "likesBtn":self.likesBtn, "customerLbl":self.customerBtn, "descriptionLbl":self.descriptionLbl, "tagsLbl":self.tagsLbl
            ] as [String:Any]
        viewsDictionary3 = ["likesImage":self.likesImageView] as [String:Any]
        
        setUpViews()
        
        
    }
    
    @objc func showCustomerView(){
        print("customer = \(image.customer)")
        
        
        
        let actionSheet = UIAlertController(title: "Customer Option", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.view.backgroundColor = UIColor.white
        actionSheet.view.layer.cornerRadius = 5;
        
        
        actionSheet.addAction(UIAlertAction(title: "Customer View", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            //print("show cam 1")
            
            if(self.image.customer != "0"){
                let customerViewController = CustomerViewController(_customerID: self.image.customer, _customerName: self.image.customerName, _imageView: true)
                //let customerViewController = CustomerViewController(_customerID: image.customer,_customerName: image.customerName)
                self.navigationController?.pushViewController(customerViewController, animated: false )
                //customerViewController.showImages()
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Customer Images", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.delegate.showCustomerImages(_customer: self.image.customer)
            self.goBack()
          
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
    
    
    @objc func showLikesList(){
        print("show likes list w/ ID = \(image.ID)")
        let imageLikesListViewController = ImageEmployeeLikesListViewController(_image: self.image)
        self.navigationController?.pushViewController(imageLikesListViewController, animated: false )
    }
    
    
    
    
    
    @objc func showFullScreenImage(_ sender: UITapGestureRecognizer){
        
        
        
        navigationController?.pushViewController(imageFullViewController, animated: false )
    }
    
    
    @objc func swiped(_ gesture: UIGestureRecognizer){
        //print("swiped")
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                //print("right swipe")
                _ = delegate.getPrevNextImage(_next: false)
            case UISwipeGestureRecognizerDirection.left:
                //print("left swipe")
                _ = delegate.getPrevNextImage(_next: true)
            default:
                print("other swipe")
            }
        }
    }
    
    @objc func share() {
        //print("share")
        if self.presentedViewController == nil {
            let activity = UIActivityViewController(activityItems: [self.imageView.image!], applicationActivities: nil)
            present(activity, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: {
                let activity = UIActivityViewController(activityItems: [self.image!], applicationActivities: nil)
                self.present(activity, animated: true, completion: nil)
            })
        }
    }
    
    
    
    
    
    func canRotate() -> Void {}
    
    
    
        
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
       
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("rotate view")
        
       setUpViews()
    
    }
    
    
    
    func setUpViews(){
        
        
        print("set up views")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
       // _ = ["navHeight":self.layoutVars.navAndStatusBarHeight, "landscapeNavHeight":self.layoutVars.navAndStatusBarHeight - self.layoutVars.statusBarHeight] as [String : Any]
        
        print("navHeight = \(self.layoutVars.navAndStatusBarHeight)  statusBarHeight = \(self.layoutVars.statusBarHeight) ")
        
        if(self.textView != nil){
            self.textView.subviews.forEach({ $0.removeFromSuperview() })
        }
        //if(self.likesView != nil){
           // self.likesView.subviews.forEach({ $0.removeFromSuperview() })
       // }
        
    
        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.imageView)
        self.view.addSubview(activityView)
        self.view.addSubview(self.textView)
        
        self.textView.addSubview(self.likeBtn)
        
        
        self.textView.addSubview(self.likesBtn)
       // self.textView.addSubview(self.createdByLbl)
        //self.textView.addSubview(self.customerLbl)
        self.textView.addSubview(self.customerBtn)
        
        self.likeBtn.addSubview(self.likesImageView)
        
       




        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[textView]|", options: [], metrics: nil, views: viewsDictionary))
       // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[likesView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        
        
       
        

        
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            //here you can do the logic for the cell size if phone is in landscape
            print("landscape")
            
          
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[textView(40)]|", options: [], metrics: nil, views: viewsDictionary))
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likeBtn(30)][likesBtn(80)]-[customerLbl]-|", options: [NSLayoutFormatOptions.alignAllCenterY], metrics: nil, views: viewsDictionary2))
            
            
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likeBtn(30)]", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likesBtn(30)]", options: [], metrics: nil, views: viewsDictionary2))
            
            
        } else {
            //logic if not landscape
            print("portrait")
            
            
            self.textView.addSubview(self.descriptionLbl)
            
            self.textView.addSubview(self.tagsLbl)
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[textView(150)]|", options: [], metrics: nil, views: viewsDictionary))
            
            
          
            
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likeBtn(30)][likesBtn(80)]-[customerLbl]-|", options: [NSLayoutFormatOptions.alignAllCenterY], metrics: nil, views: viewsDictionary2))
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likeBtn(30)]-[descriptionLbl]-[tagsLbl(25)]-|", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likeBtn(30)]-[descriptionLbl]-|", options: [], metrics: nil, views: viewsDictionary2))

            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tagsLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            
            
        }
        
        
        self.likeBtn.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[likesImage(30)]", options: [], metrics: nil, views: viewsDictionary3))
        
        
        
        self.likeBtn.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[likesImage(30)]", options: [], metrics: nil, views: viewsDictionary3))
        
        
        
        
        
       
        
        self.blurredEffectView.frame = self.view.bounds
        
    }
    
    
   
    
    
    @objc func handleLike(){
        print("handle Like")
        
        indicator = SDevIndicator.generate(self.view)!
        let parameters:[String:String]
        parameters = ["empID":self.appDelegate.loggedInEmployee?.ID, "imageID":self.image.ID] as! [String : String]
        
        
        if(self.image.liked == "0"){
            self.image.liked = "1"
            self.likesImageView.image = UIImage(named:"liked.png")
            
           
            
            
            
            
            print("parameters = \(parameters)")
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/new/like.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("images response = \(response)")
                }
                
                .responseJSON(){
                    response in
                    
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        let returnJSON = JSON(json)
                        self.image.likes = returnJSON["newLikes"].stringValue
                        //self.likesBtn.text = "x\(self.image.likes)"
                        if self.image.likes == "1"{
                            self.likesBtn.setTitle("x\(self.image.likes) Like", for: UIControlState.normal)
                        }else{
                            self.likesBtn.setTitle("x\(self.image.likes) Likes", for: UIControlState.normal)
                        }
                        self.imageLikeDelegate.updateLikes(_index: self.image.index, _liked: self.image.liked, _likes: returnJSON["newLikes"].stringValue)
                        
                    }
                    
                    self.indicator.dismissIndicator()
                    
                    if self.image.likes == "0"{
                        self.likesBtn.isEnabled = false
                    }else{
                        self.likesBtn.isEnabled = true
                    }
            }
            
            
            
            
            
            
            
            
            
            
           
 
            
        }else{
            self.image.liked = "0"
            self.likesImageView.image = UIImage(named:"unLiked.png")
            
            
            
            
            
            layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/delete/like.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    print("images response = \(response)")
                }
                
                .responseJSON(){
                    response in
                    
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        let returnJSON = JSON(json)
                        self.image.likes = returnJSON["newLikes"].stringValue
                        //self.likesBtn.text = "x\(self.image.likes)"
                        //self.likesBtn.setTitle("x\(self.image.likes) Likes", for: UIControlState.normal)
                        if self.image.likes == "1"{
                            self.likesBtn.setTitle("x\(self.image.likes) Like", for: UIControlState.normal)
                        }else{
                            self.likesBtn.setTitle("x\(self.image.likes) Likes", for: UIControlState.normal)
                        }
                        
                        self.imageLikeDelegate.updateLikes(_index: self.image.index, _liked: self.image.liked, _likes: returnJSON["newLikes"].stringValue)
                        
                    }
                    
                    self.indicator.dismissIndicator()
                    
                    if self.image.likes == "0"{
                        self.likesBtn.isEnabled = false
                    }else{
                        self.likesBtn.isEnabled = true
                    }
            }

            
            
            
            
           
            
            
        }
        
        
        
        
    }
    
    
    /*
    //instagram sharing
    
    func shareInstagram(_ sender: Any) {
        
        DispatchQueue.main.async {
            
            //Share To Instagram:
            let instagramURL = URL(string: "instagram://app")
            if UIApplication.shared.canOpenURL(instagramURL!) {
                
                let imageData = UIImageJPEGRepresentation(self.image.image!, 100)
                let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
                
                do {
                    try imageData?.write(to: URL(fileURLWithPath: writePath), options: .atomic)
                } catch {
                    print(error)
                }
                
                let fileURL = URL(fileURLWithPath: writePath)
                self.documentController = UIDocumentInteractionController(url: fileURL)
                self.documentController.delegate = self
                self.documentController.uti = "com.instagram.exlusivegram"
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    self.documentController.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
                } else {
                   // self.documentController.presentOpenInMenu(from: self.IGBarButton, animated: true)
                }
            } else {
                print(" Instagram is not installed ")
            }
        }
    }

*/
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

