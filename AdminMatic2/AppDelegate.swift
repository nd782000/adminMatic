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
import SwiftyJSON

protocol MenuDelegate{
    func menuChange(_ menuItem:Int)
}

protocol TimeEntryDelegate{
    func editStartTime()
    func editStopTime()
    func editBreakTime()
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MenuDelegate{
    
    var window: UIWindow?
    
    var layoutVars:LayoutVars!
    
    var navigationController:UINavigationController!
    var homeViewController:HomeViewController!
    var employeeListViewController:EmployeeListViewController!
    var customerListViewController:CustomerListViewController!
    var vendorListViewController:VendorListViewController!
    var itemListViewController:ItemListViewController!
    var employeeViewController:EmployeeViewController!
    var scheduleViewController:ScheduleViewController!
    var imageCollectionViewController:ImageCollectionViewController!
    
    
    var underConstructionViewController:UnderConstructionViewController!

    //var equipmentListViewController:EquipmentListViewController!
    
    var fieldsJson:JSON!
    
    var employees:JSON!
    var employeeArray:[Employee] = []
    
    var loggedInEmployee:Employee?
    
    
    var messageView:UIView?
    var messageImageView:UIImageView = UIImageView()
    var messageLabel:InfoLabel?
   
    
    
    /*
    var loggedInUser:String = "0"
    var loggedInUserFName:String = ""
    var loggedInUserPic:String = ""
    */
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        
        
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        
        manager?.listener = { status in
            print("Network Status Changed: \(status)")
        }
        
        manager?.startListening()
        
        
        
        //Get all Fields
        ////print("get fields")
        //let testEmp = Employee(_ID: "1", _name: "Tyrone Tester", _lname: "Tester", _fname: "Tyrone", _username: "tester", _pic: "", _phone: "", _depID: "", _payRate: "", _appScore: "1000000")
        //self.loggedInEmployee = testEmp
            
        self.layoutVars = LayoutVars()
        
        //cache buster
        let now = Date()
        let timeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        //, "cb":timeStamp as AnyObject
        
        Alamofire.request(API.Router.fields(["cb":timeStamp as AnyObject])).responseJSON() {
            response in
            ////print(response.request ?? "default request")  // original URL request
            ////print(response.response ?? "default response") // URL response
            ////print(response.data ?? "default data")     // server data
            ////print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                jsonDataHolder.jsonData = JSON(json)
                self.fieldsJson = JSON(json)
                
                //print("fields json = \(self.fieldsJson)")
            }
        }
                
        
        //Get employee list
        Alamofire.request(API.Router.employeeList(["cb":timeStamp as AnyObject])).responseJSON() {
            response in
            
            if let json = response.result.value {
                self.employees = JSON(json)
                //self.employeeListViewController.layoutViews()
                
                
                
                
                let jsonCount = self.employees["employees"].count
                //self.totalItems = jsonCount
                //print("JSONcount: \(jsonCount)")
                for i in 0 ..< jsonCount {
                    
                    
                    let employee = Employee(_ID: self.employees["employees"][i]["ID"].stringValue, _name: self.employees["employees"][i]["name"].stringValue, _lname: self.employees["employees"][i]["lname"].stringValue, _fname: self.employees["employees"][i]["fname"].stringValue, _username: self.employees["employees"][i]["username"].stringValue, _pic: self.employees["employees"][i]["pic"].stringValue, _phone: self.employees["employees"][i]["phone"].stringValue, _depID: self.employees["employees"][i]["depID"].stringValue, _payRate: self.employees["employees"][i]["payRate"].stringValue, _appScore: self.employees["employees"][i]["appScore"].stringValue)
                    
                    
                   
                    
                    self.employeeArray.append(employee)
                    
                }
               
                
                
                
                
                
            }
            ////print("getEmployeeList JSON = \(self.employeesJson)")
            
            
        }
        
        
        self.homeViewController = HomeViewController()
        
        
        self.employeeListViewController = EmployeeListViewController()
        self.employeeListViewController.delegate = self
        
        
        
        self.customerListViewController = CustomerListViewController()
        self.customerListViewController.delegate = self
        
        self.vendorListViewController = VendorListViewController()
        self.vendorListViewController.delegate = self
        
       self.itemListViewController = ItemListViewController()
        self.itemListViewController.delegate = self
        
        self.scheduleViewController = ScheduleViewController(_employeeID: "")
        self.scheduleViewController.delegate = self
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        /*
        self.imageCollectionViewController = ImageCollectionViewController()
        self.imageCollectionViewController.delegate = self
        */
        
        self.underConstructionViewController = UnderConstructionViewController()
        self.underConstructionViewController.delegate = self
        
        
        navigationController = UINavigationController(rootViewController: homeViewController)
        
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        
        //style the nav bar
        let layoutVars:LayoutVars = LayoutVars()
        UIBarButtonItem.appearance().tintColor = layoutVars.buttonTextColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.barTintColor = layoutVars.buttonColor1
        //title
        UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName: layoutVars.buttonFont, NSForegroundColorAttributeName: layoutVars.buttonTextColor ]
        //left right buttons
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: layoutVars.buttonFont, NSForegroundColorAttributeName: layoutVars.buttonTextColor], for: UIControlState())
        
        return true
    }
    
    
    func menuChange(_ menuItem:Int){
        self.navigationController.popToRootViewController(animated: false)
        
        switch (menuItem) {
        case 0:
            //print("Show Customers")
            if(loggedInEmployee != nil){
                self.navigationController = UINavigationController(rootViewController: self.customerListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "customers")
            }
            
            break;
        case 1:
            //print("Show Employee List")
            navigationController = UINavigationController(rootViewController: self.employeeListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            break;
        case 2:
            //print("Show Vendor List")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.vendorListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "vendors")
            }
            break;
        case 3:
            //print("Show Item List")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.itemListViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "items")
            }
            break;
        case 4:
            //print("Show Schedule")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.scheduleViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
               requireLogIn(_destination: "schedule")
           }
            break;
        case 5:
            //print("Show  Performance")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.underConstructionViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "performance")
            }
            break;
        case 6:
            //print("Show  Images")
            if(loggedInEmployee != nil){
                
                if(self.imageCollectionViewController == nil){
                    self.imageCollectionViewController = ImageCollectionViewController()
                    self.imageCollectionViewController.delegate = self
                }
                

                
                navigationController = UINavigationController(rootViewController: self.imageCollectionViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "images")
            }
            break;
        case 7:
            //print("Show  Equipment List")
            if(loggedInEmployee != nil){
                navigationController = UINavigationController(rootViewController: self.underConstructionViewController)
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }else{
                requireLogIn(_destination: "equipment")
            }

            
            break;
            
        default://home
            //print("Show  Home Screen")
            navigationController = UINavigationController(rootViewController: self.homeViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            break;
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
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
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
    
    func requireLogIn(_destination:String){
        //print("requireLogIn")
        if(loggedInEmployee == nil){
            let alertController = UIAlertController(title: "Log In", message: "You must log in to use \(_destination).", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                //go to employee screen
                
                self.navigationController = UINavigationController(rootViewController: self.employeeListViewController)
                self.window?.rootViewController = self.navigationController
                self.window?.makeKeyAndVisible()
                
            }
            alertController.addAction(okAction)
            homeViewController.present(alertController, animated: true, completion: nil)
        }
        
       
        
        
        
        
    }
    
    
    func showMessage(_message:String)
    {
        
        //print("show message : \(_message)")
        //frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: 50)
        
        self.messageView = UIView()
        self.messageView?.backgroundColor = layoutVars.backgroundColor
        self.messageView?.translatesAutoresizingMaskIntoConstraints = false
        self.messageView?.alpha = 0.0
        
        let imgUrl = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+(self.loggedInEmployee?.pic)!)
        
        
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: imgUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.messageImageView.image = UIImage(data: data!)
            }
        }
        
        
        
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        //messageImageView.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        self.messageView?.addSubview(self.messageImageView)
        
        self.messageLabel = InfoLabel()
        self.messageLabel?.text = "\(self.loggedInEmployee!.fname!) \(_message)"
        //self.messageLabel?.font = layoutVars.labelFont
        self.messageView?.addSubview(self.messageLabel!)
        
        
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            
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
                "messageLabel":self.messageLabel!
                ] as [String:Any]
            
            self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[messageImage(40)]-[messageLabel]-|", options: [], metrics: nil, views: messageViewsDictionary2))
            
            self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[messageImage(40)]", options: [], metrics: nil, views: messageViewsDictionary2))
             self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[messageLabel(30)]", options: [], metrics: nil, views: messageViewsDictionary2))
            
            
            
            
            
            
        }
        
        
       

        
        
        
       
        
        
        UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
            self.messageView?.alpha = 1.0
        }, completion: {
            (value: Bool) in
            
            
            UIView.animate(withDuration: 1.0, delay:2.0, animations: {
                self.messageView?.alpha = 0.0
            }, completion: {
                (value: Bool) in
                
                
                
                self.messageView?.isHidden = true
                
                
                
            })
           
            
            
            
        })
        
        
        
    }
    
    /*
    func showLoggedInUser(){
        //print("show logged in user")
        ////print("name = \(currentCell.name)")
        
        
        
        let employeeViewController = EmployeeViewController(_employee: loggedInEmployee!)
        
       // tableView.deselectRow(at: indexPath!, animated: true)
        
        navigationController?.pushViewController(employeeViewController, animated: false )

    }
    
    */
    
    
    
    
}







