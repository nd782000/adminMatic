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


 
class ImageDetailViewController: UIViewController, UIDocumentInteractionControllerDelegate, UIScrollViewDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var delegate:ImageViewDelegate!
    var imageLikeDelegate:ImageLikeDelegate!
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    var image:Image2!
    var backgroundImageView:UIImageView!
    var scrollView:UIScrollView=UIScrollView()
    var blurEffect:UIBlurEffect!
    var blurredEffectView:UIVisualEffectView!
    
    var imageView:UIImageView!
    var activityView:UIActivityIndicatorView!
    
    var textView:UIView!
    
    var likeBtn:Button = Button(titleText: "")
    var likesImageView:UIImageView = UIImageView()
    var likesBtn:Button!
    
   
    var customerBtn:Button!
    var descriptionLbl:UITextView!
    var tagsLbl:Label!
    
    
    
    
    //var saveURLString:String!
    
    var ID:String //elementID to possibly edit
    
   // var editButton:Button = Button()
    
    
    var viewsDictionary:[String:Any] = [:]
    var viewsDictionary2:[String:Any] = [:]
    var viewsDictionary3:[String:Any] = [:]
    
    
    
    //var imageFullViewController:ImageFullViewController!
    
   
    
    var documentController: UIDocumentInteractionController!
    
    var UIHidden:Bool = false
    
    
    init(_image:Image2, _ID:String = "0"){
        
        self.image = _image
        //self.mode = _mode
        self.ID = _ID
        
        //self.imageFullViewController = ImageFullViewController(_image: _image)
        
        super.init(nibName:nil,bundle:nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.darkGray
        
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        self.layoutViews()
    }
    
    func layoutViews(){
    
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.scrollView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        if(self.textView != nil){
            self.textView.subviews.forEach({ $0.removeFromSuperview() })
        }
       
        if(self.backgroundImageView != nil){
            self.backgroundImageView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
       
        //navigationController?.hidesBarsOnTap = true
        
        title = self.image.name
        
        self.backgroundImageView = UIImageView()
        
        self.backgroundImageView.clipsToBounds = true
        self.backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.backgroundImageView.alpha = 0.5
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.isUserInteractionEnabled = false
        self.backgroundImageView.image = nil
        
        self.blurEffect = UIBlurEffect(style: .dark)
        self.blurredEffectView = UIVisualEffectView(effect: blurEffect)
        
        
        
        scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        
        
        scrollView.minimumZoomScale=1
        scrollView.maximumZoomScale=3
        scrollView.bounces=false
        scrollView.delegate=self
        scrollView.backgroundColor = UIColor.darkGray
        self.view.addSubview(scrollView)
        
        
        
        self.imageView = UIImageView()
        
        
       
        
        imageView.frame = CGRect(x:0, y:0, width:scrollView.frame.width, height:scrollView.frame.height)
        
        
        
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        
        
        
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ImageDetailViewController.hideUI))
        self.imageView.addGestureRecognizer(tap)
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ImageDetailViewController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.imageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ImageDetailViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.imageView.addGestureRecognizer(swipeLeft)
        
        
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        
        
        
        self.textView = UIView()
        self.textView.frame = CGRect(x:0, y:(layoutVars.fullHeight - 150), width:scrollView.frame.width, height:150)
        //self.textView.translatesAutoresizingMaskIntoConstraints = false
        //self.textView.backgroundColor = UIColor(hex: 0x005100, op: 0.6)
        
        self.textView.backgroundColor = layoutVars.backgroundColor
        
        
        
        imageView.backgroundColor = .black
        //imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        
        
        
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        
        self.likeBtn = Button(titleText: "")
        self.likeBtn.backgroundColor = UIColor.clear
        //if self.image.liked != nil{
            if(self.image.liked == "0"){
                self.likesImageView.image = UIImage(named:"unLiked.png")
            }else{
                self.likesImageView.image = UIImage(named:"liked.png")
            }
       // }
        
        
        likesImageView.contentMode = .scaleAspectFill
        likesImageView.translatesAutoresizingMaskIntoConstraints = false
        self.likeBtn.addTarget(self, action: #selector(ImageDetailViewController.handleLike), for: UIControl.Event.touchUpInside)
        
      
        /*
        self.likesBtn.text = "x\(self.image.likes)"
        self.likesBtn.layer.opacity = 1.0
        self.likesBtn.textColor = UIColor(hex: 0xffffff, op: 1.0)
        */
        
        self.likesBtn = Button()
        self.likesBtn.translatesAutoresizingMaskIntoConstraints = false
        self.likesBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.likesBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.likesBtn.backgroundColor = UIColor.clear
       
        
        //self.likesBtn.setTitle("x\(self.image.likes) Likes", for: UIControlState.normal)
        
        if self.image.likes == "1"{
            self.likesBtn.setTitle("x\(self.image.likes!) Like", for: UIControl.State.normal)
        }else{
            self.likesBtn.setTitle("x\(self.image.likes!) Likes", for: UIControl.State.normal)
        }
        // self.likesBtn.titleLabel?.textColor = layoutVars.buttonColor1
        self.likesBtn.setTitleColor(layoutVars.buttonColor1, for: UIControl.State())
        
        self.likesBtn.addTarget(self, action: #selector(ImageDetailViewController.showLikesList), for: UIControl.Event.touchUpInside)
        
        if self.image.likes == "0"{
            self.likesBtn.isEnabled = false
        }
        
        
        
        self.customerBtn = Button()
        self.customerBtn.translatesAutoresizingMaskIntoConstraints = false
        self.customerBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        self.customerBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.customerBtn.backgroundColor = UIColor.clear
        
        //if image.custName != nil{
            self.customerBtn.setTitle(image.custName, for: UIControl.State.normal)

       // }else{
           // self.customerBtn.setTitle("Unassigned", for: UIControl.State.normal)

       // }
        //self.customerBtn.titleLabel?.textColor = layoutVars.buttonColor1
        self.customerBtn.setTitleColor(layoutVars.buttonColor1, for: UIControl.State())

        self.customerBtn.addTarget(self, action: #selector(ImageDetailViewController.showCustomerView), for: UIControl.Event.touchUpInside)
        
        
        
        
        
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.descriptionLbl = UITextView()
       if self.image.dateAdded != ""{
            let date = dateFormatter.date(from: self.image.dateAdded)!
        
            let shortDateFormatter = DateFormatter()
            shortDateFormatter.dateFormat = "MM/dd/yyyy"

            
            let addedByDate = shortDateFormatter.string(from: date)
        
        self.descriptionLbl.text = "Uploaded by \(self.image.createdBy!) on \(addedByDate) - \(self.image.description)"
        }else{
           // textView.isHidden = true
       }

        //self.descriptionLbl.text = "\(self.image.customerName)     \(self.image.description!)"
        self.descriptionLbl.backgroundColor = UIColor(hex: 0xffffff, op: 0.1)
        self.descriptionLbl.layer.cornerRadius = 4.0
        self.descriptionLbl.textColor = layoutVars.buttonColor1
        self.descriptionLbl.font = layoutVars.textFieldFont
        self.descriptionLbl.isEditable = false
        
        self.descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.tagsLbl = Label(text: self.image.tags)
        self.tagsLbl.textColor = UIColor.white

        activityView.startAnimating()
        
        
        
        
        Alamofire.request(image.mediumPath!).responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.response!)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                //self.imageFullViewController = ImageFullViewController(_image: //self.equipment.image)
                // cell.imageView.image = image
               // self.equipmentImage.image = image
                
                self.imageView.image = image
                self.backgroundImageView.image = self.imageView.image
                self.activityView.stopAnimating()
                
                
                //let shareBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(ImageDetailViewController.share))
                
                let shareBtn = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(ImageDetailViewController.share))
                self.navigationItem.rightBarButtonItem = shareBtn
                
            }
        }
        
        
       
        
            self.blurredEffectView.frame = self.view.bounds
            self.backgroundImageView.addSubview(self.blurredEffectView)
        
       
        
        setZoomScale()
        setupGestureRecognizer()
        
        
        
        
        
        viewsDictionary = [
            "backgroundImageView":self.backgroundImageView
            ] as [String:Any]
        
        viewsDictionary2 = ["likeBtn":self.likeBtn, "likesBtn":self.likesBtn, "customerLbl":self.customerBtn, "descriptionLbl":self.descriptionLbl, "tagsLbl":self.tagsLbl
            ] as [String:Any]
        viewsDictionary3 = ["likesImage":self.likesImageView] as [String:Any]
        
        setUpViews()
        
        
    }
    
    
    //Scroll Methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("viewForZooming")
        // self.navigationController?.isNavigationBarHidden = true
        return self.imageView
        
    }
    
   
    func setZoomScale() {
        print("setZoomScale")
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("scrollViewDidZoom")
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setupGestureRecognizer() {
        print("setupGestureRecognizer")
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc func handleDoubleTap() {
        print("handleDoubleTap")
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    
    
    
    
    @objc func showCustomerView(){
        print("customer = \(image.customer)")
        
        if(self.image.customer != "0"){
        
            let actionSheet = UIAlertController(title: "Customer Option", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            
            actionSheet.addAction(UIAlertAction(title: "Customer View", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                //print("show cam 1")
                
                
                let customerViewController = CustomerViewController(_customerID: self.image.customer!, _customerName: self.image.custName!, _imageView: true)
                    //let customerViewController = CustomerViewController(_customerID: image.customer,_customerName: image.customerName)
                    self.navigationController?.pushViewController(customerViewController, animated: false )
                    //customerViewController.showImages()
                
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Customer Images", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                
                self.delegate.showCustomerImages(_customer: self.image.customer!)
                self.goBack()
              
            }))
            
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction!) -> Void in
                
               
                
            }))
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                
                let popover:UIPopoverPresentationController = nav.popoverPresentationController! 
                
                //let popover = nav.popoverPresentationController as! UIPopoverPresentationController
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                self.present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
                
            }
            
        }
        
        
    }
    
    
    @objc func showLikesList(){
        //print("show likes list w/ ID = \(image.ID)")
        let imageLikesListViewController = ImageEmployeeLikesListViewController(_image: self.image)
        self.navigationController?.pushViewController(imageLikesListViewController, animated: false )
    }
    
    
    @objc func hideUI(_ sender: UITapGestureRecognizer){
        
        
        
        if !UIHidden{
            print("slide UI Out")
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                // var fabricTopFrame = self.fabricTop.frame
               // self.view.frame.origin.y -= keyboardFrame.height
                if UIApplication.shared.statusBarOrientation.isLandscape {
                    //here you can do the logic for the cell size if phone is in landscape
                    print("landscape")
                    
                    self.textView.frame.origin.y = self.layoutVars.fullWidth
                }else{
                    print("portrait")
                    
                    self.textView.frame.origin.y = self.layoutVars.fullHeight
                }
                
                self.navigationController?.navigationBar.frame.origin.y = 0 - (self.navigationController?.navigationBar.frame.height)!
                
            }, completion: { finished in
                ////print("Napkins opened!")
                self.UIHidden = !self.UIHidden
            })
            
        }else{
            print("slide UI in")
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                // var fabricTopFrame = self.fabricTop.frame
                // self.view.frame.origin.y -= keyboardFrame.height
                if UIApplication.shared.statusBarOrientation.isLandscape {
                    //here you can do the logic for the cell size if phone is in landscape
                    print("landscape")
                    
                    self.textView.frame.origin.y = self.layoutVars.fullWidth - 40
                    self.navigationController?.navigationBar.frame.origin.y = 0
                }else{
                    print("portrait")
                    
                    self.textView.frame.origin.y = self.layoutVars.fullHeight - 150
                    self.navigationController?.navigationBar.frame.origin.y = 20//status bar height
                }
                
                
            }, completion: { finished in
                ////print("Napkins opened!")
                self.UIHidden = !self.UIHidden
            })
        }
    }
    /*
    
    @objc func showFullScreenImage(_ sender: UITapGestureRecognizer){
        
        
        
        navigationController?.pushViewController(imageFullViewController, animated: false )
    }
    */
    
    
    @objc func swiped(_ gesture: UIGestureRecognizer){
        //print("swiped")
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                //print("right swipe")
                if delegate != nil{
                    _ = delegate.getPrevNextImage(_next: false)
                }
                
            case UISwipeGestureRecognizer.Direction.left:
                //print("left swipe")
                if delegate != nil{
                    _ = delegate.getPrevNextImage(_next: true)
                }
            default:
                print("other swipe")
            }
        }
    }
    
    @objc func share() {
        print("share")
        if self.presentedViewController == nil {
            let activity = UIActivityViewController(activityItems: [self.imageView.image!], applicationActivities: nil)
            present(activity, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: {
                let activity = UIActivityViewController(activityItems: [self.image!], applicationActivities: nil)
                self.layoutVars.getTopController().present(activity, animated: true, completion: nil)
            })
        }
    }
    
    
    
    
    
   
    
    
    
        
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
       
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("rotate view")
        
        print("viewWillLayoutSubviews")
        
        print("view width = \(self.view.frame.width)")
        scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        imageView.frame = CGRect(x:0, y:0, width:scrollView.frame.width, height:scrollView.frame.height)
        
        //setUpViews()
        
        
        setZoomScale()
        
        
        setUpViews()
        
        
    
    }
    
    
    
    func setUpViews(){
        
        UIHidden = false
        
        print("set up views")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        
        if(self.textView != nil){
            self.textView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
    
        self.scrollView.addSubview(self.imageView)

        
        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.scrollView)
        self.view.addSubview(activityView)
        self.view.addSubview(self.textView)
        
        self.textView.addSubview(self.likeBtn)
        
        
        self.textView.addSubview(self.likesBtn)
       
        self.textView.addSubview(self.customerBtn)
        
        self.likeBtn.addSubview(self.likesImageView)
        
       




        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
       
        

        
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            //here you can do the logic for the cell size if phone is in landscape
            print("landscape")
            
          
            self.textView.frame = CGRect(x:0, y:(layoutVars.fullWidth - 40), width:scrollView.frame.width, height:40)
             self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likeBtn(30)][likesBtn(80)]-[customerLbl]-|", options: [NSLayoutConstraint.FormatOptions.alignAllCenterY], metrics: nil, views: viewsDictionary2))
            
            
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likeBtn(30)]", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likesBtn(30)]", options: [], metrics: nil, views: viewsDictionary2))
            
            
        } else {
            //logic if not landscape
            print("portrait")
            
            
            self.textView.addSubview(self.descriptionLbl)
            
            self.textView.addSubview(self.tagsLbl)
            self.textView.frame = CGRect(x:0, y:(layoutVars.fullHeight - 150), width:scrollView.frame.width, height:150)
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likeBtn(30)][likesBtn(80)]-[customerLbl]-|", options: [NSLayoutConstraint.FormatOptions.alignAllCenterY], metrics: nil, views: viewsDictionary2))
            
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
                    
                    
                    //native way
                    
                    do {
                        if let data = response.data,
                            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            
                        
                        
                        
                        
                            let imageLikes = json["newLikes"] as? String{
                            
                                self.image.likes = "\(imageLikes)"
                            
                            
                            print("self.image.likes = \(String(describing: self.image.likes))")
                            
                                if self.image.likes == "1"{
                                    self.likesBtn.setTitle("x\(String(describing: self.image.likes!)) Like", for: UIControl.State.normal)
                                }else{
                                    self.likesBtn.setTitle("x\(String(describing: self.image.likes!)) Likes", for: UIControl.State.normal)
                                }
                            self.imageLikeDelegate.updateLikes(_index: self.image.index!, _liked: self.image.liked!, _likes: json["newLikes"] as! String)
                                
                           
                        }
                        
                        
                        
                       
                        
                    } catch {
                        print("Error deserializing JSON: \(error)")
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
                    
                    
                    
                    //native way
                    
                    do {
                        if let data = response.data,
                            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            
                            
                            
                            
                            let imageLikes = json["newLikes"] as? String{
                            
                            self.self.image.likes = imageLikes
                            
                            if self.image.likes == "1"{
                                self.likesBtn.setTitle("x\(String(describing: self.image.likes)) Like", for: UIControl.State.normal)
                            }else{
                                self.likesBtn.setTitle("x\(String(describing: self.image.likes)) Likes", for: UIControl.State.normal)
                            }
                            self.imageLikeDelegate.updateLikes(_index: self.image.index!, _liked: self.image.liked!, _likes: json["newLikes"] as! String)
                            
                            
                        }
                        
                        
                        
                       
                        
                    } catch {
                        print("Error deserializing JSON: \(error)")
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
    
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   @objc func canRotate() -> Void {}
    
    
}

