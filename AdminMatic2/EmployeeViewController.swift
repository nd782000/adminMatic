//
//  EmployeeViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON
//import Nuke




class EmployeeViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ImageViewDelegate, ImageLikeDelegate  {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    
    
    
    var employeeJSON: JSON!
    var employee:Employee!
       
    var optionsButton:UIBarButtonItem!
    var tapBtn:UIButton!
    
    //employee info
    var employeeImage:UIImageView!
    var activityView:UIActivityIndicatorView!

    var employeeLbl:GreyLabel!
    var employeePhoneBtn:UIButton!
    var phoneNumberClean:String!
    
    var email: String = "No Email Found"
    var emailName: String = ""
    
    var emailBtn:Button!
    
    var departmentsBtn:Button!
    var crewsBtn:Button!
    var shiftsBtn:Button!
    var payrollBtn:Button!
    
    
    //employee images
    var totalImages:Int!
    var images: JSON!
    var imageArray:[Image] = []
    
    var noImagesLbl:Label = Label()
    
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView?
    
    var currentImageIndex:Int = 0
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    
    var order:String = "ID DESC"
    
    
    var lazyLoad = 0
    var limit = 100
    var offset = 0
    var batch = 0
    
    var userTxt:PaddedTextField!
    var passTxt:PaddedTextField!
    
    var logInOutBtn:Button!

    var keyBoardShown:Bool = false

    var imageFullViewController:ImageFullViewController!
    var departmentListViewController:DepartmentListViewController!
    var crewListViewController:CrewListViewController!
    var shiftsViewController:ShiftsViewController!
    var payrollEntryViewController:PayrollEntryViewController!
    
    
    
    init(_employee:Employee){
        super.init(nibName:nil,bundle:nil)
        print("init _employeeID = \(_employee.ID)")
        self.employee = _employee
        
        print("emp view init ID = \(self.employee.ID)")
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.indicator = SDevIndicator.generate(self.view)!
        
        getEmployeeData(_id:self.employee.ID!)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        print("view will appear")
        

        
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Employee"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func getEmployeeData(_id:String){
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        
        
        
        Alamofire.request(API.Router.employee(["empID":_id as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                print("JSON: \(json)")
                self.employeeJSON = JSON(json)
                
                self.parseEmployeeJSON()
                
                
            }
        }
    }
    
    func parseEmployeeJSON(){
        
        print("parseEmployeeJSON")
        
        self.employee = Employee(_ID: self.employeeJSON["employees"][0]["ID"].stringValue, _name: self.employeeJSON["employees"][0]["name"].stringValue, _lname: self.employeeJSON["employees"][0]["lname"].stringValue, _fname: self.employeeJSON["employees"][0]["fname"].stringValue, _username: self.employeeJSON["employees"][0]["username"].stringValue, _pic: self.employeeJSON["employees"][0]["pic"].stringValue, _phone: self.employeeJSON["employees"][0]["phone"].stringValue, _depID: self.employeeJSON["employees"][0]["depID"].stringValue, _payRate: self.employeeJSON["employees"][0]["payRate"].stringValue, _appScore: self.employeeJSON["employees"][0]["appScore"].stringValue, _userLevel: self.employeeJSON["employees"][0]["level"].intValue, _userLevelName: self.employeeJSON["employees"][0]["levelName"].stringValue)
        
        
        self.email = self.employeeJSON["employees"][0]["email"].stringValue
        
        print("email = \(self.employeeJSON["employees"][0]["email"].stringValue)")
        
        self.getImages()
    }
    
    
    func getImages(){
        print("get images")
        
        let parameters:[String:String]
        parameters = ["loginID": "\(self.appDelegate.loggedInEmployee?.ID)","limit": "\(self.limit)","offset": "\(self.offset)", "order":self.order,"uploadedBy": self.employee.ID] as! [String : String]
        
       // print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/images.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("images response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                if let json = response.result.value {
                   // print("JSON: \(json)")
                    self.images = JSON(json)
                    //self.parseJSON()
                    self.parseEmployeeImagesJSON()
                    
                    self.indicator.dismissIndicator()
                }
                
                
        }
    }
    
    
    func parseEmployeeImagesJSON(){
        let jsonCount = self.images["images"].count
        self.totalImages = jsonCount
        print("Employee image count: \(jsonCount)")
        
        let thumbBase:String = self.images["thumbBase"].stringValue
        let mediumBase:String = self.images["mediumBase"].stringValue
        let rawBase:String = self.images["rawBase"].stringValue
        
        for i in 0 ..< jsonCount {
            
            let thumbPath:String = "\(thumbBase)\(self.images["images"][i]["fileName"].stringValue)"
            let mediumPath:String = "\(mediumBase)\(self.images["images"][i]["fileName"].stringValue)"
            let rawPath:String = "\(rawBase)\(self.images["images"][i]["fileName"].stringValue)"
            
            //create a item object
            //print("create an image object \(i)")
            
            let image = Image(_id: self.images["images"][i]["ID"].stringValue,_thumbPath: thumbPath, _mediumPath: mediumPath,_rawPath: rawPath,_name: self.images["images"][i]["name"].stringValue,_width: self.images["images"][i]["width"].stringValue,_height: self.images["images"][i]["height"].stringValue,_description: self.images["images"][i]["description"].stringValue,_dateAdded: self.images["images"][i]["dateAdded"].stringValue,_createdBy: self.images["images"][i]["createdByName"].stringValue,_type: self.images["images"][i]["type"].stringValue)
            
            image.customer = self.images["images"][i]["customer"].stringValue
            image.customerName = self.images["images"][i]["customerName"].stringValue
            image.tags = self.images["images"][i]["tags"].stringValue
            image.liked = self.images["images"][i]["liked"].stringValue
            image.likes = self.images["images"][i]["likes"].stringValue
            image.index = i
            
            self.imageArray.append(image)
            
        }
        
        if(lazyLoad == 0){
            self.layoutViews()
        }else{
            lazyLoad = 0
            self.imageCollectionView?.reloadData()
        }
        
        if self.imageArray.count == 0{
            self.noImagesLbl.isHidden = false
        }else{
            self.noImagesLbl.isHidden = true
        }
    }
    
    
    
    func layoutViews(){
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.indicator.dismissIndicator()
        
        //only show option button to profile of logged in user
        if self.employee.ID == appDelegate.loggedInEmployee?.ID{
            optionsButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(EmployeeViewController.displayEmployeeOptions))
            navigationItem.rightBarButtonItem = optionsButton
        }
        
        
        print("layoutViews")
       
        self.employeeImage = UIImageView()
        
       
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = CGPoint(x: self.employeeImage.frame.size.width / 2, y: self.employeeImage.frame.size.height / 2)
        employeeImage.addSubview(activityView)
        activityView.startAnimating()
        
        
        /*
        let imgURL:URL = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+self.employee.pic!)!
    
        Nuke.loadImage(with: imgURL, into: self.employeeImage!){ 
            print("nuke loadImage")
            self.employeeImage?.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            
            let image = Image(_path: self.employee.pic)
            
            self.imageFullViewController = ImageFullViewController(_image: image)
            
        }
 */
        
        self.tapBtn = Button()
        self.tapBtn.translatesAutoresizingMaskIntoConstraints = false
        self.tapBtn.addTarget(self, action: #selector(EmployeeViewController.showFullScreenImage), for: UIControlEvents.touchUpInside)
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControlState.normal)
        self.view.addSubview(self.tapBtn)
        
        self.employeeImage.layer.cornerRadius = 5.0
        self.employeeImage.layer.borderWidth = 2
        self.employeeImage.layer.borderColor = layoutVars.borderColor
        self.employeeImage.clipsToBounds = true
        self.employeeImage.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.employeeImage)
        
        //name
        self.employeeLbl = GreyLabel()
        self.employeeLbl.text = self.employee.name
        self.employeeLbl.font = layoutVars.labelFont
        self.view.addSubview(self.employeeLbl)
        
        //phone
        self.phoneNumberClean = cleanPhoneNumber(self.employee.phone)
        
        self.employeePhoneBtn = Button()
        self.employeePhoneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.employeePhoneBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 36.0, 0.0, 0.0)
        
        
        self.employeePhoneBtn.setTitle(testFormat(sourcePhoneNumber: self.employee.phone), for: UIControlState.normal)
        self.employeePhoneBtn.addTarget(self, action: #selector(EmployeeViewController.handlePhone), for: UIControlEvents.touchUpInside)
        
        let phoneIcon:UIImageView = UIImageView()
        phoneIcon.backgroundColor = UIColor.clear
        phoneIcon.frame = CGRect(x: -35, y: -4, width: 28, height: 28)
        let phoneImg = UIImage(named:"phoneIcon.png")
        phoneIcon.image = phoneImg
        self.employeePhoneBtn.titleLabel?.addSubview(phoneIcon)
        
        self.view.addSubview(self.employeePhoneBtn)

        self.emailBtn = Button()
        self.emailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.emailBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 36.0, 0.0, 0.0)
        
        
        self.emailBtn.setTitle(self.email, for: UIControlState.normal)
        if self.email != "No Email Found" {
            self.emailBtn.addTarget(self, action: #selector(CustomerViewController.emailHandler), for: UIControlEvents.touchUpInside)
        }
        
        let emailIcon:UIImageView = UIImageView()
        emailIcon.backgroundColor = UIColor.clear
        emailIcon.contentMode = .scaleAspectFill
        emailIcon.frame = CGRect(x: -35, y: -4, width: 28, height: 28)
        let emailImg = UIImage(named:"emailIcon.png")
        emailIcon.image = emailImg
        self.emailBtn.titleLabel?.addSubview(emailIcon)
        
        
        self.view.addSubview(self.emailBtn)
        
        
        self.departmentsBtn = Button()
        self.departmentsBtn.setTitle("Departments", for: UIControlState.normal)
        self.departmentsBtn.addTarget(self, action: #selector(self.showDepartments), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.departmentsBtn)
        
        self.crewsBtn = Button()
        self.crewsBtn.setTitle("Crews", for: UIControlState.normal)
        self.crewsBtn.addTarget(self, action: #selector(self.showCrews), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.crewsBtn)
        
        self.shiftsBtn = Button()
        self.shiftsBtn.setTitle("Shifts", for: UIControlState.normal)
        self.shiftsBtn.addTarget(self, action: #selector(self.showShifts), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.shiftsBtn)
        
        self.payrollBtn = Button()
        self.payrollBtn.setTitle("Payroll", for: UIControlState.normal)
        self.payrollBtn.addTarget(self, action: #selector(self.showPayroll), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.payrollBtn)
        
        
        
        //Images
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50), collectionViewLayout: layout)
        imageCollectionView?.layer.cornerRadius = 4.0
        
        self.imageCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        imageCollectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        imageCollectionView?.dataSource = self
        imageCollectionView?.delegate = self
        imageCollectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView?.backgroundColor = UIColor.darkGray
        self.view.addSubview(imageCollectionView!)
        
        self.edgesForExtendedLayout = UIRectEdge.top
        
        self.noImagesLbl.text = "No Images Uploaded"
        self.noImagesLbl.textColor = UIColor.white
        self.noImagesLbl.textAlignment = .center
        self.noImagesLbl.font = layoutVars.largeFont
        self.view.addSubview(self.noImagesLbl)
        
        self.userTxt = PaddedTextField(placeholder: "User Name")
        self.userTxt.tag = 1
        self.userTxt.text = self.employee.username
        self.userTxt.delegate = self
        self.view.addSubview(self.userTxt)
        self.userTxt.autocorrectionType = UITextAutocorrectionType.no
        
        
        self.passTxt = PaddedTextField(placeholder: "Password")
        self.passTxt.tag = 2
        self.passTxt.returnKeyType = .done
        self.passTxt.delegate = self
        self.passTxt.isSecureTextEntry = true
        self.view.addSubview(self.passTxt)
        
        
        self.logInOutBtn = Button()
        
        if(appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) == self.employee.ID){
            self.logInOutBtn.setTitle("Log Out (\(self.employee.fname!))", for: UIControlState.normal)
            self.logInOutBtn.addTarget(self, action: #selector(self.logOut), for: UIControlEvents.touchUpInside)
        }else{
            //not logged in
            self.logInOutBtn.setTitle("Log In (\(self.employee.fname!))", for: UIControlState.normal)
            self.logInOutBtn.addTarget(self, action: #selector(EmployeeViewController.attemptLogIn), for: UIControlEvents.touchUpInside)
        }
        self.view.addSubview(self.logInOutBtn)
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let viewsDictionary = [
            "image":self.employeeImage,
            "tapBtn":self.tapBtn,
            "name":self.employeeLbl,
            "phone":self.employeePhoneBtn,
            "email":self.emailBtn,
            "departmentsBtn":self.departmentsBtn,
            "crewsBtn":self.crewsBtn,
            "shiftsBtn":self.shiftsBtn,
            "payrollBtn":self.payrollBtn,
            "imageCollection":self.imageCollectionView!,
            "noImagesLbl":self.noImagesLbl,
            "userTxt":self.userTxt,
            "passTxt":self.passTxt,
            "logInBtn":logInOutBtn
            
            ] as [String:Any]
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[name]-10-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tapBtn(100)]", options: [], metrics: nil, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[phone]-10-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[email]-10-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[departmentsBtn(halfWidth)]-5-[crewsBtn]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[shiftsBtn(halfWidth)]-5-[payrollBtn]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[imageCollection]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[noImagesLbl]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[userTxt(halfWidth)]-5-[passTxt]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[logInBtn]-10-|", options: [], metrics: nil, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[image(100)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[tapBtn(100)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[name(30)][phone(30)]-10-[email(30)]-[departmentsBtn(30)]-[shiftsBtn(30)]-[imageCollection]-[userTxt(30)]-[logInBtn(40)]-16-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[name(30)][phone(30)]-10-[email(30)]-[crewsBtn(30)]-[payrollBtn(30)]-[imageCollection]-[passTxt(30)]-[logInBtn(40)]-16-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[name(30)][phone(30)]-10-[email(30)]-[crewsBtn(30)]-[payrollBtn(30)]-20-[noImagesLbl(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
    }
    
    
    @objc func displayEmployeeOptions(){
        print("display Options")
        
        
        let actionSheet = UIAlertController(title: "Employee Options", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.view.backgroundColor = UIColor.white
        actionSheet.view.layer.cornerRadius = 5;
        
        actionSheet.addAction(UIAlertAction(title: "Change Password", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            print("display Change Password View")
            
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Upload Signature", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            print("Show Signature View")
            
            let signatureViewController:SignatureViewController = SignatureViewController(_employee: self.employee)
            self.navigationController?.pushViewController(signatureViewController, animated: false )
            
            
           
        }))
        
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert:UIAlertAction!) -> Void in
        }))
        
        
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.present(actionSheet, animated: true, completion: nil)
            
            break
        // It's an iPhone
        case .pad:
            let nav = UINavigationController(rootViewController: actionSheet)
            nav.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = nav.popoverPresentationController as UIPopoverPresentationController?
            actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
            
            self.present(nav, animated: true, completion: nil)
            break
        // It's an iPad
        case .unspecified:
            break
        default:
            self.present(actionSheet, animated: true, completion: nil)
            break
            
            // Uh, oh! What could it be?
        }
        
        
    }
    
    
    
    
    
    
    @objc func showDepartments(){
        print("show departments")
        
        if(appDelegate.loggedInEmployee != nil){
            self.departmentListViewController = DepartmentListViewController(_empID: self.employee.ID, _empFirstName: self.employee.fname)
            navigationController?.pushViewController(self.departmentListViewController, animated: false )
        }else{
            appDelegate.requireLogIn(_destination: "departments", _vc:self)
        }
        
        
        
        
        
        
    }
    
    @objc func showCrews(){
        print("show crews")
        if(appDelegate.loggedInEmployee != nil){
            self.crewListViewController = CrewListViewController(_empID: self.employee.ID, _empFirstName: self.employee.fname)
            navigationController?.pushViewController(self.crewListViewController, animated: false )
        }else{
            appDelegate.requireLogIn(_destination: "crews", _vc:self)
        }
    }
    
    @objc func showShifts(){
        print("show shifts")
        if(appDelegate.loggedInEmployee != nil){
            self.shiftsViewController = ShiftsViewController(_empID: self.employee.ID, _empFirstName: self.employee.fname)
            navigationController?.pushViewController(self.shiftsViewController, animated: false )
        }else{
            appDelegate.requireLogIn(_destination: "shifts", _vc:self)
        }
    }
    
    @objc func showPayroll(){
        print("show payroll")
        if(appDelegate.loggedInEmployee != nil){
            self.payrollEntryViewController = PayrollEntryViewController(_employee: self.employee)
            navigationController?.pushViewController(self.payrollEntryViewController, animated: false )
        }else{
            appDelegate.requireLogIn(_destination: "payroll", _vc:self)
        }
    }
    
    
    //image methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
            let totalHeight: CGFloat = ((self.view.frame.width - 20) / 3 - 1)
            let totalWidth: CGFloat = ((self.view.frame.width - 20) / 3 - 1)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("making cells")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        cell.activityView.startAnimating()
        cell.imageView.image = nil
        
        //print("name = \(self.imageArray)")
        
       // print("name = \(self.imageArray[indexPath.row].name!)")
        cell.textLabel.text = " \(self.imageArray[indexPath.row].customerName)"
        cell.image = self.imageArray[indexPath.row]
        cell.activityView.startAnimating()
        
        //print("thumb = \(self.imageArray[indexPath.row].thumbPath!)")
        
        
        /*
        let imgURL:URL = URL(string: self.imageArray[indexPath.row].thumbPath!)!
        
        //print("imgURL = \(imgURL)")
        
        
        
        Nuke.loadImage(with: imgURL, into: cell.imageView){
            //print("nuke loadImage")
            cell.imageView?.handle(response: $0, isFromMemoryCache: $1)
            cell.activityView.stopAnimating()
            
        }
 */
        
        
        
        //print("view width = \(imageCollectionView?.frame.width)")
        //print("cell width = \(cell.frame.width)")
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
        //print("name = \(currentCell.image.name)")
        
        imageDetailViewController = ImageDetailViewController(_image: currentCell.image, _ID: currentCell.image.ID)
        imageDetailViewController.imageFullViewController.delegate = self
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        imageDetailViewController.imageLikeDelegate = self
        
        
        currentImageIndex = indexPath.row
        
        
    }
    
    func getPrevNextImage(_next:Bool){
        if(_next == true){
            if(currentImageIndex + 1) > (self.imageArray.count - 1){
                currentImageIndex = 0
                imageDetailViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.layoutViews()
                imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.imageFullViewController.layoutViews()
                
                
            }else{
                currentImageIndex = currentImageIndex + 1
                imageDetailViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.layoutViews()
                imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.imageFullViewController.layoutViews()
            }
            
        }else{
            if(currentImageIndex - 1) < 0{
                currentImageIndex = self.imageArray.count - 1
                imageDetailViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.layoutViews()
                imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.imageFullViewController.layoutViews()
            }else{
                currentImageIndex = currentImageIndex - 1
                imageDetailViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.layoutViews()
                imageDetailViewController.imageFullViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.imageFullViewController.layoutViews()
            }
        }
        
        imageCollectionView?.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0),
                                          at: .top,
                                          animated: false)
        
        
        
    }

    
    func refreshImages(_images:[Image], _scoreAdjust:Int){
        print("refreshImages")
        
        for insertImage in _images{
            
            imageArray.insert(insertImage, at: 0)
        }
        
        
        
        imageCollectionView?.reloadData()
        
        imageCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
    }
    
    
    func updateLikes(_index:Int, _liked:String, _likes:String){
        print("update likes _liked: \(_liked)  _likes\(_likes)")
        imageArray[_index].liked = _liked
        imageArray[_index].likes = _likes
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.bounds.maxY == scrollView.contentSize.height) {
            print("scrolled to bottom")
            lazyLoad = 1
            batch += 1
            offset = batch * limit
            self.indicator = SDevIndicator.generate(self.view)!
            
            getImages()
        }
    }
    
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        
        self.passTxt.reset()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
       // print("keyboard will show")
        
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            // tableView.contentInset.bottom = keyboardFrame.height
            if(!keyBoardShown){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    // var fabricTopFrame = self.fabricTop.frame
                    self.view.frame.origin.y -= keyboardFrame.height
                    
                    
                }, completion: { finished in
                    // //print("Napkins opened!")
                })
            }
            
            
        }
        keyBoardShown = true
    }

    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if(keyBoardShown){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y = 0
            
            }, completion: { finished in
            ////print("Napkins opened!")
            })
        }
        keyBoardShown = false
    }
    
    
    func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    
    
    @objc func attemptLogIn(){
        
        //print("setLoginStatus")
        self.passTxt.reset()
        
        
        
        if(!self.userTxt.text!.isEmpty && !self.passTxt.text!.isEmpty){
            
            indicator = SDevIndicator.generate(self.view)!
            
            
            
            //cache buster
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            
            
            Alamofire.request(API.Router.logIn(["user":self.userTxt.text! as AnyObject,"pass":self.passTxt.text! as AnyObject, "cb":timeStamp as AnyObject])).responseJSON(){
                
            response in
                
                //print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                //print(response.result)   // result of response serialization
                
                if let json = response.result.value {
                    print("Log In Json = \(json)")
                    let LogInJson = JSON(json)
                    
                    let loggedIn = LogInJson["loggedIn"].stringValue
                    
                    if(loggedIn == "true"){
                        self.logInOutBtn.setTitle("Log Out (\(self.employee.name!))", for: UIControlState.normal)
                        print("Login Success")
                        self.appDelegate.loggedInEmployee = self.employee
                        self.appDelegate.scheduleViewController.personalScheduleArray.removeAll()
                        self.appDelegate.scheduleViewController.personalHistoryArray.removeAll()
                        self.appDelegate.scheduleViewController.personalHistoryLoaded = false
                        self.appDelegate.scheduleViewController.personalScheduleLoaded = false
                        
                        self.logInOutBtn.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
                        self.logInOutBtn.addTarget(self, action: #selector(self.logOut), for: UIControlEvents.touchUpInside)
                        
                        self.userTxt.resignFirstResponder()
                        self.passTxt.resignFirstResponder()
                        self.passTxt.text = ""
                        
                        print("set values for appDelegate id = \(self.employee.ID)")
                        
                        
                        self.appDelegate.defaults = UserDefaults.standard
                        self.appDelegate.defaults.setValue(self.employee.ID, forKey: loggedInKeys.loggedInId)
                       // self.appDelegate.defaults.setValue(self.employee.name, forKey: loggedInKeys.loggedInName)
                        self.appDelegate.defaults.synchronize()
                        
                    }else{
                        
                        self.passTxt.error()
                    }
                }
                
                self.indicator.dismissIndicator()
                
            }
        }else{
            self.passTxt.error()
        }
        
        
    }
    
  
   
    @objc func logOut() {
        
        //print("setLoginStatus")
        
        self.logInOutBtn.setTitle("Log In (\(self.employee.name!))", for: UIControlState.normal)
        
        self.appDelegate.loggedInEmployee = nil
        
        
        self.appDelegate.scheduleViewController.personalScheduleArray.removeAll()
        self.appDelegate.scheduleViewController.personalHistoryArray.removeAll()
        self.appDelegate.scheduleViewController.personalHistoryLoaded = false
        self.appDelegate.scheduleViewController.personalScheduleLoaded = false
        
        
        self.logInOutBtn.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)
        self.logInOutBtn.addTarget(self, action: #selector(EmployeeViewController.attemptLogIn), for: UIControlEvents.touchUpInside)
        
        self.passTxt.text = ""
        
        
        self.appDelegate.defaults = UserDefaults.standard
        self.appDelegate.defaults.setValue("0", forKey: loggedInKeys.loggedInId)
        self.appDelegate.defaults.synchronize()
    
    }
    
 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //print("NEXT")
        switch (textField.tag) {
        case userTxt.tag:
            passTxt.becomeFirstResponder()
            break;
        case passTxt.tag:
            textField.resignFirstResponder()
            break;
        default:
            break;
        }
        return true
    }
    
    
    
    @objc func showFullScreenImage(_ sender: UITapGestureRecognizer){
        
        print("show full screen")
        
        navigationController?.pushViewController(imageFullViewController, animated: false )
    }
    
    
    
    @objc func handlePhone(){
        
        callPhoneNumber(self.phoneNumberClean)
        
        
    }
    
    @objc func emailHandler(){
        sendEmail(self.email)
    }
    
    
   
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    func showCustomerImages(_customer:String){
        print("show customer images cust: \(_customer)")
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
