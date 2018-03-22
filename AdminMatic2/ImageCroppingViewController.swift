//
//  ImageCroppingViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//



/*
import UIKit
import AKImageCropperView




class ImageCroppingViewController: UIViewController  {
    
    var layoutVars:LayoutVars = LayoutVars()
    var delegate:ImageDrawingDelegate!
    var backButton: UIButton!
    
    var cropView: AKImageCropperView!
    var indexPath:IndexPath!
    var imageToCrop:UIImage!
    var undoButton: Button!
    var cropButton: Button!
    var editsMade:Bool = false
    
    init(_indexPath:IndexPath, _image:UIImage){
        super.init(nibName:nil,bundle:nil)
        self.imageToCrop = _image
        self.indexPath = _indexPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func image(image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        
        
        let alertController = UIAlertController(title: nil, message: "Image successfully saved to Photos library", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let DestructiveAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
        }
        alertController.addAction(DestructiveAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image Cropping"
        layoutViews()
    }
    

    func layoutViews(){
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.view.backgroundColor = UIColor.darkGray
        self.cropView = AKImageCropperView(frame:CGRect(x: 0, y: layoutVars.navAndStatusBarHeight, width: self.view.frame.size.width, height: self.view.frame.size.height - layoutVars.navAndStatusBarHeight - 40))
        self.cropView.image = self.imageToCrop
        view.addSubview(self.cropView)
        
        // Inset for overlay action view
        
        cropView.overlayView?.configuraiton.cropRectInsets.bottom = layoutVars.navAndStatusBarHeight
        cropView.delegate = self
        cropView.showOverlayView(animationDuration: 0.3)
        
        
        //custom back button
        backButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ImageCroppingViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        self.cropButton = Button()
        self.cropButton.translatesAutoresizingMaskIntoConstraints = false
        self.cropButton.setTitle("Crop", for: UIControlState.normal)
        self.cropButton.layer.borderColor = UIColor.darkGray.cgColor
        self.cropButton.layer.borderWidth = 2
        
        self.cropButton.addTarget(self, action: #selector(ImageCroppingViewController.crop), for: UIControlEvents.touchUpInside)
        view.addSubview(self.cropButton)
        
        self.undoButton = Button()
        self.undoButton.translatesAutoresizingMaskIntoConstraints = false
        self.undoButton.setTitle("Undo", for: UIControlState.normal)
        self.undoButton.layer.borderColor = UIColor.darkGray.cgColor
        self.undoButton.layer.borderWidth = 2
        
        self.undoButton.addTarget(self, action: #selector(ImageCroppingViewController.undo), for: UIControlEvents.touchUpInside)
         view.addSubview(self.undoButton)
        
    
        let sizeVals = ["width": layoutVars.fullWidth/2] as [String : Any]
        //auto layout group
        let viewsDictionary = [
            "undoBtn":self.undoButton, "cropBtn":self.cropButton
            ] as [String:Any]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[undoBtn(width)][cropBtn(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[undoBtn(40)]|", options: [], metrics: nil, views: viewsDictionary))
       self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cropBtn(40)]|", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func undo(){
       self.cropView.reset(animationDuration: 0.5, options: [], completion: nil)
    }
    
    
    
    @objc func crop(){
        delegate.updateImage(_indexPath:self.indexPath, _image: self.cropView.croppedImage!)
        _ = navigationController?.popViewController(animated: true)
    }
    

    @objc func goBack(){
        
        if(editsMade == true){
            let alertController = UIAlertController(title: "Edits Made", message: "Crop this Image?", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                self.crop()
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
             _ = navigationController?.popViewController(animated: true)
        }
    }
}




//  MARK: - AKImageCropperViewDelegate
extension ImageCroppingViewController: AKImageCropperViewDelegate {
    
    func imageCropperViewDidChangeCropRect(view: AKImageCropperView, cropRect rect: CGRect) {
        print("imageCropperViewDidChangeCropRect")
        editsMade = true
                print("New crop rectangle: \(rect)")
    }
    
}

*/




