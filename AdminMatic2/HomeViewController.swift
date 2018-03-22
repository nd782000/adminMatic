//
//  HomeViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/5/17.
//  Copyright © 2017 Nick. All rights reserved.
//

import Foundation
import UIKit

import Nuke


import UIKit
class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var employeeImage:UIImageView!
    var loggedInBtn: Button = Button()
    var layout: UICollectionViewFlowLayout!
    var homeCollectionView: UICollectionView?
    var layoutVars:LayoutVars = LayoutVars()
    var homeBtnData:[(image: String, title: String)] = []
    
    
    init(){
        super.init(nibName:nil,bundle:nil)
        
        title = "Home v \(self.appDelegate.appVersion)"
        homeBtnData = [("customersIcon","Customers"),("employeesIcon","Employees"),("vendorsIcon","Vendors"),("itemsIcon","Items"),("scheduleIcon","Schedule"),("performanceIcon","Performance"),("imagesIcon","Images"),("equipmentIcon","Equipment"),("leadsIcon","Leads"),("contractsIcon","Contracts")]
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
        
        if(appDelegate.loggedInEmployee == nil){
            self.loggedInBtn = Button(titleText: "Log In")
            self.loggedInBtn.contentHorizontalAlignment = .center
        }else{
            self.setLoggedInUserBtn()
        }
        
        self.loggedInBtn.translatesAutoresizingMaskIntoConstraints = true
        self.loggedInBtn.frame = CGRect(x: 10, y:layoutVars.navAndStatusBarHeight + 10, width: self.view.frame.width - 20, height: 40)
        self.loggedInBtn.addTarget(self, action: #selector(HomeViewController.showLoggedInUser), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(self.loggedInBtn)
    
        
        // Do any additional setup after loading the view, typically from a nib.
        layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: layoutVars.fullWidth/2-15, height: layoutVars.fullWidth/2-15)
        
         homeCollectionView = UICollectionView(frame: CGRect(x: 0, y: layoutVars.navAndStatusBarHeight + 50, width: self.view.frame.width, height: self.view.frame.height - 50 - layoutVars.navAndStatusBarHeight), collectionViewLayout: layout)
        

        homeCollectionView?.dataSource = self
        homeCollectionView?.delegate = self
        homeCollectionView?.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        
        
        
        homeCollectionView?.backgroundColor = UIColor.white
        self.view.addSubview(homeCollectionView!)
    }
    
    func setLoggedInUserBtn(){

        if(appDelegate.loggedInEmployee != nil){
            //print("logged in emp is not nil")
            self.loggedInBtn = Button(titleText: "Welcome \(appDelegate.loggedInEmployee!.fname!)!")
            self.loggedInBtn.contentHorizontalAlignment = .left
            
            //image
            self.employeeImage = UIImageView()
            
            let imgUrl = URL(string: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+(appDelegate.loggedInEmployee?.pic)!)
            
            print("imgURL = \(String(describing: imgUrl))")
            
            
            Nuke.loadImage(with: imgUrl!, into: self.employeeImage!){ 
                print("nuke loadImage")
                self.employeeImage?.handle(response: $0, isFromMemoryCache: $1)
                //self.activityView.stopAnimating()
                
            }
            
        
            employeeImage.contentMode = .scaleAspectFill
            employeeImage.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
            self.loggedInBtn.addSubview(self.employeeImage)
    
            self.loggedInBtn.translatesAutoresizingMaskIntoConstraints = true
            self.loggedInBtn.frame = CGRect(x: 10, y:layoutVars.navAndStatusBarHeight + 10, width: self.view.frame.width - 20, height: 40)
            self.loggedInBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 10)
            self.loggedInBtn.addTarget(self, action: #selector(HomeViewController.showLoggedInUser), for: UIControlEvents.touchUpInside)
            self.view.addSubview(self.loggedInBtn)
            
        }else{
           
            self.loggedInBtn = Button(titleText: "Log In")
            self.loggedInBtn.contentHorizontalAlignment = .center
            
            self.loggedInBtn.translatesAutoresizingMaskIntoConstraints = true
            self.loggedInBtn.frame = CGRect(x: 10, y:layoutVars.navAndStatusBarHeight + 10, width: self.view.frame.width - 20, height: 40)
            self.loggedInBtn.addTarget(self, action: #selector(HomeViewController.showLoggedInUser), for: UIControlEvents.touchUpInside)
            
            self.view.addSubview(self.loggedInBtn)
            
        }
    }
    
    @objc func showLoggedInUser(){
        //print("showLoggedInUser")
        
        
        if(appDelegate.loggedInEmployee != nil){
            let employeeViewController = EmployeeViewController(_employee: appDelegate.loggedInEmployee!)
        
            appDelegate.navigationController?.pushViewController(employeeViewController, animated: false )
        }else{
            appDelegate.menuChange(1)
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
            //customers
             appDelegate.menuChange(0)
            break
        case 1:
            //employees
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
            //schedule
            appDelegate.menuChange(4)
            break
        case 5:
            //performance
            appDelegate.menuChange(5)
            break
        case 6:
            //images
            appDelegate.menuChange(6)
            break
        case 7:
            //equipment
            appDelegate.menuChange(7)
            break
        case 8:
            //leads
            appDelegate.menuChange(8)
            break
        case 9:
            //contracts
            appDelegate.menuChange(9)
            break
        default:
            break
            
        }
    }
    
    

}




