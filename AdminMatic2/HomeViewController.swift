//
//  HomeViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/5/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//edited for safeView


import Foundation
import UIKit

//import Nuke

import  Alamofire
import  AlamofireImage


import UIKit
class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var employeeImage:UIImageView!
    var loggedInBtn: Button = Button()
    var layout: UICollectionViewFlowLayout!
    var homeCollectionView: UICollectionView?
    var layoutVars:LayoutVars = LayoutVars()
    var homeBtnData:[(image: String, title: String)] = []
    
    
    init(){
        super.init(nibName:nil,bundle:nil)
        
        title = "Home v \(self.appDelegate.appVersion)"
        homeBtnData = [("employeesIcon","Employees"),("customersIcon","Customers"),("vendorsIcon","Vendors"),("itemsIcon","Items"),("leadsIcon","Leads"),("contractsIcon","Contracts"),("scheduleIcon","Work Orders"),("invoiceIcon","Invoices"),("imagesIcon","Images"),("equipmentIcon","Equipment")]
        self.view.backgroundColor = layoutVars.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
         layoutViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        self.setLoggedInUserBtn()
    }
    
    
    func layoutViews(){
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
       
        
        
        // Do any additional setup after loading the view, typically from a nib.
        layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: layoutVars.fullWidth/2-15, height: layoutVars.fullWidth/2-15)
        
        homeCollectionView = UICollectionView(frame: CGRect(x: 0, y: layoutVars.navAndStatusBarHeight + 50, width: self.view.frame.width, height: self.view.frame.height - 50 - layoutVars.navAndStatusBarHeight), collectionViewLayout: layout)
        homeCollectionView!.translatesAutoresizingMaskIntoConstraints = false
        
       
        homeCollectionView!.dataSource = self
        homeCollectionView!.delegate = self
        homeCollectionView!.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        homeCollectionView!.backgroundColor = UIColor.white
       self.view.addSubview(homeCollectionView!)
        
       // indicator = SDevIndicator.generate(self.view)!
        
        self.homeCollectionView!.translatesAutoresizingMaskIntoConstraints = false
        self.homeCollectionView!.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.homeCollectionView!.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 60.0).isActive = true
        //self.loggedInBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        self.homeCollectionView!.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.homeCollectionView!.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor).isActive = true
        
        if(appDelegate.loggedInEmployee == nil){
            self.loggedInBtn = Button(titleText: "Log In")
            self.loggedInBtn.contentHorizontalAlignment = .center
            
            //self.indicator.dismissIndicator()
            
        }else{
            self.setLoggedInUserBtn()
        }
        
        
        //self.loggedInBtn.frame = CGRect(x: 10, y:layoutVars.navAndStatusBarHeight + 10, width: self.view.frame.width - 20, height: 40)
        self.loggedInBtn.addTarget(self, action: #selector(HomeViewController.showLoggedInUser), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(self.loggedInBtn)
        
        self.loggedInBtn.translatesAutoresizingMaskIntoConstraints = false
        self.loggedInBtn.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant: 10.0).isActive = true
        self.loggedInBtn.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 10.0).isActive = true
        self.loggedInBtn.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
        self.loggedInBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    
    func setLoggedInUserBtn(){

        if(appDelegate.loggedInEmployee != nil){
            //print("logged in emp is not nil")
            
            
            self.loggedInBtn.setTitle("Welcome \(appDelegate.loggedInEmployee!.fname!)!", for: .normal)
            self.loggedInBtn.contentHorizontalAlignment = .left
            
            //image
            self.employeeImage = UIImageView()
            
            
            
            
            
            Alamofire.request("https://atlanticlawnandgarden.com/uploads/general/thumbs/"+(appDelegate.loggedInEmployee?.pic)!).responseImage { response in
               // debugPrint(response)
                
                //print(response.request)
                //print(response.response)
                //debugPrint(response.result)
                
                if let image = response.result.value {
                   // print("image downloaded: \(image)")
                    self.employeeImage.image = image
                   // self.indicator.dismissIndicator()
                }
            }
            
            
        
            employeeImage.contentMode = .scaleAspectFill
            employeeImage.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
            self.loggedInBtn.addSubview(self.employeeImage)
    
            //self.loggedInBtn.translatesAutoresizingMaskIntoConstraints = true
            //self.loggedInBtn.frame = CGRect(x: 10, y:layoutVars.navAndStatusBarHeight + 10, width: self.view.frame.width - 20, height: 40)
            self.loggedInBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 10)
            self.loggedInBtn.addTarget(self, action: #selector(HomeViewController.showLoggedInUser), for: UIControl.Event.touchUpInside)
            self.view.addSubview(self.loggedInBtn)
            
        }else{
           
            self.loggedInBtn = Button(titleText: "Log In")
            self.loggedInBtn.contentHorizontalAlignment = .center
            
            //self.loggedInBtn.translatesAutoresizingMaskIntoConstraints = true
            //self.loggedInBtn.frame = CGRect(x: 10, y:layoutVars.navAndStatusBarHeight + 10, width: self.view.frame.width - 20, height: 40)
            self.loggedInBtn.addTarget(self, action: #selector(HomeViewController.showLoggedInUser), for: UIControl.Event.touchUpInside)
            
            self.view.addSubview(self.loggedInBtn)
            
        }
    }
    
    @objc func showLoggedInUser(){
        //print("showLoggedInUser")
        
        
        if(appDelegate.loggedInEmployee != nil){
            let employeeViewController = EmployeeViewController(_employee: appDelegate.loggedInEmployee!)
        
            appDelegate.navigationController?.pushViewController(employeeViewController, animated: false )
        }else{
            appDelegate.menuChange(0)
        }
    
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.homeBtnData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! HomeCollectionViewCell
        cell.backgroundColor = layoutVars.backgroundColor
        cell.textLabel.text = self.homeBtnData[indexPath.row].title
        cell.imageView.image = UIImage(named: self.homeBtnData[indexPath.row].image)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //employees
             appDelegate.menuChange(0)
            break
        case 1:
            
            //customers
            appDelegate.menuChange(1)
            break
        case 2:
            //vendors
            appDelegate.menuChange(2)
            break
        case 3:
            //items
            appDelegate.menuChange(3)
            break
        case 4:
            //leads
            appDelegate.menuChange(4)
            break
        case 5:
            //contracts
            
            //need userLevel greater then 1 to access this
            if self.layoutVars.grantAccess(_level: 1,_view: self) {
                return
            }
            
            appDelegate.menuChange(5)
            break
        case 6:
            //work orders
            appDelegate.menuChange(6)
            break
        case 7:
            //invoices
            appDelegate.menuChange(7)
            break
        case 8:
            //images
            appDelegate.menuChange(8)
            break
        case 9:
            //equipment
            appDelegate.menuChange(9)
            break
        
        default:
            break
            
        }
    }
    
    

}




