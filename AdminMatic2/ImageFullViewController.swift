//
//  ImageFullViewController.swift
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
       
        
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ImageFullViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        self.layoutViews()
    }
    
    func layoutViews()
    {
        super.viewDidLoad()
        
         title = self.image.name
        
        scrollView=UIScrollView()
        scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        
        
        scrollView.minimumZoomScale=1
        scrollView.maximumZoomScale=3
        scrollView.bounces=false
        scrollView.delegate=self
        scrollView.backgroundColor = UIColor.darkGray
        self.view.addSubview(scrollView)
        
        imageView=UIImageView()
        imageView.backgroundColor = UIColor.darkGray
        imageView.frame = CGRect(x:0, y:0, width:scrollView.frame.width, height:scrollView.frame.height)
        
        
        
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        
       
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        
        let imgUrl = URL(string: image.rawPath)
        
        
        //Nuke.loadImage(with: imgUrl!, into: imageView){ [weak view] in
            
        Nuke.loadImage(with: imgUrl!, into: imageView){
            self.imageView?.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            let shareBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(ImageFullViewController.share))
            self.navigationItem.rightBarButtonItem = shareBtn
        }
        
        setZoomScale()
        setupGestureRecognizer()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ImageFullViewController.swiped(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.imageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ImageFullViewController.swiped(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.imageView.addGestureRecognizer(swipeLeft)

    }
    
    
    @objc func swiped(_ gesture: UIGestureRecognizer){
        print("swiped")
        
        if delegate != nil{
            if(scrollView.zoomScale == 1){
                
                imageView.image = nil
                
                if let swipeGesture = gesture as? UISwipeGestureRecognizer{
                    switch swipeGesture.direction {
                    case UISwipeGestureRecognizerDirection.right:
                        print("right swipe")
                        
                        
                            _ = delegate.getPrevNextImage(_next: false)
                        
                        
                    case UISwipeGestureRecognizerDirection.left:
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
        return self.imageView
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        print("viewWillLayoutSubviews")
        
        print("view width = \(self.view.frame.width)")
        scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        imageView.frame = CGRect(x:0, y:0, width:scrollView.frame.width, height:scrollView.frame.height)
        
        
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
                self.present(activity, animated: true, completion: nil)
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




