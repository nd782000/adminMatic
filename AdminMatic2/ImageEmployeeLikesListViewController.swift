//
//  ImageEmployeeLikesListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/21/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON
//import Nuke


 

class ImageEmployeeLikesListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource{
    var indicator: SDevIndicator!
    
    var image:Image2!
    //var uiImage:UIImage!
    
    
    //employee info
    var imageView:UIImageView!
    var activityView:UIActivityIndicatorView!
    
    var nameLbl:GreyLabel!
    var infoLbl:Label!
    var info2Lbl:Label!
    
    
    
    
    var likesTableView:TableView!
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    //var noLikesLabel:Label = Label()
    
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var totalEmployees:Int!
    var employees:JSON!
    var employeeArray:[Employee] = []
    
    
    
    
    
    var employeeViewController:EmployeeViewController!
    
    
    
    
    init(){
        super.init(nibName:nil,bundle:nil)
        print("init")
    }
    
    
    init(_image:Image2){
        super.init(nibName:nil,bundle:nil)
        //print("init _image.ID = \(_image.ID)")
        self.image = _image
        //self.uiImage = _uiImage
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image Likes"
        view.backgroundColor = layoutVars.backgroundColor
        
       
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        
        getEmployeeLikes()
    }
    
    
    func getEmployeeLikes() {
        //remove any added views (needed for table refresh
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        likesTableView = TableView()
        employeeArray = []
        
        
        
        
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
       
        
        let parameters:[String:String]
        parameters = ["imageID":self.image.ID]
        print("parameters = \(parameters)")
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/imageLikes.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("likes response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    
                    
                    //print("JSON: \(json)")
                    self.employees = JSON(json)
                    self.parseJSON()
                }
                
        }
        
    }
    func parseJSON(){
        let jsonCount = self.employees["employees"].count
        self.totalEmployees = jsonCount
        
        
        
        
        self.countLbl.text = "\(self.totalEmployees!) Like(s)"
        
       
            
            
           
            for n in 0 ..< totalEmployees {
                
                
                let employee = Employee(_ID: self.employees["employees"][n]["employeeID"].stringValue, _name: self.employees["employees"][n]["name"].stringValue, _pic: self.employees["employees"][n]["pic"].stringValue)
                
               
                
                
                
                
                self.employeeArray.append(employee)
                
               
                
            }
            
            
            
            
           
        
       
        
        
        self.layoutViews()
        
    }
    
   
    
    
    func layoutViews(){
        
        // Close Indicator
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        self.imageView = UIImageView()
        
        
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: self.imageView.frame.size.width / 2, y: self.imageView.frame.size.height / 2)
        imageView.addSubview(activityView)
        
       
        
        Alamofire.request(self.image.thumbPath!).responseImage { response in
            debugPrint(response)
            
            print(response.request!)
            print(response.response!)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                
                
                self.imageView.image = image
                
                
                self.activityView.stopAnimating()
                
                
            }
        }
        
        
        
        
        
        
        
        
        self.imageView.layer.cornerRadius = 5.0
        self.imageView.layer.borderWidth = 2
        self.imageView.layer.borderColor = layoutVars.borderColor
        self.imageView.clipsToBounds = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.imageView)
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = self.image.name
        self.nameLbl.font = layoutVars.labelFont
        safeContainer.addSubview(self.nameLbl)
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        let date = dateFormatter.date(from: self.image.dateAdded)!
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MM/dd/yyyy"
        
        
        let addedByDate = shortDateFormatter.string(from: date)
        
        
        //info
        self.infoLbl = Label()
        self.infoLbl.text = "By \(self.image.createdBy)"
        self.infoLbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.infoLbl)
        
        self.info2Lbl = Label()
        self.info2Lbl.text = "On \(addedByDate)"
        self.info2Lbl.font = layoutVars.smallFont
        safeContainer.addSubview(self.info2Lbl)
        
        
        
        
        
        
        
        self.likesTableView.delegate  =  self
        self.likesTableView.dataSource = self
        likesTableView.rowHeight = 60.0
        self.likesTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        safeContainer.addSubview(self.likesTableView)
        
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        
        
        
        //auto layout group
        let viewsDictionary = [
            "image":self.imageView,
            "name":self.nameLbl,
            "info":self.infoLbl,
            "info2":self.info2Lbl,
            "table":self.likesTableView,
            "count":self.countView
            
            ] as [String : Any]
        
        let sizeVals = ["halfWidth": layoutVars.halfWidth, "fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight + 8,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[name]-10-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[info]-10-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[info2]-10-|", options: [], metrics: nil, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        //safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noLikesLbl(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[count(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(100)]-[table][count(30)]|", options:[], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(30)][info(30)][info2(30)]", options:[], metrics: sizeVals, views: viewsDictionary))
        //safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[noLikesLbl(30)]", options:[], metrics: sizeVals, views: viewsDictionary))
        
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    
    
   
    
    
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        
        
        return totalEmployees
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cell for row \(indexPath.row)")
        
        let cell:EmployeeTableViewCell = likesTableView.dequeueReusableCell(withIdentifier: "cell") as! EmployeeTableViewCell
        
        
        cell.employee = self.employeeArray[indexPath.row]
        
        //print("cell.employee.ID = \(cell.employee.ID)")
        cell.layoutViews()
        cell.activityView.startAnimating()
        cell.nameLbl.text = cell.employee.name
        cell.setImageUrl(_url: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+cell.employee.pic!)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! EmployeeTableViewCell
        
        
        //print("currentCell.employee.ID = \(currentCell.employee.ID)")
        
        self.employeeViewController = EmployeeViewController(_employee: currentCell.employee)
        tableView.deselectRow(at: indexPath!, animated: true)
        
        
        
        navigationController?.pushViewController(self.employeeViewController, animated: false )
    }
    
    
   
    
    
    
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



