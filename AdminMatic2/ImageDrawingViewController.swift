//
//  ImageDrawingViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/11/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import UIKit

class ImageDrawingViewController: UIViewController {

    var layoutVars:LayoutVars = LayoutVars()
    var delegate:ImageDrawingDelegate!
    
    var backButton: UIButton!
    
    var imageView:UIImageView!
    var image:UIImage!
    
    var widthRatio : CGFloat = 0.0
    var heightRatio : CGFloat = 0.0
    var scale : CGFloat = 0.0
    var imageWidth : CGFloat = 0.0
    var imageHeight : CGFloat = 0.0
    
    
    var lastPoint:CGPoint!
    var isSwiping:Bool!
    
    var red:CGFloat = 0.0
    var green:CGFloat = 0.0
    var blue:CGFloat = 0.0
    
    var brush: CGFloat = 15.0
    
    var redBtn:Button!
    var orangeBtn:Button!
    var yellowBtn:Button!
    var greenBtn:Button!
    var blueBtn:Button!
    var purpleBtn:Button!
    var pinkBtn:Button!
    var brownBtn:Button!
    var whiteBtn:Button!
    var grayBtn:Button!
    var blackBtn:Button!
    
    var smallBrushBtn:Button!
    var mediumBrushBtn:Button!
    var largeBrushBtn:Button!
    
    var clearBtn:Button!
    var doneBtn:Button!
    
    var indexPath:IndexPath!
    
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (1.0,0.0,0.0),
        (1.0,0.5,0.0),
        (1.0, 1.0, 0),
        (0.0,1.0,0.0),
        (0.0,0.0,1.0),
        (0.5,0.0,0.5),
        (255.0/255.0,0.0/255.0,233.0/255.0),
        (0.6,0.4,0.2),
        (1.0,1.0,1.0),
        (0.33,0.33,0.33),
        (0.0,0.0,0.0)
    ]
    
    init(_indexPath:IndexPath, _image:UIImage){
        super.init(nibName:nil,bundle:nil)
        self.image = _image
        self.indexPath = _indexPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func image(image: UIImage, withPotentialError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        
        
        let alertController = UIAlertController(title: nil, message: "Image successfully saved to Photos library", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let DestructiveAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            //print("Dismiss")
        }
        alertController.addAction(DestructiveAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Draw"
        
        
       
        layoutViews()
        
       // NotificationCenter.default.addObserver(self, selector: #selector(ImageDrawingViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
 
    }
    
    
    
    
    func layoutViews(){
        
         self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        // Do any additional setup after loading the view, typically from a nib.
        red   = (255.0/255.0)
        green = (0.0/255.0)
        blue  = (0.0/255.0)
        
        self.view.backgroundColor = layoutVars.backgroundColor
       
        
        self.imageView = UIImageView(frame:CGRect(x: 0, y: layoutVars.navAndStatusBarHeight, width: self.view.frame.size.width, height: self.view.frame.size.height)    )
        
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        self.imageView.layer.borderWidth = 1.0
        
        self.imageView.image = self.image
        self.imageView.clipsToBounds = true
        
        self.view.addSubview(self.imageView)
        
        
        //custom back button
        backButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(ImageDrawingViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
       
        
        let shareBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(ImageDrawingViewController.share))
        self.navigationItem.rightBarButtonItem = shareBtn
        
        
        
        
        widthRatio = imageView.bounds.size.width / imageView.image!.size.width;
        heightRatio = imageView.bounds.size.height / imageView.image!.size.height;
        scale = min(widthRatio, heightRatio);
        imageWidth = CGFloat(Int(scale * imageView.image!.size.width));
        imageHeight = CGFloat(Int(scale * imageView.image!.size.height));
        
        
        imageView.frame.size.width = imageWidth
        imageView.frame.size.height = imageHeight
        

        
        //print("rescaled imageWidth = \(imageWidth)")
        //print("rescaled imageHeight = \(imageHeight)")
        
        //print("image width = \(self.imageView.frame.size.width)")
        
        //print("image height = \(self.imageView.frame.size.height)")
        //print("scale = \(scale)")
        
        
        
        self.redBtn = Button()
        self.redBtn.tag = 0
        self.redBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.redBtn.layer.borderWidth = 2.0
        self.redBtn.translatesAutoresizingMaskIntoConstraints = false
        self.redBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.redBtn.backgroundColor = UIColor.red
        self.view.addSubview(self.redBtn)
        
        self.orangeBtn = Button()
        self.orangeBtn.tag = 1
        self.orangeBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.orangeBtn.layer.borderWidth = 2.0
        self.orangeBtn.translatesAutoresizingMaskIntoConstraints = false
        self.orangeBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.orangeBtn.backgroundColor = UIColor.orange
        self.view.addSubview(self.orangeBtn)
        
        self.yellowBtn = Button()
        self.yellowBtn.tag = 2
        self.yellowBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.yellowBtn.layer.borderWidth = 2.0
        self.yellowBtn.translatesAutoresizingMaskIntoConstraints = false
        self.yellowBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.yellowBtn.backgroundColor = UIColor.yellow
        self.view.addSubview(self.yellowBtn)
        
        self.greenBtn = Button()
        self.greenBtn.backgroundColor = UIColor.green
        self.greenBtn.tag = 3
        self.greenBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.greenBtn.layer.borderWidth = 2.0
        self.greenBtn.translatesAutoresizingMaskIntoConstraints = false
        self.greenBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.greenBtn)
        
        self.blueBtn = Button()
        self.blueBtn.backgroundColor = UIColor.blue
        self.blueBtn.tag = 4
        self.blueBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.blueBtn.layer.borderWidth = 2.0
        self.blueBtn.translatesAutoresizingMaskIntoConstraints = false
        self.blueBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.blueBtn)
        
        self.purpleBtn = Button()
        self.purpleBtn.backgroundColor = UIColor.purple
        self.purpleBtn.tag = 5
        self.purpleBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.purpleBtn.layer.borderWidth = 2.0
        self.purpleBtn.translatesAutoresizingMaskIntoConstraints = false
        self.purpleBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.purpleBtn)
        
        self.pinkBtn = Button()
        self.pinkBtn.backgroundColor = UIColor(displayP3Red: 255.0/255.0, green: 0.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        //self.pinkBtn.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 0.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        self.pinkBtn.tag = 6
        self.pinkBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.pinkBtn.layer.borderWidth = 2.0
        self.pinkBtn.translatesAutoresizingMaskIntoConstraints = false
        self.pinkBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.pinkBtn)
        
        
        self.brownBtn = Button()
        self.brownBtn.backgroundColor = UIColor.brown
        self.brownBtn.tag = 7
        self.brownBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.brownBtn.layer.borderWidth = 2.0
        self.brownBtn.translatesAutoresizingMaskIntoConstraints = false
        self.brownBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.brownBtn)
        
        self.whiteBtn = Button()
        self.whiteBtn.backgroundColor = UIColor.white
        self.whiteBtn.tag = 8
        self.whiteBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.whiteBtn.layer.borderWidth = 2.0
        self.whiteBtn.translatesAutoresizingMaskIntoConstraints = false
        self.whiteBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.whiteBtn)
        
        self.grayBtn = Button()
        self.grayBtn.backgroundColor = UIColor.darkGray
        self.grayBtn.tag = 9
        self.grayBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.grayBtn.layer.borderWidth = 2.0
        self.grayBtn.translatesAutoresizingMaskIntoConstraints = false
        self.grayBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.grayBtn)
        
        self.blackBtn = Button()
        self.blackBtn.backgroundColor = UIColor.black
        self.blackBtn.tag = 10
        self.blackBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.blackBtn.layer.borderWidth = 2.0
        self.blackBtn.translatesAutoresizingMaskIntoConstraints = false
        self.blackBtn.addTarget(self, action: #selector(ImageDrawingViewController.colorChange), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.blackBtn)
        
        self.smallBrushBtn = Button()
        self.smallBrushBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.smallBrushBtn.layer.borderWidth = 2.0
        let smallCircle:UIView = UIView(frame: CGRect(x: 24.5, y: 24.5, width: 5, height: 5) )
        smallCircle.isUserInteractionEnabled = false
        smallCircle.backgroundColor = UIColor.white
        smallCircle.layer.cornerRadius = 2.5
        smallBrushBtn.addSubview(smallCircle)
        
        self.smallBrushBtn.backgroundColor = layoutVars.buttonColor1
        
        self.smallBrushBtn.translatesAutoresizingMaskIntoConstraints = false
        self.smallBrushBtn.addTarget(self, action: #selector(ImageDrawingViewController.smallBrush), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.smallBrushBtn)
        
        self.mediumBrushBtn = Button()
        self.mediumBrushBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.mediumBrushBtn.layer.borderWidth = 2.0
        
        let mediumCircle:UIView = UIView(frame: CGRect(x: 22, y: 22, width: 10, height: 10))
        mediumCircle.isUserInteractionEnabled = false
        mediumCircle.backgroundColor = UIColor.white
        mediumCircle.layer.cornerRadius = 5
        mediumBrushBtn.addSubview(mediumCircle)
        
        self.mediumBrushBtn.backgroundColor = layoutVars.buttonColor1
        self.mediumBrushBtn.translatesAutoresizingMaskIntoConstraints = false
        self.mediumBrushBtn.addTarget(self, action: #selector(ImageDrawingViewController.mediumBrush), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.mediumBrushBtn)
        
        self.largeBrushBtn = Button()
        self.largeBrushBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.largeBrushBtn.layer.borderWidth = 2.0
        let largeCircle:UIView = UIView(frame: CGRect(x: 19.5, y: 19.5, width: 15, height: 15))
        
        largeCircle.isUserInteractionEnabled = false
        
        
        
        largeCircle.backgroundColor = UIColor.white
        largeCircle.layer.cornerRadius = 7.5
        largeBrushBtn.addSubview(largeCircle)
        
        self.largeBrushBtn.backgroundColor = layoutVars.buttonColor1
        self.largeBrushBtn.translatesAutoresizingMaskIntoConstraints = false
        self.largeBrushBtn.addTarget(self, action: #selector(ImageDrawingViewController.largeBrush), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.largeBrushBtn)
        
        
        
        self.clearBtn = Button(titleText: "Clear")
        self.clearBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.clearBtn.layer.borderWidth = 2.0
        self.clearBtn.backgroundColor = layoutVars.buttonColor1
        self.clearBtn.translatesAutoresizingMaskIntoConstraints = false
        self.clearBtn.addTarget(self, action: #selector(ImageDrawingViewController.clear), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.clearBtn)
        
        self.doneBtn = Button(titleText: "Done")
        self.doneBtn.layer.borderColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha: 1.0).cgColor
        self.doneBtn.layer.borderWidth = 2.0
        self.doneBtn.backgroundColor = layoutVars.buttonColor1
        self.doneBtn.translatesAutoresizingMaskIntoConstraints = false
        self.doneBtn.addTarget(self, action: #selector(ImageDrawingViewController.done), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.doneBtn)
        
        
        
        /////////////////  Auto Layout   ////////////////////////////////////////////////
     
        
         let viewsDictionary = [
         
         "red":self.redBtn,
         "orange":self.orangeBtn,
         "yellow":self.yellowBtn,
         "green":self.greenBtn,
         "blue":self.blueBtn,
         "purple":self.purpleBtn,
         "pink":self.pinkBtn,
         "brown":self.brownBtn,
         "white":self.whiteBtn,
         "gray":self.grayBtn,
         "black":self.blackBtn,
         "small":self.smallBrushBtn,
         "medium":self.mediumBrushBtn,
         "large":self.largeBrushBtn,
         "clear":self.clearBtn,
         "done":self.doneBtn
         ] as [String:Button]
 
        
         let sizeVals = ["colorBtnSize": layoutVars.colorBtnSize,"clearBtnSize": layoutVars.fullWidth/2]  as [String:CGFloat]
        
         
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[red(colorBtnSize)][orange(colorBtnSize)][yellow(colorBtnSize)][green(colorBtnSize)][blue(colorBtnSize)][purple(colorBtnSize)][pink(colorBtnSize)]", options: NSLayoutFormatOptions.alignAllBottom, metrics: sizeVals, views: viewsDictionary))
         
         
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[brown(colorBtnSize)][white(colorBtnSize)][gray(colorBtnSize)][black(colorBtnSize)][small(colorBtnSize)][medium(colorBtnSize)][large(colorBtnSize)]", options: NSLayoutFormatOptions.alignAllBottom, metrics: sizeVals, views: viewsDictionary))
         
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[clear(clearBtnSize)][done(clearBtnSize)]|", options: NSLayoutFormatOptions.alignAllBottom, metrics: sizeVals, views: viewsDictionary))
         
         
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[red(colorBtnSize)]-108-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[orange(colorBtnSize)]-108-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[yellow(colorBtnSize)]-108-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[green(colorBtnSize)]-108-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[blue(colorBtnSize)]-108-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[purple(colorBtnSize)]-108-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[pink(colorBtnSize)]-108-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[brown(colorBtnSize)]-54-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[white(colorBtnSize)]-54-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[gray(colorBtnSize)]-54-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[black(colorBtnSize)]-54-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[small(colorBtnSize)]-54-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[medium(colorBtnSize)]-54-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[large(colorBtnSize)]-54-|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[clear(colorBtnSize)]|", options: [], metrics: sizeVals, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[done(colorBtnSize)]|", options: [], metrics: sizeVals, views: viewsDictionary))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSwiping = false
        if let touch = touches.first {
            lastPoint = touch.location(in: imageView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSwiping = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: imageView)
            drawLine(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
   
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0)
        
        imageView.image?.draw(in: imageView.bounds)
        
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(self.brush)
        context?.setStrokeColor(red: self.red, green: self.green, blue: self.blue, alpha: 1.0)
        context?.setBlendMode(CGBlendMode.normal)
        context?.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = 1.0
        UIGraphicsEndImageContext()
        
        
        self.imageView.contentMode = .scaleAspectFill
       
        //print("image width = \(self.imageView.frame.size.width)")
 
        //print("image height = \(self.imageView.frame.size.height)")
    }
 
 
 
 
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isSwiping {
            // draw a single point
            self.drawLine(fromPoint: lastPoint, toPoint: lastPoint)
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
    

    
    @objc func colorChange(sender:AnyObject){
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        (red, green, blue) = colors[index]
        
        if index == colors.count - 1 {
        }
    }
    
    @objc func smallBrush(){
        //print("smallBrush")
        self.brush = 5
        
    }
    
    @objc func mediumBrush(){
        //print("mediumBrush")
        self.brush = 15
        
    }
    
    @objc func largeBrush(){
        //print("largeBrush")
        self.brush = 30
        
    }
    
    @objc func clear(){
        
        self.imageView.image = self.image
        
        
    }
    
    @objc func done(){
        goBack()
    }
   

 
    @objc func goBack(){
        //print("Go Back")
        delegate.updateImage(_indexPath:self.indexPath, _image: self.imageView.image!)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    //Future work - enable view rotate
    
    /*
     func rotated() {
     layoutViews()
     if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
     //print("Landscape")
     }
     
     if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
     //print("Portrait")
     }
     
     }
     */
    
    
    
    // func canRotate() -> Void {}
    
    
}



