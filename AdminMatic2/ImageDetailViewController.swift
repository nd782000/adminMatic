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


class ImageDetailViewController: UIViewController{
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
    
    var likesBtn:Button = Button(titleText: "")
    var likesImageView:UIImageView = UIImageView()
    var likesLbl:Label = Label()
    
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
        //self.view.addSubview(activityView)
        
        
        /*
        self.likesView = UIView()
        self.likesView.translatesAutoresizingMaskIntoConstraints = false
        self.likesView.backgroundColor = layoutVars.backgroundColor
        self.likesView.layer.opacity = 0.9
        */
        
        //if(self.mode != "Top Image"){
           // self.votesView.isHidden = true
       // }
        
       // self.plusVoteBtn.addTarget(self, action: #selector(ImageDetailViewController.handlePlusVote), for: UIControlEvents.touchUpInside)
        
        //self.minusVoteBtn.addTarget(self, action: #selector(ImageDetailViewController.handleMinusVote), for: UIControlEvents.touchUpInside)
        
        
        
        
        
        self.textView = UIView()
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.backgroundColor = UIColor(hex: 0x005100, op: 0.6)
        
        self.likesBtn = Button(titleText: "")
        self.likesBtn.backgroundColor = UIColor.clear
        
        if(self.image.liked == "0"){
            self.likesImageView.image = UIImage(named:"unLiked.png")
        }else{
            self.likesImageView.image = UIImage(named:"liked.png")
        }
        
        likesImageView.contentMode = .scaleAspectFill
        likesImageView.translatesAutoresizingMaskIntoConstraints = false
        self.likesBtn.addTarget(self, action: #selector(ImageDetailViewController.handleLike), for: UIControlEvents.touchUpInside)
        
        //self.textView.addSubview(self.likesImageView)
        
        self.likesLbl.text = "x\(self.image.likes)"
        self.likesLbl.layer.opacity = 1.0
        self.likesLbl.textColor = UIColor(hex: 0xffffff, op: 1.0)
        //self.textView.addSubview(self.likesLbl)
        

        
        
       
       // self.createdByLbl = Label(text: "\(self.image.createdBy!)")
       // self.createdByLbl.textColor = UIColor.white
        //self.createdByLbl.textAlignment = NSTextAlignment.right
        
        /*
        self.customerLbl = Label(text: "\(self.image.customerName)")
        self.customerLbl.textColor = UIColor.white
        self.customerLbl.textAlignment = NSTextAlignment.right
        */
        
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
        
        viewsDictionary2 = ["likesBtn":self.likesBtn, "likesLbl":self.likesLbl, "customerLbl":self.customerBtn, "descriptionLbl":self.descriptionLbl, "tagsLbl":self.tagsLbl
            ] as [String:Any]
        viewsDictionary3 = ["likesImage":self.likesImageView] as [String:Any]
        
        setUpViews()
        
        
    }
    
    @objc func showCustomerView(){
        print("customer = \(image.customer)")
        if(image.customer != "0"){
            let customerViewController = CustomerViewController(_customerID: image.customer, _customerName: image.customerName, _imageView: true)
            //let customerViewController = CustomerViewController(_customerID: image.customer,_customerName: image.customerName)
            navigationController?.pushViewController(customerViewController, animated: false )
            //customerViewController.showImages()
        }
        
        
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
    
    /*
    func edit(){
        print("edit")
       /*
        let imageUploadViewController:ImageUploadViewController = ImageUploadViewController(_imageType: "Gallery", _ID: "", _image: self.imageView.image!, _saveURLString: self.saveURLString)
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        
            
            
        imageUploadViewController.loadLinkList(_linkType: "customers", _loadScript: API.Router.customerList(["cb":timeStamp as AnyObject]))
        //self.loadLinkList(_linkType: "customers", _loadScript: API.Router.customerList(["cb":timeStamp as AnyObject]))
        
        
        
        
        
        
        
       // self.imagePicked = true
        
        //imageUploadViewController.delegate = self
        
        navigationController?.pushViewController(imageUploadViewController, animated: false )
*/
        
        
        
        
        
    }
 */
    
    
    
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
        
        self.textView.addSubview(self.likesBtn)
        
        
        self.textView.addSubview(self.likesLbl)
       // self.textView.addSubview(self.createdByLbl)
        //self.textView.addSubview(self.customerLbl)
        self.textView.addSubview(self.customerBtn)
        
        self.likesBtn.addSubview(self.likesImageView)
        
       




        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[textView]|", options: [], metrics: nil, views: viewsDictionary))
       // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[likesView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        
        
        
        print("votesView 1")
        //self.votesView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done



        /*let imgUrl = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+(appDelegate.loggedInEmployee?.pic)!)
        self.likesImageView.layer.opacity = 1.0
        
        
        
        // let imgURL:URL = URL(string: imgUrl)!
        Nuke.loadImage(with: imgUrl!, into: self.likesImageView){ [weak likesView] in
            //print("nuke loadImage")
            self.likesImageView.handle(response: $0, isFromMemoryCache: $1)
            //self.activityView.stopAnimating()
        }
        */
        
                //print("votesView 3")
       
        
        
        /*
        //self.plusVoteBtn.titleLabel?.text = "+"
        self.plusVoteBtn.layer.opacity = 1.0
        self.plusVoteBtn.titleLabel?.textColor = UIColor.white
        self.votesView.addSubview(plusVoteBtn)
        
        //self.minusVoteBtn.titleLabel?.text = "-"
        self.minusVoteBtn.layer.opacity = 1.0
        self.minusVoteBtn.titleLabel?.textColor = UIColor.white
        self.votesView.addSubview(minusVoteBtn)
        
        self.myVotesValueLbl.text = "8"
        self.myVotesValueLbl.layer.opacity = 1.0
        self.myVotesValueLbl.textColor = UIColor(hex: 0x005100, op: 1.0)
        self.votesView.addSubview(self.myVotesValueLbl)
        
        self.totalVotesLbl.text = "Total Votes"
        self.totalVotesLbl.layer.opacity = 1.0
        self.totalVotesLbl.textColor = UIColor(hex: 0x005100, op: 1.0)
        self.votesView.addSubview(self.totalVotesLbl)
        
        self.totalVotesValueLbl.text = "39"
        self.totalVotesValueLbl.layer.opacity = 1.0
        self.totalVotesValueLbl.textColor = UIColor(hex: 0x005100, op: 1.0)
        self.votesView.addSubview(self.totalVotesValueLbl)

        */
        
        
        
        
        /*
        viewsDictionary3 = [
            "likesImageView":self.likesImageView, "likesLbl":self.likesLbl
            ] as [String:Any]
        self.likesView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likesImageView(30)]-[likesLbl]-|", options: [], metrics: nil, views: viewsDictionary3))
        
        print("votesView 4")
        
        self.likesView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[likesImageView(30)]", options: [], metrics: nil, views: viewsDictionary3))
        self.likesView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[likesLbl(30)]", options: [], metrics: nil, views: viewsDictionary3))
        print("votesView 5")
        
       */
        
        

        
        
        
        
        

        
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            //here you can do the logic for the cell size if phone is in landscape
            print("landscape")
            
           // let navHeight = self.navigationController!.navigationBar.layer.frame.height
            
           // let sizeVals2 = ["navHeight":navHeight] as [String : Any]

            //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[votesView(100)]", options: [], metrics: nil, views: viewsDictionary))
            
            //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[likesView(80)]", options: [], metrics: sizeVals2, views: viewsDictionary))
            
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[textView(40)]|", options: [], metrics: nil, views: viewsDictionary))
            
            
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likesBtn(30)][likesLbl(50)]-[customerLbl(250)]-|", options: [NSLayoutFormatOptions.alignAllCenterY], metrics: nil, views: viewsDictionary2))
            
            
            
           // self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|- [likesImageView(30)]-[createdByLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likesBtn(30)]", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likesLbl(30)]", options: [], metrics: nil, views: viewsDictionary2))
            
           
            
            
            
           
            
            
            
        } else {
            //logic if not landscape
            print("portrait")
            
           // self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navHeight-[likesView(80)]", options: [], metrics: sizeVals, views: viewsDictionary))
            
            //self.textView.addSubview(self.customerLbl)
            self.textView.addSubview(self.descriptionLbl)
            
            self.textView.addSubview(self.tagsLbl)
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[textView(150)]|", options: [], metrics: nil, views: viewsDictionary))
            
            
           // self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likesImageView(30)]-[likesLbl(20)]-|", options: [], metrics: nil, views: viewsDictionary2))
            //self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likesImageView(30)]", options: [], metrics: nil, views: viewsDictionary2))
           // self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likesLbl(30)]", options: [], metrics: nil, views: viewsDictionary2))
            
            
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[likesBtn(30)][likesLbl(50)]-[customerLbl(250)]-|", options: [NSLayoutFormatOptions.alignAllCenterY], metrics: nil, views: viewsDictionary2))
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likesBtn(30)]-[descriptionLbl]-[tagsLbl(25)]-|", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[likesBtn(30)]-[descriptionLbl]-|", options: [], metrics: nil, views: viewsDictionary2))

            //self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[customerLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tagsLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            
            
        }
        
        
        self.likesBtn.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[likesImage(30)]", options: [], metrics: nil, views: viewsDictionary3))
        
        
        
        // self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|- [likesImageView(30)]-[createdByLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
        self.likesBtn.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[likesImage(30)]", options: [], metrics: nil, views: viewsDictionary3))
        
        
        
        
        
        
        //vote view
       // if(self.mode == "Top Image"){
            
        
            
        //}else{
            //self.votesView.isHidden = true
       // }
        
        
        self.blurredEffectView.frame = self.view.bounds
        
    }
    
    
    
    /*
    func handlePlusVote(){
        print("handle Plus Vote")
        
        //self.messageView?.isHidden = true
        
    }
    
    func handleMinusVote(){
        print("handle Minus Vote")
        
        //self.messageView?.isHidden = true
        
    }

    
    */
    
    
    @objc func handleLike(){
        print("handle Like")
        
        indicator = SDevIndicator.generate(self.view)!
        let parameters = ["empID":self.appDelegate.loggedInEmployee?.ID as AnyObject, "imageID":self.image.ID as AnyObject]
        
        
        if(self.image.liked == "0"){
            self.image.liked = "1"
            self.likesImageView.image = UIImage(named:"liked.png")
            
           /* Alamofire.request(API.Router.newLike(["empID":self.appDelegate.loggedInEmployee?.ID as AnyObject, "imageID":self.image.ID as AnyObject])).responseString() {
                response in
                print(response.request ?? "")  // original URL request
                print(response.response ?? "") // URL response
                print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
            }
            */
           // print("imageID = \(self.image.ID)")
             //print("empID = \(String(describing: self.appDelegate.loggedInEmployee?.ID))")
            
            
            
            
            
            
            
            
            
            
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
                        self.likesLbl.text = "x\(self.image.likes)"
                        self.imageLikeDelegate.updateLikes(_index: self.image.index, _liked: self.image.liked, _likes: returnJSON["newLikes"].stringValue)
                        
                    }
                    
                    self.indicator.dismissIndicator()
            }
            
            
            
            
            
            
            
            
            
            
            /*
            
            Alamofire.request(API.Router.newLike(["empID":self.appDelegate.loggedInEmployee?.ID as AnyObject, "imageID":self.image.ID as AnyObject])).responseJSON() {
                response in
                print(response.request ?? "")  // original URL request
                print(response.response ?? "") // URL response
                print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    let returnJSON = JSON(json)
                    self.image.likes = returnJSON["newLikes"].stringValue
                    self.likesLbl.text = "x\(self.image.likes)"
                    self.imageLikeDelegate.updateLikes(_index: self.image.index, _liked: self.image.liked, _likes: returnJSON["newLikes"].stringValue)
                    
                }
               // self.imageLikeDelegate.updateLikes(_index: self.image.index, _liked: self.image.liked, _likes: "100")

                
                
            }
            */
 
            
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
                        self.likesLbl.text = "x\(self.image.likes)"
                        self.imageLikeDelegate.updateLikes(_index: self.image.index, _liked: self.image.liked, _likes: returnJSON["newLikes"].stringValue)
                        
                    }
                    
                    self.indicator.dismissIndicator()
            }

            
            
            
            
            
            /*
            Alamofire.request(API.Router.deleteLike(["empID":self.appDelegate.loggedInEmployee?.ID as AnyObject, "imageID":self.image.ID as AnyObject])).responseJSON() {
                response in
                // //print(response.request ?? "")  // original URL request
                ////print(response.response ?? "") // URL response
                ////print(response.data ?? "")     // server data
                ////print(response.result)   // result of response serialization
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    let returnJSON = JSON(json)
                    self.image.likes = returnJSON["newLikes"].stringValue
                    self.likesLbl.text = "x\(self.image.likes)"
                    self.imageLikeDelegate.updateLikes(_index: self.image.index, _liked: self.image.liked, _likes: returnJSON["newLikes"].stringValue)
                    
                }
                
                

                
            }
 */
            
            
        }
        
        
        
        //self.messageView?.isHidden = true
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

