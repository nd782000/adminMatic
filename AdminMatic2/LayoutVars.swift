//
//  LayoutVars.swift
//  Atlantic_Blank
//
//  Created by Nicholas Digiando on 4/6/15.
//  Copyright (c) 2015 Nicholas Digiando. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapKit
import Alamofire



extension UIColor {
    
    convenience init(hex: Int, op: CGFloat) {
        
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        
        self.init(red: components.R, green: components.G, blue: components.B, alpha: op)
        
    }
    
}






extension String {
    //test git  
    
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9-_ ]", options: .regularExpression) == nil
    }
    
    var twoFractionDigits: String {
        let styler = NumberFormatter()
        styler.minimumFractionDigits = 2
        styler.maximumFractionDigits = 2
        styler.numberStyle = .currency
        let converter = NumberFormatter()
        converter.decimalSeparator = "."
        if let result = converter.number(from: self) {
            return styler.string(from: result)!
        }
        return ""
    }
}


class LayoutVars: UIViewController {
    
    var fullWidth:CGFloat! = UIScreen.main.bounds.width
    var fullHeight:CGFloat! = UIScreen.main.bounds.height
    
    var colorBtnSize:CGFloat! = UIScreen.main.bounds.width/7
    var navAndStatusBarHeight:CGFloat! = 64
    var statusBarHeight:CGFloat! = UIApplication.shared.statusBarFrame.height
    var backgroundColor:UIColor = UIColor(hex:0xFFF8E6, op: 1)
    var backgroundLight:UIColor = UIColor(hex:0xFFFaF8, op: 1)
    var buttonBackground:UIColor = UIColor(hex:0xFFFFFF, op: 1)
    var buttonTint:UIColor = UIColor(hex:0x005100, op: 1)
    var buttonActive:UIColor = UIColor(hex:0x227322, op: 1)
    var buttonColor1:UIColor = UIColor(hex:0x005100, op: 1)
    var buttonTextColor:UIColor = UIColor(hex:0xffffff, op: 1)
    var borderColor:CGColor = UIColor(hex:0x005100, op: 1).cgColor
    var largeFont:UIFont = UIFont(name: "Helvetica Neue", size: 28)!
    var labelFont:UIFont = UIFont(name: "Helvetica Neue", size: 24)!
    var labelBoldFont = UIFont(name:"HelveticaNeue-Bold", size: 16)!
    
    var smallFont:UIFont = UIFont(name: "Helvetica Neue", size: 20)!
    var buttonFont:UIFont = UIFont(name: "Helvetica Neue", size: 18)!
    var textFieldFont:UIFont = UIFont(name: "Helvetica Neue", size: 12)!

    var inputHeight = 50
    
    var defaultImage : UIImage = UIImage(named:"cameraIcon.png")!
    
    let rawBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/raw/"
    let mediumBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/medium/"
    let thumbBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/thumbs/"
    
    
    let manager: Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "www.atlanticlawnandgarden.com": .disableEvaluation
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    

    
     
}


class PaddedTextField: UITextField {
    
    var placeHolder:String!
    
    override init(frame:CGRect)
    {
        super.init(frame:frame)
        
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(hex:0xFFFFFF, op: 1)
        let inputFont:UIFont = UIFont(name: "Helvetica Neue", size: 17)!
        self.font = inputFont
        self.returnKeyType = UIReturnKeyType.next
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var leftMargin : CGFloat = 5.0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftMargin
        return newBounds
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftMargin
        return newBounds
    }
    
    func reset() {
        self.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.backgroundColor = UIColor(hex:0xFFFFFF, op: 1)
        self.layer.borderWidth = 1
    }
    
    func error() {
        self.layer.borderColor = UIColor(hex:0xff0000, op: 0.2).cgColor
        self.backgroundColor = UIColor(hex:0xFFFFFF, op: 1)
        self.layer.borderWidth = 3
    }
    
    convenience init(placeholder:String!) {
        self.init()
        self.placeHolder = placeholder
        self.attributedPlaceholder = NSAttributedString(string:placeholder,attributes:[NSForegroundColorAttributeName: UIColor(hex:0x333333, op: 0.75)])
    }
    
    convenience init(textValue:String!) {
        self.init()
        self.text = textValue
    }
}




class TableView: UITableView {
    
      
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(hex:0xFFFFFF, op: 0.8)
        self.separatorColor = UIColor(hex:0x005100, op: 0.6)
        self.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        self.separatorInset = UIEdgeInsets.zero
        self.rowHeight = 40
        
        self.tableHeaderView = nil
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}




class SegmentedControl:UISegmentedControl{

    
    override init(items: [Any]?) {
        super.init(items: items)
        
        let layoutVars:LayoutVars = LayoutVars()
        self.selectedSegmentIndex = 0
        self.backgroundColor = UIColor(hex:0xFFFFFF, op: 1)
        let attr = NSDictionary(object: UIFont(name: "Avenir Next", size: 16.0)!, forKey: NSFontAttributeName as NSCopying)
        self.setTitleTextAttributes(attr as? [AnyHashable: Any], for: UIControlState())
        self.layer.cornerRadius = 0  // Don't let background bleed
       
        self.tintColor = layoutVars.buttonTint
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.masksToBounds = false;
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
  

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Label :UILabel{
    var valueMode:Bool!
    var insets:UIEdgeInsets!
    var textVal:String!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = UIColor.black
        self.font = UIFont(name: "Avenir Next", size: 16)
    }
    
    convenience init(text: String?, valueMode:Bool = false){
        self.init()
        self.valueMode = true
        self.text = text
        
        if(valueMode == true){
            self.textColor = UIColor.black
            self.font = UIFont(name: "Avenir Next", size: 16)
            insets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 0.0)
        }else{
            self.textColor = UIColor(hex: 0x005100, op: 1)
            self.font = UIFont(name: "Avenir Next", size: 16)
            insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        self.translatesAutoresizingMaskIntoConstraints = false//for autolayout
        
    }
}

class DetailLabel :UILabel{
    
    var insets:UIEdgeInsets!
    var textVal:String!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textColor = UIColor.gray
        self.font = UIFont(name: "Avenir Next", size: 12)
    }
    
    convenience init(text: String?, valueMode:Bool = false){
        self.init()
        self.text = text
        self.textAlignment = NSTextAlignment.right
        self.textColor = UIColor.gray
        self.font = UIFont(name: "Avenir Next", size: 12)
        self.translatesAutoresizingMaskIntoConstraints = false//for autolayout
    }
}


class H1Label :UILabel{
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(text: String?){
        self.init()
        self.text = text
        self.textAlignment = NSTextAlignment.center
        self.textColor = UIColor.black
        self.font = UIFont(name: "Avenir Next", size: 26)
        self.translatesAutoresizingMaskIntoConstraints = false//for autolayout
    }
    
}

class InfoLabel :UILabel{
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5.0
    }
    
    convenience init(text: String?){
        self.init()
        self.text = text
        self.textColor = UIColor.black
        self.font = UIFont(name: "Avenir Next", size: 18)
        self.layer.cornerRadius = 5.0
        self.translatesAutoresizingMaskIntoConstraints = false//for autolayout
    }
    
}

class GreyLabel:UILabel {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    convenience init(icon:Bool){
        self.init()
        if(icon == true){
            insets = UIEdgeInsets(top: 0.0, left: 30.0, bottom: 0.0, right: 0.0)
        }else{
            insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        self.translatesAutoresizingMaskIntoConstraints = false//for autolayout
        
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}




class THead :UILabel{
    var valueMode:Bool!
    var insets:UIEdgeInsets!
    var textVal:String!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(text: String?){
        self.init()
        self.text = text
        self.font = UIFont(name: "Avenir Next-italic", size: 16)
        self.textColor = UIColor.white
        self.translatesAutoresizingMaskIntoConstraints = false//for autolayout
    }
    
}


class Picker:UIPickerView{
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false//for autolayout
        self.backgroundColor = UIColor.white
        let layer = self.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 8
    }
    
}

class DatePicker:UIDatePicker{
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false//for autolayout
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 4.0
    }
    
}

class Button:UIButton{
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hex:0x005100, op: 1.0)
        self.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 16)!
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.layer.cornerRadius = 5.0
        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    convenience init(titleText:String!) {
        self.init()
        self.setTitle(titleText, for: UIControlState())
    }
}

class Cell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
    }
}



/////////////////////    Helper Methods     //////////////////////////////////

func html_Decode(_ _encodedString:String!)->String{

    let encodedData = _encodedString.data(using: String.Encoding.utf8)!
    let attributedOptions : [String: AnyObject] = [
        NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
        NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject
    ]
    let attributedString = try! NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
    let decodedString = attributedString.string // The Weeknd ‘King Of The Fall’
    
    return decodedString
}

func cleanText(_ _text:String!)->String{
    
    var cleanText = ""
    
       // print("phone = \(_text)")
        cleanText = _text!.replacingOccurrences(of: "\t", with: "", options: NSString.CompareOptions.literal, range: nil)
        cleanText = cleanText.replacingOccurrences(of: "\n", with: "-", options: NSString.CompareOptions.literal, range: nil)
        cleanText = cleanText.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range: nil)
        cleanText = cleanText.replacingOccurrences(of: "\\", with: "", options: NSString.CompareOptions.literal, range: nil)
        cleanText = cleanText.replacingOccurrences(of: "\0", with: "", options: NSString.CompareOptions.literal, range: nil)
        cleanText = cleanText.replacingOccurrences(of: "^\\s*", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        
        cleanText = cleanText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        print("Clean Text= \(cleanText)")
    return cleanText
}

func cleanAddress(_ _dirtyString:String!)->String{
    var cleanAddress = ""
    
        print("phone = \(_dirtyString)")
        cleanAddress = _dirtyString!.replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range: nil)
        cleanAddress = cleanAddress.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
        print("address Clean = \(cleanAddress)")
        
        if(cleanAddress == ""){
            cleanAddress = "No Address Saved"
        }
    return cleanAddress
}




func cleanPhoneNumber(_ _number:String!)->String{
    print("clean phone number \(_number)")
    let stringArray = _number.components(
        separatedBy: CharacterSet.decimalDigits.inverted)
    print("clean phone stringArray \(stringArray)")
    let cleanPhone = stringArray.joined(separator: "")
    print("cleanPhone \(cleanPhone)")
    return cleanPhone
}


////  Calling, Emailing .....






func callPhoneNumber(_ _number:String){
    print("Call \(_number)")
    
    
    
    if (cleanPhoneNumber(_number) != "No Number Saved"){
        
        UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(_number))")! as URL, options: [:], completionHandler: nil)
    }
    
    
    
    /*
    
    let alertController: UIAlertController
    
     if (cleanPhoneNumber(_number) != "No Number Saved"){
    
        alertController = UIAlertController(title: "CALL \(_number)", message: "Confirm Phone Call", preferredStyle: UIAlertControllerStyle.alert) //Replace
        let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            print("Cancel")
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
           UIApplication.shared.open(URL(string: "tel://\(_number)")!, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
     }else{
        alertController = UIAlertController(title: "No Saved Number", message: "", preferredStyle: UIAlertControllerStyle.alert) //Replace
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
           
        }
        
        alertController.addAction(okAction)
    }
      
    getTopViewController().present(alertController, animated: true, completion: nil)
    
    */
    
}

func getTopViewController() -> UIViewController{
    
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }else{
        return (UIApplication.shared.delegate?.window!?.rootViewController!)!
    }
    
    
}





func sendEmail(_ _email:String){
    print("send Email to \(_email)")
    let url = URL(string: "mailto:\(_email)")
    print("url: \(url)")
    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    
}


func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
        
        if (error != nil) {
            print("Error:" + error!.localizedDescription)
            return
        }
        if placemarks!.count > 0 {
            let pm = placemarks![0] 
            displayLocationInfo(pm)
            
        }else {
            
            print("Error with data")
        }
    })
}

func displayLocationInfo(_ placemark: CLPlacemark) {
    let locationManager = CLLocationManager()
    locationManager.stopUpdatingLocation()
    /*
    print(placemark.locality ?? <#default value#>)
    print(placemark.postalCode ?? <#default value#>)
    print(placemark.administrativeArea ?? <#default value#>)
    print(placemark.country ?? <#default value#>)
 */
    
}

func locationManager(_ manager: CLLocationManager!, didFailWithError error: NSError!) {
    print("Error: " + error.localizedDescription)
}


func openMapForPlace(_ _name:String,_lat:NSString,_lng:NSString) {
    print("openMapForPlace name: \(_name) lat: \(_lat) lng: \(_lng)")
    let latitute:CLLocationDegrees =  _lat.doubleValue
    let longitute:CLLocationDegrees =  _lng.doubleValue
    
    let regionDistance:CLLocationDistance = 100000
    let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
    let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
    let options = [
        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
    ]
    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = _name
    mapItem.openInMaps(launchOptions: options)
    
}

func openWebLink(_ _url:String){
    print("openWebLink url: \(_url)")
    UIApplication.shared.open(URL(string: "http://\(_url)")!, options: [:], completionHandler: nil)
}


func verifyUrl (_ urlString: String?) -> Bool {
    //Check for nil
    if let urlString = urlString {
        // create NSURL instance
        if let url = URL(string: urlString) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url)
        }
    }
    return false
}


func getChargeName(_charge:String) -> String {
    var chargeTypeName:String
    switch (_charge) {
    case "1":
        chargeTypeName = "NC"
        break;
    case "2":
        chargeTypeName = "FL"
        break;
    case "3":
        chargeTypeName = "T&M"
        break;
    default:
        chargeTypeName = "Null"//online
        break;
    }
    return chargeTypeName
    
}






class SDevIndicator : UIView {
    
    var spinnerParentView : UIView!
    var spinner : UIActivityIndicatorView!
    var layoutVars:LayoutVars
    var loadingLabel:UILabel!
    
    class func generate(_ mainView: UIView) -> SDevIndicator? {
        return SDevIndicator(frame: mainView.bounds, mainView: mainView)
    }
    
    init(frame: CGRect, mainView: UIView) {
        self.layoutVars = LayoutVars()
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinnerParentView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: layoutVars.fullHeight))
        spinnerParentView.backgroundColor = layoutVars.buttonTint
        spinnerParentView.alpha = 0.8
        spinnerParentView.center = self.center
        spinner.center = CGPoint(x: layoutVars.fullWidth/2, y: layoutVars.fullWidth/2)
        spinnerParentView.addSubview(spinner)
        self.addSubview(self.spinnerParentView)
        mainView.addSubview(self)
        spinner.startAnimating()
        
        loadingLabel = UILabel(frame: CGRect(x: 0, y: 100, width: layoutVars.fullWidth, height: 40))
        loadingLabel.textAlignment = NSTextAlignment.center
        loadingLabel.center = CGPoint(x: layoutVars.fullWidth/2, y: layoutVars.fullHeight/2 + 50)
        loadingLabel.textColor = UIColor.white
        mainView.addSubview(loadingLabel)
        loadingLabel.text = "Loading..."
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismissIndicator() -> Void {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0
            }, completion: {
                finished in
                self.spinner.stopAnimating()
                self.removeFromSuperview()
                self.loadingLabel.removeFromSuperview()
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

    }
    
    
    
    
    
    
    
}


struct loggedInKeys {
    static let loggedInId = ""
}


extension UIImage {
    
    public func fixedOrientation() -> UIImage {
        
        //print("fixedOrientation")
         //print("imageOrientation = \(imageOrientation.rawValue)")
        
        if imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        
        switch imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil,
                                       width: Int(size.width),
                                       height: Int(size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent,
                                       bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
    
    
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
}



//
//  MonthYearPicker.swift
//
//  Created by Ben Dodson on 15/04/2015.
//  Modified by Jiayang Miao on 24/10/2016 to support Swift 3
//
import UIKit

class MonthYearPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var months: [String]!
    var years: [Int]!
    
    var month: Int = 0 {
        didSet {
            selectRow(month-1, inComponent: 0, animated: false)
        }
    }
    
    var year: Int = 0 {
        didSet {
            selectRow(years.index(of: year)!, inComponent: 1, animated: true)
        }
    }
    
    var onDateSelected: ((_ month: Int, _ year: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        // population years
        var years: [Int] = []
        if years.count == 0 {
            var year = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
            for _ in 1...15 {
                years.append(year)
                year += 1
            }
        }
        self.years = years
        
        // population months with localized names
        var months: [String] = []
        var month = 0
        for _ in 1...12 {
            months.append(DateFormatter().monthSymbols[month].capitalized)
            month += 1
        }
        self.months = months
        
        self.delegate = self
        self.dataSource = self
        
        let currentMonth = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.month, from: NSDate() as Date)
        self.selectRow(currentMonth - 1, inComponent: 0, animated: false)
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return months[row]
        case 1:
            return "\(years[row])"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = self.selectedRow(inComponent: 0)+1
        let year = years[self.selectedRow(inComponent: 1)]
        if let block = onDateSelected {
            block(month, year)
        }
        
        self.month = month
        self.year = year
    }
    
}












