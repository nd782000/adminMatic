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
    var delegate:ImageViewDelegate!
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    var image:Image!
    var backgroundImageView:UIImageView!
    
    var blurEffect:UIBlurEffect!
    var blurredEffectView:UIVisualEffectView!
    
    var imageView:UIImageView!
    var activityView:UIActivityIndicatorView!
    
    var textView:UIView!
    var createdByLbl:Label!
    var dateAddedLbl:Label!
    var descriptionLbl:UITextView!
    var tagsLbl:Label!
    
    var viewsDictionary:[String:Any] = [:]
    var viewsDictionary2:[String:Any] = [:]
    
    
    
    var imageFullViewController:ImageFullViewController!
    
    init(_image:Image){
        super.init(nibName:nil,bundle:nil)
        self.image = _image
        self.imageFullViewController = ImageFullViewController(_image: _image)
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
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
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
        if(self.backgroundImageView != nil){
            self.backgroundImageView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
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
        
        
        self.textView = UIView()
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textView.backgroundColor = UIColor(hex: 0x005100, op: 0.6)
        //self.view.addSubview(self.textView)
       
        self.createdByLbl = Label(text: "by: \(self.image.createdBy!)")
        self.createdByLbl.textColor = UIColor.white
        //self.textView.addSubview(self.createdByLbl)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        let date = dateFormatter.date(from: self.image.dateAdded)!
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MM/dd/yyyy"

            
        let addedByDate = shortDateFormatter.string(from: date)
        
        
        self.dateAddedLbl = Label(text:  "date: \(addedByDate)")
        self.dateAddedLbl.textAlignment = NSTextAlignment.right
       
        self.dateAddedLbl.textColor = UIColor.white
        //self.textView.addSubview(self.dateAddedLbl)
        
        self.descriptionLbl = UITextView()
        self.descriptionLbl.text = self.image.description!
        self.descriptionLbl.backgroundColor = UIColor(hex: 0xffffff, op: 0.1)
        self.descriptionLbl.layer.cornerRadius = 4.0
        self.descriptionLbl.textColor = UIColor.white
        self.descriptionLbl.font = layoutVars.textFieldFont
        
        self.descriptionLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.tagsLbl = Label(text: self.image.tags!)
        self.tagsLbl.textColor = UIColor.white

        activityView.startAnimating()
        
         let imgUrl = URL(string: image.rawPath)
        
        Nuke.loadImage(with: imgUrl!, into: imageView){ [weak view] in
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
        
        viewsDictionary2 = [
            "createdByLbl":self.createdByLbl, "dateAddedLbl":self.dateAddedLbl, "descriptionLbl":self.descriptionLbl, "tagsLbl":self.tagsLbl
            ] as [String:Any]
        
        setUpViews()
        
        
    }
    
    func showFullScreenImage(_ sender: UITapGestureRecognizer){
        
        
        
        navigationController?.pushViewController(imageFullViewController, animated: false )
    }
    
    
    func swiped(_ gesture: UIGestureRecognizer){
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
    
    func share() {
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
    
    
    
        
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
       
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("rotate view")
        
        
        
        setUpViews()
        
        
       
    }
    
    
    
    func setUpViews(){
        
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        if(self.textView != nil){
            self.textView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
    
        self.view.addSubview(self.backgroundImageView)
        self.view.addSubview(self.imageView)
        self.view.addSubview(activityView)
        self.view.addSubview(self.textView)
        self.textView.addSubview(self.createdByLbl)
        self.textView.addSubview(self.dateAddedLbl)
        
    
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[textView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: viewsDictionary))
        
        
        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {
            //here you can do the logic for the cell size if phone is in landscape
            print("landscape")
            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[textView(40)]|", options: [], metrics: nil, views: viewsDictionary))
            
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[createdByLbl]-[dateAddedLbl(150)]-|", options: [NSLayoutFormatOptions.alignAllCenterY], metrics: nil, views: viewsDictionary2))
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[createdByLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            
        } else {
            //logic if not landscape
            //print("portrait")
            
            self.textView.addSubview(self.descriptionLbl)
            
            self.textView.addSubview(self.tagsLbl)

            self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[textView(150)]|", options: [], metrics: nil, views: viewsDictionary))
            
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[createdByLbl]-[dateAddedLbl(150)]-|", options: [NSLayoutFormatOptions.alignAllCenterY], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tagsLbl]-|", options: [], metrics: nil, views: viewsDictionary2))
            self.textView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[createdByLbl(25)][descriptionLbl]-[tagsLbl(25)]-|", options: [], metrics: nil, views: viewsDictionary2))
            
        }
        
        self.blurredEffectView.frame = self.view.bounds
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
