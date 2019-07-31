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
// import this
import AVFoundation


/*
extension Collection where Iterator.Element == [String:AnyObject] {
    func toJSONString(options: JSONSerialization.WritingOptions = .prettyPrinted) -> String {
        if let arr = self as? [[String:AnyObject]],
            let dat = try? JSONSerialization.data(withJSONObject: arr, options: options),
            let str = String(data: dat, encoding: String.Encoding.utf8) {
            return str
        }
        return "[]"
    }
}
*/


/*
extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}
*/


//Way to time functions
/*
 
 //before function
 var methodStart:Date!
 var methodFinish:Date!
 methodStart = Date()
 
 //after execution of function
 methodFinish = Date()
 let executionTime = methodFinish.timeIntervalSince(methodStart)
 print("Execution time: \(executionTime)")
 */

 

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

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }
    
    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            a: a
        )
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




//used to color map pins
extension MKPinAnnotationView {
    class func bluePinColor() -> UIColor {
        return UIColor.blue
    }
    class func grayPinColor() -> UIColor {
        return UIColor.gray
    }
}


extension UIView{
    
    func pinToEdges(view:UIView){
        self.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
        self.leftAnchor.constraint(equalTo:view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo:view.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
    }
    
    func anchor(top:NSLayoutYAxisAnchor?, left:NSLayoutXAxisAnchor?, right:NSLayoutXAxisAnchor?, bottom:NSLayoutYAxisAnchor?, topPadding:CGFloat, leftPadding:CGFloat, rightPadding:CGFloat, bottomPadding:CGFloat, width:CGFloat = 0, height:CGFloat = 0){
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }
        if let left = left{
            self.leftAnchor.constraint(equalTo: left, constant: leftPadding).isActive = true
        }
        if let right = right{
            self.rightAnchor.constraint(equalTo: right, constant: rightPadding).isActive = true
        }
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: bottomPadding).isActive = true
        }
        if width != 0{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    var safeTopAnchor:NSLayoutYAxisAnchor{
        if #available(iOS 11.0, *){
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var safeLeftAnchor:NSLayoutXAxisAnchor{
        if #available(iOS 11.0, *){
            return safeAreaLayoutGuide.leftAnchor
        }
        return leftAnchor
    }
    
    var safeRightAnchor:NSLayoutXAxisAnchor{
        if #available(iOS 11.0, *){
            return safeAreaLayoutGuide.rightAnchor
        }
        return rightAnchor
    }
    
    var safeBottomAnchor:NSLayoutYAxisAnchor{
        if #available(iOS 11.0, *){
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
}





class LayoutVars: UIViewController {
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var fullWidth:CGFloat! = UIScreen.main.bounds.width
    var halfWidth:CGFloat! = (UIScreen.main.bounds.width - 25)/2
    var fullHeight:CGFloat! = UIScreen.main.bounds.height
    
    var colorBtnSize:CGFloat! = UIScreen.main.bounds.width/7
    var navAndStatusBarHeight:CGFloat! = 64
    var statusBarHeight:CGFloat! = UIApplication.shared.statusBarFrame.height
    
    /*
    var backgroundColor1:UIColor = UIColor(hex:0xefc6c6, op: 1)
    var backgroundColor2:UIColor = UIColor(hex:0xefeac6, op: 1)
    var backgroundColor3:UIColor = UIColor(hex:0xdbefc6, op: 1)
    var backgroundColor4:UIColor = UIColor(hex:0xc6edef, op: 1)
    var backgroundColor5:UIColor = UIColor(hex:0xd0c6ef, op: 1)
    
    
    var backgroundColorArray:[UIColor]!
    */
    
    
    
    
    
    
    
    
    var backgroundColor:UIColor = UIColor(hex:0xFFF8E6, op: 1)
    var navBarColor:UIColor = UIColor(hex:0x999999, op: 1)
    var backgroundLight:UIColor = UIColor(hex:0xFFFaF8, op: 1)
    var buttonBackground:UIColor = UIColor(hex:0xFFFFFF, op: 1)
    var buttonTint:UIColor = UIColor(hex:0x005100, op: 1)
    var buttonActive:UIColor = UIColor(hex:0x227322, op: 1)
    var buttonColor1:UIColor = UIColor(hex:0x005100, op: 1)
    var buttonTextColor:UIColor = UIColor(hex:0x005100, op: 1)
    var borderColor:CGColor = UIColor(hex:0x005100, op: 1).cgColor
    var largeFont:UIFont = UIFont(name: "Helvetica Neue", size: 28)!
    var labelFont:UIFont = UIFont(name: "Helvetica Neue", size: 24)!
    var labelBoldFont = UIFont(name:"HelveticaNeue-Bold", size: 16)!
    
    var smallFont:UIFont = UIFont(name: "Helvetica Neue", size: 20)!
    var smallBoldFont:UIFont = UIFont(name: "HelveticaNeue-Bold", size: 20)!
    var extraSmallFont:UIFont = UIFont(name: "Helvetica Neue", size: 14)!
    var buttonFont:UIFont = UIFont(name: "Helvetica Neue", size: 18)!
    var textFieldFont:UIFont = UIFont(name: "Helvetica Neue", size: 12)!
    var microFont:UIFont = UIFont(name: "Helvetica Neue", size: 10)!

    var inputHeight = 50
    
    var defaultImage : UIImage = UIImage(named:"cameraIcon.png")!
    
    let rawBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/raw/"
    let mediumBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/medium/"
    let thumbBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/thumbs/"
    
    let salutations = ["Mr.","Mrs.","Ms.","Miss","Dr."]
    
    /*let states = ["Alaska",
                  "Alabama",
                  "Arkansas",
                  "American Samoa",
                  "Arizona",
                  "California",
                  "Colorado",
                  "Connecticut",
                  "District of Columbia",
                  "Delaware",
                  "Florida",
                  "Georgia",
                  "Guam",
                  "Hawaii",
                  "Iowa",
                  "Idaho",
                  "Illinois",
                  "Indiana",
                  "Kansas",
                  "Kentucky",
                  "Louisiana",
                  "Massachusetts",
                  "Maryland",
                  "Maine",
                  "Michigan",
                  "Minnesota",
                  "Missouri",
                  "Mississippi",
                  "Montana",
                  "North Carolina",
                  " North Dakota",
                  "Nebraska",
                  "New Hampshire",
                  "New Jersey",
                  "New Mexico",
                  "Nevada",
                  "New York",
                  "Ohio",
                  "Oklahoma",
                  "Oregon",
                  "Pennsylvania",
                  "Puerto Rico",
                  "Rhode Island",
                  "South Carolina",
                  "South Dakota",
                  "Tennessee",
                  "Texas",
                  "Utah",
                  "Virginia",
                  "Virgin Islands",
                  "Vermont",
                  "Washington",
                  "Wisconsin",
                  "West Virginia",
                  "Wyoming"]
 */
    
    
    let states = [ "AK - Alaska",
                  "AL - Alabama",
                  "AR - Arkansas",
                  "AS - American Samoa",
                  "AZ - Arizona",
                  "CA - California",
                  "CO - Colorado",
                  "CT - Connecticut",
                  "DC - District of Columbia",
                  "DE - Delaware",
                  "FL - Florida",
                  "GA - Georgia",
                  "GU - Guam",
                  "HI - Hawaii",
                  "IA - Iowa",
                  "ID - Idaho",
                  "IL - Illinois",
                  "IN - Indiana",
                  "KS - Kansas",
                  "KY - Kentucky",
                  "LA - Louisiana",
                  "MA - Massachusetts",
                  "MD - Maryland",
                  "ME - Maine",
                  "MI - Michigan",
                  "MN - Minnesota",
                  "MO - Missouri",
                  "MS - Mississippi",
                  "MT - Montana",
                  "NC - North Carolina",
                  "ND - North Dakota",
                  "NE - Nebraska",
                  "NH - New Hampshire",
                  "NJ - New Jersey",
                  "NM - New Mexico",
                  "NV - Nevada",
                  "NY - New York",
                  "OH - Ohio",
                  "OK - Oklahoma",
                  "OR - Oregon",
                  "PA - Pennsylvania",
                  "PR - Puerto Rico",
                  "RI - Rhode Island",
                  "SC - South Carolina",
                  "SD - South Dakota",
                  "TN - Tennessee",
                  "TX - Texas",
                  "UT - Utah",
                  "VA - Virginia",
                  "VI - Virgin Islands",
                  "VT - Vermont",
                  "WA - Washington",
                  "WI - Wisconsin",
                  "WV - West Virginia",
                  "WY - Wyoming"]
    
    
    
    /*
    
    init(){
        super.init(nibName:nil,bundle:nil)
        
        
        
        
         
         
         
         if UIDevice().userInterfaceIdiom == .phone {
         switch UIScreen.main.nativeBounds.height {
         case 1136:
         print("iPhone 5 or 5S or 5C")
         case 1334:
         print("iPhone 6/6S/7/8")
         case 2208:
         print("iPhone 6+/6S+/7+/8+")
         case 2436:
         print("iPhone X")
            navAndStatusBarHeight = navAndStatusBarHeight + 24
         default:
         print("unknown")
         }
         }
         
        
        
        
        
        //let number:Int = Int(arc4random_uniform(5))
        //print("background color number = \(number)")
        
        //self.backgroundColorArray = [backgroundColor1,backgroundColor2,backgroundColor3,backgroundColor4,backgroundColor5]
        
        //self.backgroundColor = self.backgroundColorArray[number]
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    */
    
    
    
    
    
    
    var manager: Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "www.atlanticlawnandgarden.com": .disableEvaluation
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        //configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
 
    //var topController:UIViewController
    
   
    
    func imageOrientation(_ srcImage: UIImage)->UIImage {
        if srcImage.imageOrientation == UIImage.Orientation.up {
            return srcImage
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch srcImage.imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: srcImage.size.width, y: srcImage.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))// replace M_PI by Double.pi when using swift 4.0
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: srcImage.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))// replace M_PI_2 by Double.pi/2 when using swift 4.0
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: srcImage.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))// replace M_PI_2 by Double.pi/2 when using swift 4.0
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        switch srcImage.imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: srcImage.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: srcImage.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        let ctx:CGContext = CGContext(data: nil, width: Int(srcImage.size.width), height: Int(srcImage.size.height), bitsPerComponent: (srcImage.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (srcImage.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.concatenate(transform)
        switch srcImage.imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(srcImage.cgImage!, in: CGRect(x: 0, y: 0, width: srcImage.size.height, height: srcImage.size.width))
            break
        default:
            ctx.draw(srcImage.cgImage!, in: CGRect(x: 0, y: 0, width: srcImage.size.width, height: srcImage.size.height))
            break
        }
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        return img
    }
    
    
    
    
    
    
    func simpleAlert(_vc:UIViewController,_title:String,_message:String?){
        print("simpleAlert: \(String(describing: _message))")
        let alertController = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        
        self.getTopController().present(alertController, animated: false, completion: nil)
        
        
        
        
        
        
        
    }
    
   
    
    
    func grantAccess(_level:Int,_view:UIViewController)->Bool{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if (appDelegate.loggedInEmployee?.userLevel)! <= _level{
        
            self.simpleAlert(_vc: self.getTopController(), _title: "Access Denied", _message: "Your user level (\(appDelegate.loggedInEmployee!.userLevelName!)) does not allow access to this feature.")
            return true
        }else{
            return false
        }
        
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    //method used for equipment service date forcasting
    func determineUpcomingDate(_equipmentService:EquipmentService)->String{
        print("determineUpcomingDate")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        //var dateString = "2014-07-15" // change to your date format
        
        let dbDateFormatter = DateFormatter()
        dbDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dbDateFormatter.locale = NSLocale.current
        dbDateFormatter.timeZone = TimeZone.current
        
        let dbDate = dbDateFormatter.date(from: _equipmentService.creationDate)
        
        
        
        //print("equipmentService.nextValue = \(_equipmentService.nextValue)")
        //print("equipmentService.creationDate = \(_equipmentService.creationDate)")
       // print("dbDate = \(String(describing: dbDate))")
        
        
        
        let daysToAdd = Int(_equipmentService.nextValue)!
        let futureDate = Calendar.current.date(byAdding:
            .day, // updated this params to add hours
            value: daysToAdd,
            to: dbDate!)
        
        print(dateFormatter.string(from: futureDate!))
        return dateFormatter.string(from: futureDate!)
        
    }
    
    
    func getDayOfWeek(_ today:String) -> Int? {
        // sunday = 0, saturday = 6
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay - 1
    }
    
    
    func numberAsCurrency(_number:String)->String{
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        // localize to your grouping and decimal separator
        currencyFormatter.locale = Locale.current
        
        // We'll force unwrap with the !, if you've got defined data you may need more error checking
        
        let priceString = currencyFormatter.string(from: NSNumber(value: Double(_number)!))!
        //let priceString = "\(currencyFormatter.number(from: _number))"
        print(priceString) // Displays $9,999.99 in the US locale
        
        return priceString
        
        /*
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        var returnVal:String = ""
        if let formattedTipAmount = formatter.number(from: _number) {
            returnVal = "\(formattedTipAmount)"
        }
        return returnVal
 */
        
    }
    
    func getTopController() -> UIViewController{
        var vc:UIViewController = UIViewController()
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
        }
    
    // topController should now be your topmost view controller
    
    //topController.present(alertController, animated: true, completion: nil)
            vc = topController
        }
        return vc
    }
    
    
    
    
    func playSaveSound(){
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1322
        AudioServicesPlaySystemSound (systemSoundID)
    }
    
    func playErrorSound(){
        // create a sound ID, in this case its the tweet sound.
        let systemSoundID: SystemSoundID = 1324
        AudioServicesPlaySystemSound (systemSoundID)
    }

    
    
    
}


//helper functions

func isValidEmail(testStr:String) -> Bool {
    // print("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
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
    
   // print("phone = \(_dirtyString)")
    cleanAddress = _dirtyString!.replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range: nil)
    cleanAddress = cleanAddress.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
    print("address Clean = \(cleanAddress)")
    
    if(cleanAddress == ""){
        cleanAddress = "No Address Saved"
    }
    return cleanAddress
}




func cleanPhoneNumber(_ _number:String!)->String{
    //print("clean phone number \(_number)")
    let stringArray = _number.components(
        separatedBy: CharacterSet.decimalDigits.inverted)
    print("clean phone stringArray \(stringArray)")
    let cleanPhone = stringArray.joined(separator: "")
    print("cleanPhone \(cleanPhone)")
    return cleanPhone
}


//phone number formatting



func format(phoneNumber sourcePhoneNumber: String) -> String? {
    
    // Remove any character that is not a number
    let numbersOnly = sourcePhoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    let length = numbersOnly.count
    let hasLeadingOne = numbersOnly.hasPrefix("1")
    
    // Check for supported phone number length
    guard length == 7 || length == 10 || (length == 11 && hasLeadingOne) else {
        return nil
    }
    
    let hasAreaCode = (length >= 10)
    var sourceIndex = 0
    
    // Leading 1
    var leadingOne = ""
    if hasLeadingOne {
        leadingOne = "1 "
        sourceIndex += 1
    }
    
    // Area code
    var areaCode = ""
    if hasAreaCode {
        let areaCodeLength = 3
        guard let areaCodeSubstring = numbersOnly.substring(start: sourceIndex, offsetBy: areaCodeLength) else {
            return nil
        }
        areaCode = String(format: "(%@) ", areaCodeSubstring)
        sourceIndex += areaCodeLength
    }
    
    // Prefix, 3 characters
    let prefixLength = 3
    guard let prefix = numbersOnly.substring(start: sourceIndex, offsetBy: prefixLength) else {
        return nil
    }
    sourceIndex += prefixLength
    
    // Suffix, 4 characters
    let suffixLength = 4
    guard let suffix = numbersOnly.substring(start: sourceIndex, offsetBy: suffixLength) else {
        return nil
    }
    
    return leadingOne + areaCode + prefix + "-" + suffix
}


func testFormat(sourcePhoneNumber: String) -> String {
    if let formattedPhoneNumber = format(phoneNumber: sourcePhoneNumber) {
        return formattedPhoneNumber
    }
    else {
        return "Format Error"
    }
}




class PaddedTextField: UITextField{
    
    var placeHolder:String!
    var canPaste:Bool = true
    
    override init(frame:CGRect)
    {
        super.init(frame:frame)
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
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
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if self.canPaste == false{
            if action == #selector(UIResponderStandardEditActions.increaseSize(_:)){
                return false
            }
            if action == #selector(UIResponderStandardEditActions.paste(_:)) {
                return false
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
    /*
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "paste:" {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
 */
    
    
    
    
    func reset() {
        self.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.backgroundColor = UIColor(hex:0xFFFFFF, op: 1)
        self.layer.borderWidth = 1
    }
    
    func error() {
        self.layer.borderColor = UIColor(hex:0xff0000, op: 1.0).cgColor
        self.backgroundColor = UIColor(hex:0xFFFFFF, op: 1)
        self.layer.borderWidth = 3
    }
    
    
    
    
    
    
    
    convenience init(placeholder:String!) {
        self.init()
        self.placeHolder = placeholder
        self.attributedPlaceholder = NSAttributedString(string:placeholder,attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex:0x333333, op: 0.75)])
    }
    
    convenience init(textValue:String!) {
        self.init()
        self.text = textValue
    }
    
    
}




class TableView: UITableView {
    
      
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        //self.layer.borderWidth = 1
        //self.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        //self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(hex:0xFFFFFF, op: 0.8)
        self.separatorColor = UIColor(hex:0x005100, op: 0.6)
        self.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
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
        let attr = NSDictionary(object: UIFont(name: "Avenir Next", size: 16.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        self.setTitleTextAttributes((attr as? [AnyHashable: Any] as! [NSAttributedString.Key : Any]), for: UIControl.State())
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
    
    /*
    func setStrikethrough(text:String, color:UIColor = UIColor.black) {
        let attributedText = NSAttributedString(string: text , attributes: [
            NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue, NSStrikethroughColorAttributeName: color])
            self.attributedText = attributedText
    }
 */
        
        
    
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
        super.drawText(in: rect.inset(by: insets))
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
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.layer.cornerRadius = 5.0
        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    convenience init(titleText:String!) {
        self.init()
        self.setTitle(titleText, for: UIControl.State())
    }
}

class BarButtonItem:UIBarButtonItem{
    
    let layoutVars:LayoutVars = LayoutVars()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        print("init of BarButtonItem")
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : self.layoutVars.backgroundColor], for: .normal)
        
        //self.tintColor = UIColor.white
        //super.setTitleColor( self.layoutVars.backgroundColor, for: .normal)
    }
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hex:0x005100, op: 1.0)
        self.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 16)!
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.layer.cornerRadius = 5.0
        self.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    convenience init(titleText:String!) {
        self.init()
        self.setTitle(titleText, for: UIControl.State())
    }
 */
    
}




/*
class IconButton:UIButton{
    
    
    //var iconBgView:UIView!
    var icon:UIImageView!
    //var label:UILabel!
    var layoutVars:LayoutVars = LayoutVars()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        
        
        //self.iconBgView = UIView()
        //self.label = UILabel()
        
        
        
        
        
        //iconBgView.translatesAutoresizingMaskIntoConstraints = true
        //iconBgView.backgroundColor = layoutVars.backgroundColor
        //self.addSubview(iconBgView)
        
        /*
        label.translatesAutoresizingMaskIntoConstraints = true
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Helvetica Neue", size: 16)!
        label.textColor = UIColor.white
        self.addSubview(label)
 */
        
        
        self.backgroundColor = UIColor(hex:0x005100, op: 1.0)
        self.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 16)!
        self.setTitleColor(UIColor.white, for: UIControlState())
        
        self.layer.cornerRadius = 5.0
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        
    }
    
    convenience init(titleText:String!,iconName:String!) {
        self.init()
        print("title = \(titleText)")
        self.setTitle(titleText!, for: UIControlState())
        //label.text = titleText
        
        icon = UIImageView()
        icon.backgroundColor = UIColor.clear
        icon.contentMode = .scaleAspectFill
        
        let img = UIImage(named:iconName)
        icon.image = img
        self.addSubview(icon)
        
        
    }
    
    override func layoutSubviews() {
        print("layoutSubviews")
        print("button width = \(self.frame.width) height = \(self.frame.height)")
        //iconBgView.frame =  CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
        //label.frame =  CGRect(x: 0, y: 0, width: self.frame.width - 34, height: self.frame.height)
        icon.frame = CGRect(x: 1.0, y: 1.0, width: self.frame.height - 2.0, height: self.frame.height - 2.0)
        //self.titleEdgeInsets = UIEdgeInsetsMake(0.0, self.frame.height + 4, 0.0, 0.0)
    }
    
    
    
    
    
}

*/









class Cell:UITableViewCell {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
    }
}


class SearchBarContainerView: UIView {
    
    let searchBar: UISearchBar
    
    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        
        addSubview(searchBar)
    }
    
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}






/////////////////////    Helper Methods     //////////////////////////////////

/*
func simpleAlert(_vc:UIViewController,_title:String,_message:String?){
    print("simpleAlert: \(String(describing: _message))")
    let alertController = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
        (result : UIAlertAction) -> Void in
        print("OK")
    }
    alertController.addAction(okAction)
    
    
    
    
    
    
    
    
    
}
 
 */






extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }
        
        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }
        
        return String(self[substringStartIndex ..< substringEndIndex])
    }
}


////  Calling, Emailing .....






func callPhoneNumber(_ _number:String){
    print("Call \(_number)")
    
    
    
    if (cleanPhoneNumber(_number) != "No Number Saved"){
        
        UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(_number))")! as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    }
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
    print("url: \(String(describing: url))")
    UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
    
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
    let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
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
    UIApplication.shared.open(URL(string: "http://\(_url)")!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
        spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        spinner.color = layoutVars.buttonColor1
        spinnerParentView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: layoutVars.fullHeight))
        spinnerParentView.backgroundColor = layoutVars.backgroundColor
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
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
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
    static let sessionKey = ""
    
}


extension UIImage {
    
    public func fixedOrientation() -> UIImage {
        
        //print("fixedOrientation")
         //print("imageOrientation = \(imageOrientation.rawValue)")
        
        if imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        }
        
        switch imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
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
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
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



/*
extension Date {
    
    static func today() -> Date {
        return Date()
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.index(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
}
 
 */


extension Date {

    var startOfWeek: Date {
        let date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        let dslTimeOffset = NSTimeZone.local.daylightSavingTimeOffset(for: date)
        return date.addingTimeInterval(dslTimeOffset)
    }
    
    var endOfWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 6, to: self.startOfWeek)!
        
    }
    
    
    var startOfNextWeek: Date {
        let date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        let dslTimeOffset = NSTimeZone.local.daylightSavingTimeOffset(for: date)
        let startOfWeek = date.addingTimeInterval(dslTimeOffset)
        return Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
    }
    
    var endOfNextWeek: Date {
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: self.startOfWeek)!
        return Calendar.current.date(byAdding: .day, value: 7, to: endOfWeek)!
    }
    
    
    var startOfLastWeek: Date {
        let date = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        let dslTimeOffset = NSTimeZone.local.daylightSavingTimeOffset(for: date)
        let startOfWeek = date.addingTimeInterval(dslTimeOffset)
        return Calendar.current.date(byAdding: .day, value: -7, to: startOfWeek)!
    }
    
    var endOfLastWeek: Date {
        let endOfWeek = Calendar.current.date(byAdding: .second, value: 604799, to: self.startOfWeek)!
        return Calendar.current.date(byAdding: .day, value: -7, to: endOfWeek)!
    }
    
    
    
    
    func addNumberOfDaysToDate(_numberOfDays: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: _numberOfDays, to: self)!
    }
    
    
    
    
}


internal extension DateComponents {
    mutating func to12am() {
        self.hour = 0
        self.minute = 0
        self.second = 0
    }
    
    mutating func to12pm(){
        self.hour = 23
        self.minute = 59
        self.second = 59
    }
}


//for alamofire 4







/*
extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}
extension Date {
    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
}
 */


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}


/*

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}
*/

