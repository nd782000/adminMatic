//
//  ImageEmployeeLikesListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/21/18.
//  Copyright © 2018 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON
//import Nuke




class ImageEmployeeLikesListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource{
    var indicator: SDevIndicator!
    
    var image:Image!
    
    
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
    
    
    init(_image:Image){
        super.init(nibName:nil,bundle:nil)
        //print("init _image.ID = \(_image.ID)")
        self.image = _image
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Image Likes"
        view.backgroundColor = layoutVars.backgroundColor
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(DepartmentListViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
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
        
        /*
         //cache buster
         let now = Date()
         let timeInterval = now.timeIntervalSince1970
         let timeStamp = Int(timeInterval)
         
         */
        
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
        
        
        self.imageView = UIImageView()
        
        
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = CGPoint(x: self.imageView.frame.size.width / 2, y: self.imageView.frame.size.height / 2)
        imageView.addSubview(activityView)
        
        /*activityView.startAnimating()
        
        let imgURL:URL = URL(string: self.image.thumbPath!)!
        
        Nuke.loadImage(with: imgURL, into: self.imageView!){
            print("nuke loadImage")
            self.imageView?.handle(response: $0, isFromMemoryCache: $1)
            self.activityView.stopAnimating()
            
            //let image = Image(_path: self.image.thumbPath!)
            
            //self.imageFullViewController = ImageFullViewController(_image: image)
            
        }
        */
        
        
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
        self.view.addSubview(self.imageView)
        
        //name
        self.nameLbl = GreyLabel()
        self.nameLbl.text = self.image.name!
        self.nameLbl.font = layoutVars.labelFont
        self.view.addSubview(self.nameLbl)
        
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        let date = dateFormatter.date(from: self.image.dateAdded)!
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateFormat = "MM/dd/yyyy"
        
        
        let addedByDate = shortDateFormatter.string(from: date)
        
        
        //info
        self.infoLbl = Label()
        self.infoLbl.text = "By \(self.image.createdBy!)"
        self.infoLbl.font = layoutVars.smallFont
        self.view.addSubview(self.infoLbl)
        
        self.info2Lbl = Label()
        self.info2Lbl.text = "On \(addedByDate)"
        self.info2Lbl.font = layoutVars.smallFont
        self.view.addSubview(self.info2Lbl)
        
        
        
        
        
        
        
        self.likesTableView.delegate  =  self
        self.likesTableView.dataSource = self
        likesTableView.rowHeight = 60.0
        self.likesTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        self.view.addSubview(self.likesTableView)
        
        
        /*
        noLikesLabel.text = "No Likes"
        noLikesLabel.textAlignment = NSTextAlignment.center
        noLikesLabel.font = layoutVars.largeFont
        self.view.addSubview(self.noLikesLabel)
        */
        
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
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
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[name]-10-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[info]-10-|", options: [], metrics: nil, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[info2]-10-|", options: [], metrics: nil, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noLikesLbl(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[count(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[image(100)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[image(100)]-[table][count(30)]|", options:[], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[name(30)][info(30)][info2(30)]", options:[], metrics: sizeVals, views: viewsDictionary))
        //self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[noLikesLbl(30)]", options:[], metrics: sizeVals, views: viewsDictionary))
        
        
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
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



