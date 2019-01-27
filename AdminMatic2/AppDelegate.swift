//
//  AppDelegate.swift
//  AdminMatic2
//
//  Created by Nick on 12/18/16.
//  Copyright © 2016 Nick. All rights reserved.
//



//  Find Compile Time Jam Ups Tool
// run in terminal set to same folder as app project
// returns text file of compliled functions and their compile time sorted slowest to fastest
// xcodebuild -workspace AdminMatic2.xcworkspace -scheme AdminMatic2 clean build | grep [1-9].[0-9]ms | sort -nr > culprits.txt


import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON
//import Nuke
import AVFoundation


import SystemConfiguration



protocol MenuDelegate{
    func menuChange(_ menuItem:Int)
}

protocol TimeEntryDelegate{
    func editStartTime()
    func editStopTime()
    func editBreakTime()
    
}


struct defaultsKeys {
    static let loggedInId = ""
    static let loggedInName = ""
    static let loggedInPic = ""
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MenuDelegate{
    
    var window: UIWindow?
    
    var layoutVars:LayoutVars = LayoutVars()
    var appVersion:String = "1.4.3"
    var navigationController:UINavigationController!
    var homeViewController:HomeViewController!
    var employeeListViewController:EmployeeListViewController!
    var customerListViewController:CustomerListViewController!
    var vendorListViewController:VendorListViewController!
    var itemListViewController:ItemListViewController!
    var employeeViewController:EmployeeViewController!
    var scheduleViewController:ScheduleViewController!
    var imageCollectionViewController:ImageCollectionViewController!
    var equipmentListViewController:EquipmentListViewController!
    var performanceViewController:PerformanceViewController!
    var leadListViewController:LeadListViewController!
    var contractListViewController:ContractListViewController!
    //var bugsListViewController:BugsListViewController!
    
    
    //var underConstructionViewController:UnderConstructionViewController!

    
    var fieldsJson:JSON!
    var zones:[Zone] = []
    
    var departments:[Department] = []
    var crews:[Crew] = []
    
    var employees:JSON!
    var employeeArray:[Employee] = []
    
    var salesRepArray:[Employee] = []
    
    var salesRepIDArray:[String] = []
    var salesRepNameArray:[String] = []
    
    //var chargeTypeArray:[String] = []
    //var invoiceTypeArray:[String] = []
    //var scheduleTypeArray:[String] = []
    
    
    var loggedInEmployee:Employee?
    var loggedInEmployeeJSON: JSON!

    
    
    var messageView:UIView?
    var messageImageView:UIImageView = UIImageView()
    var messageLabel:InfoLabel?
    var messageCloseBtn:Button?
   
    
    var defaults:UserDefaults!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        defaults = UserDefaults.standard
        
        self.messageView = UIView()
        
        getEmployeeList()
        
        
        return true
    }
    
    func getEmployeeList(){
        
        
        if(defaults.string(forKey: loggedInKeys.loggedInId) != nil){
            print("stored login data detected")
            if(Int(defaults.string(forKey: loggedInKeys.loggedInId)!)! > 0){
                getLoggedInEmployeeData(_id: defaults.string(forKey: loggedInKeys.loggedInId)!)
                
            }
        }
        
        
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        Alamofire.request(API.Router.fields(["cb":timeStamp as AnyObject])).responseJSON() {
            response in
            ////print(response.request ?? "default request")  // original URL request
            print(response.response ?? "default response") // URL response
            print(response.data ?? "default data")     // server data
            print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                jsonDataHolder.jsonData = JSON(json)
                self.fieldsJson = JSON(json)
                
                let zonesCount:Int = self.fieldsJson["zones"].count
                
                for i in 0 ..< zonesCount {
                    
                    let zone = Zone(_ID: self.fieldsJson["zones"][i][0].stringValue, _name: self.fieldsJson["zones"][i][1].stringValue)
                    
                    print("zone.id = \(zone.ID)")
                    print("zone.name = \(zone.name)")
                    self.zones.append(zone)
                    
                }
                
                
                let departmentCount:Int = self.fieldsJson["departments"].count
                print("dept count = \(departmentCount)")
                for n in 0 ..< departmentCount {
                    
                    let department = Department(_ID: self.fieldsJson["departments"][n]["id"].stringValue, _name: self.fieldsJson["departments"][n]["name"].stringValue, _status: self.fieldsJson["departments"][n]["status"].stringValue, _color: self.fieldsJson["departments"][n]["color"].stringValue, _depHead: self.fieldsJson["departments"][n]["depHead"].stringValue)
                    
                    //print("zone.id = \(zone.ID)")
                    //print("zone.name = \(zone.name)")
                    self.departments.append(department)
                    
                }
                
                
                let crewCount:Int = self.fieldsJson["crews"].count
                print("crew count = \(crewCount)")
                for p in 0 ..< crewCount {
                    
                    let crew = Crew(_ID: self.fieldsJson["crews"][p]["ID"].stringValue, _name: self.fieldsJson["crews"][p]["name"].stringValue)
                    
                    
                    //print("zone.id = \(zone.ID)")
                    //print("zone.name = \(zone.name)")
                    self.crews.append(crew)
                    
                }
                
                /*
                let chargeCount:Int = self.fieldsJson["chargeType"].count
                for i in 0 ..< chargeCount {
                    let charge = self.fieldsJson["charge"][i].stringValue
                    self.chargeTypeArray.append(charge)
                }
                
                let invoiceCount:Int = self.fieldsJson["invoiceType"].count
                for i in 0 ..< invoiceCount {
                    let invoice = self.fieldsJson["invoiceType"][i].stringValue
                    self.invoiceTypeArray.append(invoice)
                }
                
                let scheduleCount:Int = self.fieldsJson["scheduleType"].count
                for i in 0 ..< scheduleCount {
                    let schedule = self.fieldsJson["scheduleType"][i].stringValue
                    self.scheduleTypeArray.append(schedule)
                }
                */
            }
        }
        
        
        self.homeViewController = HomeViewController()
        
        
        self.employeeListViewController = EmployeeListViewController()
        self.employeeListViewController.delegate = self
        
        self.employeeArray = []
        self.salesRepIDArray = []
        self.salesRepNameArray = []
        
        
        //Get employee list
        var parameters:[String:String]
        parameters = ["cb":"\(timeStamp)"]
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/employees.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("employee response = \(response)")
            }
            .responseJSON() {
                response in
                if let json = response.result.value {
                    self.employees = JSON(json)
                    //self.employeeListViewController.layoutViews()
                    
                    let jsonCount = self.employees["employees"].count
                    //self.totalItems = jsonCount
                    print("JSONcount: \(jsonCount)")
                    for i in 0 ..< jsonCount {
                        
                        print("emp ID = \(self.employees["employees"][i]["ID"].stringValue)")
                        let employee = Employee(_ID: self.employees["employees"][i]["ID"].stringValue, _name: self.employees["employees"][i]["name"].stringValue, _lname: self.employees["employees"][i]["lname"].stringValue, _fname: self.employees["employees"][i]["fname"].stringValue, _username: self.employees["employees"][i]["username"].stringValue, _pic: self.employees["employees"][i]["pic"].stringValue, _phone: self.employees["employees"][i]["phone"].stringValue, _depID: self.employees["employees"][i]["depID"].stringValue, _payRate: self.employees["employees"][i]["payRate"].stringValue, _appScore: self.employees["employees"][i]["appScore"].stringValue, _userLevel: self.employees["employees"][i]["level"].intValue, _userLevelName: self.employees["employees"][i]["levelName"].stringValue)
                        
                        if self.employees["employees"][i]["hasSignature"].stringValue == "1"{
                            employee.hasSignature = true
                        }
                        
                        self.employeeArray.append(employee)
                        
                        if self.employees["employees"][i]["salesRep"].stringValue == "1"
                        {
                            self.salesRepArray.append(employee)
                            self.salesRepIDArray.append(employee.ID)
                            self.salesRepNameArray.append(employee.name)
                        }
                    }
                    
                    if self.employeeListViewController.employeeTableView != nil{
                        self.employeeListViewController.employeeTableView.reloadData()
                    }
                }
        }
        
        print("getEmployeeList JSON = \(self.employees)")
        
        
       
        
        
        
        self.customerListViewController = CustomerListViewController()
        self.customerListViewController.delegate = self
        
        self.vendorListViewController = VendorListViewController()
        self.vendorListViewController.delegate = self
        
        self.itemListViewController = ItemListViewController()
        self.itemListViewController.delegate = self
        
        self.scheduleViewController = ScheduleViewController(_employeeID: "")
        self.scheduleViewController.delegate = self
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        
        self.leadListViewController = LeadListViewController()
        self.leadListViewController.delegate = self
        
        self.equipmentListViewController = EquipmentListViewController()
        self.equipmentListViewController.delegate = self
        
        //self.bugsListViewController = BugsListViewController()
        //self.bugsListViewController.delegate = self
        
        self.contractListViewController = ContractListViewController()
        self.contractListViewController.delegate = self
        
       
        navigationController = UINavigationController(rootViewController: homeViewController)
        
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        
        //style the nav bar
        let layoutVars:LayoutVars = LayoutVars()
        UIBarButtonItem.appearance().tintColor = layoutVars.buttonTextColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.barTintColor = layoutVars.buttonColor1
        //title
        UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.font: layoutVars.buttonFont, NSAttributedString.Key.foregroundColor: layoutVars.buttonTextColor ]
        //left right buttons
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: layoutVars.buttonFont, NSAttributedString.Key.foregroundColor: layoutVars.buttonTextColor], for: UIControl.State())
        
    }
    
    
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0 
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
        
    }
    
    
    
    
    
    
    
    func getLoggedInEmployeeData(_id:String){
        
        print("getLoggedInEmployeeData id = \(_id)")
        // indicator = SDevIndicator.generate(self.view)!
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        Alamofire.request(API.Router.employee(["empID":_id as AnyObject, "cb":timeStamp as AnyObject])).responseJSON() {
            response in
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                print("Logged In Employee JSON: \(json)")
                self.loggedInEmployeeJSON = JSON(json)
                self.parseLoggedInEmployeeJSON()
            }
        }
    }
    
    
    
    func parseLoggedInEmployeeJSON(){
        print("parseLoggedInEmployeeJSON")
        
        let logInEmployee = Employee(_ID: self.loggedInEmployeeJSON["employees"][0]["ID"].stringValue, _name: self.loggedInEmployeeJSON["employees"][0]["name"].stringValue, _lname: self.loggedInEmployeeJSON["employees"][0]["lname"].stringValue, _fname: self.loggedInEmployeeJSON["employees"][0]["fname"].stringValue, _username: self.loggedInEmployeeJSON["employees"][0]["username"].stringValue, _pic: self.loggedInEmployeeJSON["employees"][0]["pic"].stringValue, _phone: self.loggedInEmployeeJSON["employees"][0]["phone"].stringValue, _depID: self.loggedInEmployeeJSON["employees"][0]["depID"].stringValue, _payRate: self.loggedInEmployeeJSON["employees"][0]["payRate"].stringValue, _appScore: self.loggedInEmployeeJSON["employees"][0]["appScore"].stringValue, _userLevel: self.loggedInEmployeeJSON["employees"][0]["level"].intValue, _userLevelName: self.loggedInEmployeeJSON["employees"][0]["levelName"].stringValue)
        
        
        //logInEmployee.userLevel = self.loggedInEmployeeJSON["employees"][0]["level"].intValue
        //logInEmployee.userLevelName = self.loggedInEmployeeJSON["employees"][0]["levelName"].stringValue
        
        print("logInEmployee.userLevelName \(String(describing: logInEmployee.userLevelName))")
        
        self.loggedInEmployee = logInEmployee
        self.homeViewController.layoutViews()
        
    }
    
    
    func menuChange(_ menuItem:Int){
        self.navigationController.popToRootViewController(animated: false)
        
        switch (menuItem) {
        case 0:
            //print("Show Employee List")
            navigationController = UINavigationController(rootViewController: self.employeeListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            
            break
        case 1:
            
            //print("Show Customers")
            if(loggedInEmployee != nil){
                self.navigationController = UINavigationController(rootViewController: self.customerListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "customers", _vc:homeViewController)
            }
            break
        case 2:
            //print("Show Vendor List")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.vendorListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "vendors", _vc:homeViewController)
            }
            break
        case 3:
            //print("Show Item List")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.itemListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "items", _vc:homeViewController)
            }
            break
        case 4:
            print("Show  Lead List")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.leadListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "leads", _vc:homeViewController)
            }
            
            
            break
            
        case 5:
            //print("Show  Contract List")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.contractListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "contracts", _vc:homeViewController)
            }
            
            
            break;
        case 6:
            //print("Show Schedule")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.scheduleViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
               requireLogIn(_destination: "schedule", _vc:homeViewController)
           }
            break
        case 7:
            //print("Show  Performance")
            if(loggedInEmployee != nil){
                self.performanceViewController = PerformanceViewController(_empID: (self.loggedInEmployee?.ID)!)
                navigationController = UINavigationController(rootViewController: self.performanceViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "performance", _vc:homeViewController)
            }
            break
        case 8:
            //print("Show  Images")
            if(loggedInEmployee != nil){
                
                if(self.imageCollectionViewController == nil){
                    self.imageCollectionViewController = ImageCollectionViewController(_mode: "Gallery")
                    self.imageCollectionViewController.delegate = self
                }
                

                
                navigationController = UINavigationController(rootViewController: self.imageCollectionViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "images", _vc:homeViewController)
            }
            break
        case 9:
            //print("Show  Equipment List")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.equipmentListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "equipment", _vc:homeViewController)
            }

            
            break
            
        
            
        default://home
            //print("Show  Home Screen")
            navigationController = UINavigationController(rootViewController: self.homeViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            break
        }
        
        
        
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.pc.PropEval" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return (urls[urls.count-1] as NSURL) as URL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "PropEval", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("PropEval.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
    
    
    // handles rotating

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController.responds(to: #selector(ImageFullViewController.canRotate))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            }
        }
        
        
        // Only allow portrait (standard behaviour)
        return .portrait;
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: (UITabBarController).self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of:(UINavigationController).self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
    func requireLogIn(_destination:String, _vc:UIViewController){
        print("requireLogIn")
        if(loggedInEmployee == nil){
            let alertController = UIAlertController(title: "Log In", message: "You must log in to use \(_destination).", preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                //go to employee screen
                
                
                if  _vc is HomeViewController {
                    self.navigationController = UINavigationController(rootViewController: self.employeeListViewController)
                    self.window?.rootViewController = self.navigationController
                    self.window?.makeKeyAndVisible()
                }
                
                
                
                
            }
            alertController.addAction(okAction)
            _vc.present(alertController, animated: true, completion: nil)
        }
        
       
        
        
        
        
    }
    
    
    func showMessage(_message:String)
    {
        
        //print("show message : \(_message)")
        //frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: 50)
        
        self.messageView?.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.messageView?.isHidden = false
        
        self.messageView?.backgroundColor = layoutVars.backgroundColor
        self.messageView?.layer.borderColor = layoutVars.borderColor
        self.messageView?.layer.borderWidth = 1.0
        self.messageView?.translatesAutoresizingMaskIntoConstraints = false
        self.messageView?.alpha = 0.0
        
        Alamofire.request("https://atlanticlawnandgarden.com/uploads/general/thumbs/"+(self.loggedInEmployee?.pic)!).responseImage { response in
            debugPrint(response)
            
            print(response.request)
            print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                self.messageImageView.image = image
            }
        }
        
        
        /*
        let imgUrl = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+(self.loggedInEmployee?.pic)!)
        
        
        
        Nuke.loadImage(with: imgUrl!, into: self.messageImageView){ 
            //print("nuke loadImage")
            self.messageImageView.handle(response: $0, isFromMemoryCache: $1)
        }

        */
        
        
        
        
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        self.messageView?.addSubview(self.messageImageView)
        
        self.messageLabel = InfoLabel()
        self.messageLabel?.text = "\(self.loggedInEmployee!.fname!) \(_message)"
        self.messageView?.addSubview(self.messageLabel!)
        
        
        self.messageCloseBtn = Button(titleText: "")
        self.messageCloseBtn?.contentHorizontalAlignment = .left
        let closeIcon:UIImageView = UIImageView()
        closeIcon.backgroundColor = UIColor.clear
        closeIcon.contentMode = .scaleAspectFill
        closeIcon.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
        let closeImg = UIImage(named:"closeIcon.png")
        closeIcon.image = closeImg
        self.messageCloseBtn?.addSubview(closeIcon)
        self.messageCloseBtn?.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.messageCloseBtn?.addTarget(self, action: #selector(self.closeMessage), for: UIControl.Event.touchUpInside)
        
        
        self.messageView?.addSubview(messageCloseBtn!)
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.view.addSubview(self.messageView!)
            
            
            //auto layout group
            let metricsDictionary = ["inputHeight":layoutVars.inputHeight, "navHeight": self.layoutVars.navAndStatusBarHeight] as [String : Any]
            
            
            let messageViewsDictionary = [
                "messageView":self.messageView!
                ] as [String:Any]
            
            topController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[messageView]|", options: [], metrics: nil, views: messageViewsDictionary))
            
            topController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[messageView(inputHeight)]", options: [], metrics: metricsDictionary, views: messageViewsDictionary))
            
            let messageViewsDictionary2 = [
                "messageImage":self.messageImageView,
                "messageLabel":self.messageLabel!,
                "messageClose":self.messageCloseBtn!
                ] as [String:Any]
            
            self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[messageImage(40)]-[messageLabel]-[messageClose(30)]-|", options: [], metrics: nil, views: messageViewsDictionary2))
            
            self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[messageImage(40)]", options: [], metrics: nil, views: messageViewsDictionary2))
             self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[messageLabel(30)]", options: [], metrics: nil, views: messageViewsDictionary2))
             self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[messageClose(30)]", options: [], metrics: nil, views: messageViewsDictionary2))
            
        }
        
        self.messageView?.layer.removeAllAnimations()
        UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
            self.messageView?.alpha = 1.0
        }, completion: {
            (value: Bool) in
            // create a sound ID, in this case its the tweet sound.
            let systemSoundID: SystemSoundID = 1023
            
            // to play sound
            AudioServicesPlaySystemSound (systemSoundID)
            
            
            UIView.animate(withDuration: 1.0, delay:2.0, animations: {
                self.messageView?.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.messageView?.isHidden = true
            })
        })
    }
    

    @objc func closeMessage(){
        print("close message")
        
        self.messageView?.isHidden = true
        
    }
        
}







