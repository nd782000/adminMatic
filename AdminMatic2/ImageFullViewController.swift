//
//  ImageFullViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/14/17.
//  Copyright © 2017 Nick. All rights reserved.
//


/*
import Foundation
import UIKit
import Alamofire
//import SwiftyJSON
//import Nuke

 
class ImageFullViewController: UIViewController, UIScrollViewDelegate{
   
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    var activityView:UIActivityIndicatorView!
    var scrollView : UIScrollView!
    var imageView:UIImageView!
    var image:Image!
    var delegate:ImageViewDelegate!
    
   
    
    init(_image:Image){
        super.init(nibName:nil,bundle:nil)
        // print("init _employeeID = \(_employeeID) _employeePhone = \(_employeePhone)")
        self.image = _image
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
       
        /*
        
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(ImageFullViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
 */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        
        self.layoutViews()
    }
    
    func layoutViews()
    {
        super.viewDidLoad()
        
         title = self.image.name
        
        scrollView=UIScrollView()
        scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height - 40)
        
        
        scrollView.minimumZoomScale=1
        scrollView.maximumZoomScale=3
        scrollView.bounces=false
        scrollView.delegate=self
        scrollView.backgroundColor = UIColor.darkGray
        self.view.addSubview(scrollView)
        
        imageView=UIImageView()
        imageView.backgroundColor = UIColor.darkGray
        //imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.frame = CGRect(x:0, y:0, width:scrollView.frame.width, height:scrollView.frame.height)
        
        
        
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        
       
        
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        
        Alamofire.request(image.rawPath).responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.response!)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
                self.imageView.image = image
                
                self.activityView.stopAnimating()
                
            }
        }
        
        
        
        
        
        setZoomScale()
        setupGestureRecognizer()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ImageFullViewController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.imageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ImageFullViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.imageView.addGestureRecognizer(swipeLeft)
        
        
        
        

    }
    
    /*
    func setUpViews(){
        
        
        print("set up views")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        // _ = ["navHeight":self.layoutVars.navAndStatusBarHeight, "landscapeNavHeight":self.layoutVars.navAndStatusBarHeight - self.layoutVars.statusBarHeight] as [String : Any]
        
        //print("navHeight = \(self.layoutVars.navAndStatusBarHeight)  statusBarHeight = \(self.layoutVars.statusBarHeight) ")
        
        if(self.scrollView != nil){
            self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
        }
        //if(self.likesView != nil){
        // self.likesView.subviews.forEach({ $0.removeFromSuperview() })
        // }
        
        
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
       
        
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: viewsDictionary))
        self.scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: viewsDictionary2))
        self.scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: viewsDictionary2))
        
        
        
        
        
        
    }
    
    */
    
    
    
    
    
    @objc func swiped(_ gesture: UIGestureRecognizer){
        print("swiped")
        
        if delegate != nil{
            if(scrollView.zoomScale == 1){
                
                imageView.image = nil
                
                if let swipeGesture = gesture as? UISwipeGestureRecognizer{
                    switch swipeGesture.direction {
                    case UISwipeGestureRecognizer.Direction.right:
                        print("right swipe")
                        
                        
                            _ = delegate.getPrevNextImage(_next: false)
                        
                        
                    case UISwipeGestureRecognizer.Direction.left:
                        print("left swipe")
                       
                        
                            _ = delegate.getPrevNextImage(_next: true)
                        
                    default:
                        print("other swipe")
                    }
                }
            }
        }
    }

    
    
    
    
  //Scroll Methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        print("viewForZooming")
       // self.navigationController?.isNavigationBarHidden = true
        return self.imageView
        
    }
   
    
    override func viewWillLayoutSubviews() {
        print("viewWillLayoutSubviews")
        
        print("view width = \(self.view.frame.width)")
        scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        imageView.frame = CGRect(x:0, y:0, width:scrollView.frame.width, height:scrollView.frame.height)
        
        //setUpViews()
        
        
        setZoomScale()
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("Test")
    }
    
    
  
    
    @objc func canRotate() -> Void {}
    
    
    
   
    
}



*/

