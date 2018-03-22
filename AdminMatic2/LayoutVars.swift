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





class LayoutVars: UIViewController {
    
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var fullWidth:CGFloat! = UIScreen.main.bounds.width
    var halfWidth:CGFloat! = (UIScreen.main.bounds.width - 25)/2
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
    var smallBoldFont:UIFont = UIFont(name: "HelveticaNeue-Bold", size: 20)!
    var extraSmallFont:UIFont = UIFont(name: "Helvetica Neue", size: 14)!
    var buttonFont:UIFont = UIFont(name: "Helvetica Neue", size: 18)!
    var textFieldFont:UIFont = UIFont(name: "Helvetica Neue", size: 12)!

    var inputHeight = 50
    
    var defaultImage : UIImage = UIImage(named:"cameraIcon.png")!
    
    let rawBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/raw/"
    let mediumBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/medium/"
    let thumbBase : String = "https://www.atlanticlawnandgarden.com/uploads/general/thumbs/"
    
    
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
 
    
   
    
    
    
   
    
    
    func grantAccess(_level:Int,_view:UIViewController)->Bool{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if (appDelegate.loggedInEmployee?.userLevel)! <= _level{
        
            simpleAlert(_vc: _view, _title: "Access Denied", _message: "Your user level (\(appDelegate.loggedInEmployee!.userLevelName!)) does not allow access to this feature.")
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
        
        
        
        print("equipmentService.nextValue = \(_equipmentService.nextValue)")
        print("equipmentService.creationDate = \(_equipmentService.creationDate)")
        print("dbDate = \(String(describing: dbDate))")
        
        
        
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
        self.attributedPlaceholder = NSAttributedString(string:placeholder,attributes:[NSAttributedStringKey.foregroundColor: UIColor(hex:0x333333, op: 0.75)])
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
        let attr = NSDictionary(object: UIFont(name: "Avenir Next", size: 16.0)!, forKey: NSAttributedStringKey.font as NSCopying)
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
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

func simpleAlert(_vc:UIViewController,_title:String,_message:String?){
    print("simpleAlert: \(String(describing: _message))")
    let alertController = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.alert)
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
        (result : UIAlertAction) -> Void in
        print("OK")
    }
    alertController.addAction(okAction)
    _vc.present(alertController, animated: true, completion: nil)
    
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
        
        UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(_number))")! as URL, options: [:], completionHandler: nil)
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
            transform = transform.rotated(by: CGFloat.pi)
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi / 2))
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

