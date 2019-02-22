//
//  DepartmentListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/16/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import MessageUI



class DeptCrewListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate{
    var indicator: SDevIndicator!
    
    var empID:String!
    var empFirstName:String!
   
    
    var customSC:SegmentedControl!
    var currentSortMode = "DEPTS" //DEPTS or CREWS
    
    var departmentTableView:TableView!
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    var noDepartmentLabel:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var deptSections : [(index: Int, length :Int, title: String, color: String)] = Array()
    var crewSections : [(index: Int, length :Int, title: String, color: String)] = Array()
    
    var totalDepartments:Int!
    var departments: JSON!
    
    var departmentArray:[Department] = []
    
    var deptEmployeeArray:[Employee] = []
    
    
    var totalCrews:Int!
    var crews: JSON!
    
    var crewArray:[Crew] = []
    
    var crewEmployeeArray:[Employee] = []
    
    //var addDepartmentBtn:Button = Button(titleText: "Add Department")
    //var editDepartmentsBtn:Button = Button(titleText: "Edit")
    
    var employeeViewController:EmployeeViewController!
    
    var controller:MFMessageComposeViewController = MFMessageComposeViewController()
    
    init(){
        super.init(nibName:nil,bundle:nil)
        //print("init")
    }
    
    
    init(_empID:String,_empFirstName:String){
        super.init(nibName:nil,bundle:nil)
        //print("init _empID = \(_empID)")
        self.empID = _empID
        self.empFirstName = _empFirstName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentSortMode == "DEPTS"{
            title = "\(self.empFirstName!)'s Departments"
        }else{
            title = "\(self.empFirstName!)'s Crews"
        }
        
        view.backgroundColor = layoutVars.backgroundColor
       
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
        getDepartmentList()
    }
    
    
    func getDepartmentList() {
        //remove any added views (needed for table refresh
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        departmentTableView = TableView()
        departmentArray = []
        
    
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        let parameters:[String:String]
        parameters = ["empID":self.empID, "crewView":"0"]
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/departments.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("department response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    //print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    
                    
                    ////print("JSON: \(json)")
                    self.departments = JSON(json)
                    self.parseJSON()
                }
        }
    }
    func parseJSON(){
        let jsonCount = self.departments["departments"].count
        self.totalDepartments = jsonCount
        if self.totalDepartments == 0{
            self.noDepartmentLabel.isHidden = false
            
        }else{
            self.noDepartmentLabel.isHidden = true
        }
        
        self.countLbl.text = "\(self.totalDepartments!) Department(s)"
        
        for i in 0 ..< jsonCount {
            
            //create an equipment object
            
            let department = Department(_ID: self.departments["departments"][i]["id"].stringValue, _name: self.departments["departments"][i]["name"].stringValue, _status: self.departments["departments"][i]["status"].stringValue, _color: self.departments["departments"][i]["color"].stringValue, _depHead: self.departments["departments"][i]["depHead"].stringValue)
            
           // //print("department name = \(department.name)")
            
            let empCount = self.departments["departments"][i]["employees"].count
            //self.totalItems = jsonCount
            //print("emp count: \(empCount)")
            for n in 0 ..< empCount {
                
                
                let employee = Employee(_ID: self.departments["departments"][i]["employees"][n]["ID"].stringValue, _name: self.departments["departments"][i]["employees"][n]["name"].stringValue, _lname: self.departments["departments"][i]["employees"][n]["lname"].stringValue, _fname: self.departments["departments"][i]["employees"][n]["fname"].stringValue, _username: self.departments["departments"][i]["employees"][n]["username"].stringValue, _pic: self.departments["departments"][i]["employees"][n]["pic"].stringValue, _phone: self.departments["departments"][i]["employees"][n]["phone"].stringValue, _depID: self.departments["departments"][i]["employees"][n]["depID"].stringValue, _payRate: self.departments["departments"][i]["employees"][n]["payRate"].stringValue, _appScore: self.departments["departments"][i]["employees"][n]["appScore"].stringValue, _userLevel: self.departments["departments"][i]["employees"][n]["level"].intValue, _userLevelName: self.departments["departments"][i]["employees"][n]["levelName"].stringValue)
                
                employee.deptName = department.name!
                employee.deptColor = department.color!
                
               // //print("employee.deptColor = \(employee.deptColor)")
                
                self.deptEmployeeArray.append(employee)
                department.employeeArray.append(employee)
            }
            
            self.departmentArray.append(department)
            
        }
        
        //createSections()
        
        
        getCrewList()
    }
    
    
    func getCrewList() {
        //remove any added views (needed for table refresh
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        //crewTableView = TableView()
        crewArray = []
        
        
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
        
        /*
         //cache buster
         let now = Date()
         let timeInterval = now.timeIntervalSince1970
         let timeStamp = Int(timeInterval)
         
         */
        
        let parameters:[String:String]
        parameters = ["empID":self.empID, "crewView":"1"]
        //print("parameters = \(parameters)")
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/departments.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("crew response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    //print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    
                    
                    ////print("JSON: \(json)")
                    self.crews = JSON(json)
                    self.parseCrewJSON()
                }
                
        }
        
    }
    func parseCrewJSON(){
        let jsonCount = self.crews["crews"].count
        self.totalCrews = jsonCount
        if self.totalCrews == 0{
            self.noDepartmentLabel.isHidden = false
            
        }else{
            self.noDepartmentLabel.isHidden = true
        }
        
       // self.countLbl.text = "\(self.totalCrews!) Crew(s)"
        
        for i in 0 ..< jsonCount {
            
            //create an equipment object
            
            let crew = Crew(_ID: self.crews["crews"][i]["id"].stringValue, _name: self.crews["crews"][i]["name"].stringValue, _status: self.crews["crews"][i]["status"].stringValue, _color: self.crews["crews"][i]["subcolor"].stringValue, _crewHead: self.crews["crews"][i]["crewHead"].stringValue)
            
            // //print("crew name = \(crew.name)")
            
            let empCount = self.crews["crews"][i]["employees"].count
            //self.totalItems = jsonCount
            //print("emp count: \(empCount)")
            for n in 0 ..< empCount {
                
                
                let employee = Employee(_ID: self.crews["crews"][i]["employees"][n]["ID"].stringValue, _name: self.crews["crews"][i]["employees"][n]["name"].stringValue, _lname: self.crews["crews"][i]["employees"][n]["lname"].stringValue, _fname: self.crews["crews"][i]["employees"][n]["fname"].stringValue, _username: self.crews["crews"][i]["employees"][n]["username"].stringValue, _pic: self.crews["crews"][i]["employees"][n]["pic"].stringValue, _phone: self.crews["crews"][i]["employees"][n]["phone"].stringValue, _depID: self.crews["crews"][i]["employees"][n]["depID"].stringValue, _payRate: self.crews["crews"][i]["employees"][n]["payRate"].stringValue, _appScore: self.crews["crews"][i]["employees"][n]["appScore"].stringValue, _userLevel: self.crews["crews"][i]["employees"][n]["level"].intValue, _userLevelName: self.crews["crews"][i]["employees"][n]["levelName"].stringValue)
                
                employee.crewName = crew.name!
                employee.crewColor = crew.color!
                //employee.crewColor2 = crew.color2!
                
                // //print("employee.crewColor = \(employee.crewColor)")
                
                
                //crew.employeeArray.append(employee)
                
                self.crewEmployeeArray.append(employee)
                
                crew.employeeArray.append(employee)
                
            }
            
            
            
            
            self.crewArray.append(crew)
            
        }
        
        createSections()
        
        
        self.layoutViews()
        
    }
    
    func createSections(){
        deptSections = []
        crewSections = []
        
        
        
        // build sections based on first letter(json is already sorted alphabetically)
        //print("build sections")
        
        //print("self.employeeArray.count = \(self.employeeArray.count)")
        
        var deptIndex = 0;
        var deptTitleArray:[String] = [" "]
        var deptColorArray:[String] = [" "]
        for i in 0 ..< self.deptEmployeeArray.count {
            let stringToTest = self.deptEmployeeArray[i].deptName!
            let colorToTest = self.deptEmployeeArray[i].deptColor!
            
            
            //let firstCharacter = String(stringToTest[stringToTest.startIndex])
            if(i == 0){
                deptTitleArray.append(stringToTest)
                deptColorArray.append(colorToTest)
                
            }
            if !deptTitleArray.contains(stringToTest) {
                //print("new")
                let title = deptTitleArray[deptTitleArray.count - 1]
                let color = deptColorArray[deptColorArray.count - 1]
                deptTitleArray.append(stringToTest)
                deptColorArray.append(colorToTest)
                //let color = self.employeeArray[i].deptColor!
                let newSection = (index: deptIndex, length: i - deptIndex, title: title, color: color)
                deptSections.append(newSection)
                deptIndex = i;
            }
            if(i == self.deptEmployeeArray.count - 1){
                let title = deptTitleArray[deptTitleArray.count - 1]
                let color = deptColorArray[deptColorArray.count - 1]
                let newSection = (index: deptIndex, length: i - deptIndex + 1, title: title, color: color)
                self.deptSections.append(newSection)
            }
        }
        
        
        var crewIndex = 0;
        var crewTitleArray:[String] = [" "]
        var crewColorArray:[String] = [" "]
        for i in 0 ..< self.crewEmployeeArray.count {
            let stringToTest = self.crewEmployeeArray[i].crewName!
            let colorToTest = self.crewEmployeeArray[i].crewColor!
            
            
            //let firstCharacter = String(stringToTest[stringToTest.startIndex])
            if(i == 0){
                crewTitleArray.append(stringToTest)
                crewColorArray.append(colorToTest)
                
            }
            if !crewTitleArray.contains(stringToTest) {
                //print("new")
                let title = crewTitleArray[crewTitleArray.count - 1]
                let color = crewColorArray[crewColorArray.count - 1]
                crewTitleArray.append(stringToTest)
                crewColorArray.append(colorToTest)
                //let color = self.employeeArray[i].crewColor!
                let newSection = (index: crewIndex, length: i - crewIndex, title: title, color: color)
                crewSections.append(newSection)
                crewIndex = i;
            }
            if(i == self.crewEmployeeArray.count - 1){
                let title = crewTitleArray[crewTitleArray.count - 1]
                let color = crewColorArray[crewColorArray.count - 1]
                let newSection = (index: crewIndex, length: i - crewIndex + 1, title: title, color: color)
                self.crewSections.append(newSection)
            }
        }
        
        //print("sections \(sections)")
    }
    
    
    func layoutViews(){
        
        // Close Indicator
        indicator.dismissIndicator()
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        let items = ["Departments","Crews"]
        customSC = SegmentedControl(items: items)
        
        
        customSC.addTarget(self, action: #selector(self.changeSort(sender:)), for: .valueChanged)
        
        switch currentSortMode {
        case "DEPTS":
            //equipmentArray.sorted(by: { $0.crewName > $1.crewName })
            customSC.selectedSegmentIndex = 0
            break
        case "CREWS":
            //equipmentArray.sorted(by: { $0.type > $1.type })
            customSC.selectedSegmentIndex = 1
            break
        
        default:
            //equipmentArray.sorted(by: { $0.status > $1.status })
            customSC.selectedSegmentIndex = 0
            break
        }
        
        
        safeContainer.addSubview(customSC)
        
        
       
        self.departmentTableView.delegate  =  self
        self.departmentTableView.dataSource = self
        departmentTableView.rowHeight = 60.0
        departmentTableView.layer.cornerRadius = 0
        self.departmentTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        safeContainer.addSubview(self.departmentTableView)
        
        noDepartmentLabel.text = "No Departments"
        noDepartmentLabel.textAlignment = NSTextAlignment.center
        noDepartmentLabel.font = layoutVars.largeFont
        safeContainer.addSubview(self.noDepartmentLabel)
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        //self.addDepartmentBtn.layer.cornerRadius = 0
        //self.addDepartmentBtn.addTarget(self, action: #selector(DepartmentListViewController.addDepartment), for: UIControl.Event.touchUpInside)
        //safeContainer.addSubview(self.addDepartmentBtn)
        
        
        //auto layout group
        let viewsDictionary = [
            "sc":customSC,
            "table":self.departmentTableView,
            "noDepartmentLbl":self.noDepartmentLabel,
            "count":self.countView
            
            ] as [String : Any]
        
        let sizeVals = ["halfWidth": layoutVars.halfWidth, "fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[sc(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noDepartmentLbl(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[count(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
       // safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addBtn(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sc(40)][table][count(30)]|", options:[], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sc(40)]-10-[noDepartmentLbl(40)]", options:[], metrics: sizeVals, views: viewsDictionary))
        
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    
    /*
    @objc func addDepartment(){
        //print("add department")
       
    }
    */
    
    @objc func changeSort(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentSortMode = "DEPTS"
            title = "\(self.empFirstName!)'s Departments"
            noDepartmentLabel.text = "No Departments"
            self.countLbl.text = "\(self.totalDepartments!) Department(s)"
            break
        case 1:
            currentSortMode = "CREWS"
            title = "\(self.empFirstName!)'s Crews"
            noDepartmentLabel.text = "No Crews"
            self.countLbl.text = "\(self.totalCrews!) Crew(s)"
            break
        default:
            noDepartmentLabel.text = "No Departments"
            title = "\(self.empFirstName!)'s Departments"
            currentSortMode = "DEPTS"
            self.countLbl.text = "\(self.totalDepartments!) Department(s)"
        }
        
        createSections()
        departmentTableView.reloadData()
        departmentTableView.reloadSectionIndexTitles()
        
        scrollToTop()
        
    }
    
    func scrollToTop() {
        if (self.departmentTableView.numberOfSections > 0 ) {
            let top = NSIndexPath(row: Foundation.NSNotFound, section: 0)
            self.departmentTableView.scrollToRow(at: top as IndexPath, at: .top, animated: true);
        }
    }
    
    
    
    
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch currentSortMode {
        case "DEPTS":
            return deptSections.count
        case "CREWS":
            return crewSections.count
        default:
            return deptSections.count
            
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ////print("titleForHeaderInSection")
        var title:String
        switch currentSortMode {
        case "DEPTS":
             title =  "                " + deptSections[section].title
        case "CREWS":
             title = "                " + crewSections[section].title
        default:
             title = "                " + deptSections[section].title
            
        }
        return title
        
           // return "                " + sections[section].title //hack way of indenting section text
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //print("heightForHeaderInSection")
            return 60
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRowsInSection")
        
        
       // return sections[section].length
        
        switch currentSortMode {
        case "DEPTS":
            
            
            
            
           
            
            return deptSections[section].length
        case "CREWS":
            //title = "\(self.empFirstName!)'s Crews"
            return crewSections[section].length
            
        default:
           // title = "\(self.empFirstName!)'s Departments"

            return deptSections[section].length
            
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        //print("viewForHeaderInSection")
         let headerView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: 60.0))
        
        headerView.backgroundColor = UIColor.clear
        
        switch currentSortMode {
        case "DEPTS":
            let lblBg = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth , height: 60.0))
            lblBg.backgroundColor = UIColor.lightGray
            lblBg.alpha = 0.5
            headerView.addSubview(lblBg)
            
            let titleLbl = Label(text: "\(deptSections[section].title) Department")
            titleLbl.font = layoutVars.buttonFont
            titleLbl.frame = CGRect(x: 70.0, y: 10.0, width: layoutVars.fullWidth - 80.0, height: 40.0)
            titleLbl.translatesAutoresizingMaskIntoConstraints = true
            
            headerView.addSubview(titleLbl)
            
            //print("color = \(sections[section].color)")
            
            let colorSwatch = UIView(frame: CGRect(x: 10.0, y: 5.0, width: 50.0, height: 50.0))
            colorSwatch.backgroundColor = layoutVars.hexStringToUIColor(hex: deptSections[section].color)
            colorSwatch.layer.cornerRadius = 5.0
            colorSwatch.layer.borderWidth = 1
            colorSwatch.layer.borderColor = layoutVars.borderColor
            headerView.addSubview(colorSwatch)
            break
        case "CREWS":
            let lblBg = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth , height: 60.0))
            lblBg.backgroundColor = UIColor.lightGray
            lblBg.alpha = 0.5
            headerView.addSubview(lblBg)
            
            let titleLbl = Label(text: "\(crewSections[section].title) Crew")
            titleLbl.font = layoutVars.buttonFont
            titleLbl.frame = CGRect(x: 70.0, y: 10.0, width: layoutVars.fullWidth - 80.0, height: 40.0)
            titleLbl.translatesAutoresizingMaskIntoConstraints = true
            
            headerView.addSubview(titleLbl)
            
            //print("color = \(sections[section].color)")
            
            let colorSwatch = UIView(frame: CGRect(x: 10.0, y: 5.0, width: 50.0, height: 50.0))
            colorSwatch.backgroundColor = layoutVars.hexStringToUIColor(hex: crewSections[section].color)
            colorSwatch.layer.cornerRadius = 5.0
            colorSwatch.layer.borderWidth = 1
            colorSwatch.layer.borderColor = layoutVars.borderColor
            headerView.addSubview(colorSwatch)
            break
        default:
            let lblBg = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth , height: 60.0))
            lblBg.backgroundColor = UIColor.lightGray
            lblBg.alpha = 0.5
            headerView.addSubview(lblBg)
            
            let titleLbl = Label(text: "\(deptSections[section].title) Department")
            titleLbl.font = layoutVars.buttonFont
            titleLbl.frame = CGRect(x: 70.0, y: 10.0, width: layoutVars.fullWidth - 80.0, height: 40.0)
            titleLbl.translatesAutoresizingMaskIntoConstraints = true
            
            headerView.addSubview(titleLbl)
            
            //print("color = \(sections[section].color)")
            
            let colorSwatch = UIView(frame: CGRect(x: 10.0, y: 5.0, width: 50.0, height: 50.0))
            colorSwatch.backgroundColor = layoutVars.hexStringToUIColor(hex: deptSections[section].color)
            colorSwatch.layer.cornerRadius = 5.0
            colorSwatch.layer.borderWidth = 1
            colorSwatch.layer.borderColor = layoutVars.borderColor
            headerView.addSubview(colorSwatch)
            
        }
        
        
        
       
        //headerView.alpha = 0.5
        // Do your customization
        
        
        
        //print("colorSwatch.width = \(colorSwatch.frame.width)")
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print("cell for row \(indexPath.row)")
        
        let cell:EmployeeTableViewCell = departmentTableView.dequeueReusableCell(withIdentifier: "cell") as! EmployeeTableViewCell
        
        switch currentSortMode {
        case "DEPTS":
            cell.employee = self.deptEmployeeArray[deptSections[indexPath.section].index + indexPath.row]
            break
        case "CREWS":
             cell.employee = self.crewEmployeeArray[crewSections[indexPath.section].index + indexPath.row]
            break
        default:
             cell.employee = self.deptEmployeeArray[deptSections[indexPath.section].index + indexPath.row]
            
        }
        
        
        
        cell.layoutViews()
        cell.activityView.startAnimating()
        cell.nameLbl.text = cell.employee.name
        cell.setImageUrl(_url: "https://atlanticlawnandgarden.com/uploads/general/thumbs/"+cell.employee.pic!)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! EmployeeTableViewCell
        
        self.employeeViewController = EmployeeViewController(_employee: currentCell.employee)
        tableView.deselectRow(at: indexPath!, animated: true)
        
        navigationController?.pushViewController(self.employeeViewController, animated: false )
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let currentCell = tableView.cellForRow(at: indexPath as IndexPath) as! EmployeeTableViewCell;
        let call = UITableViewRowAction(style: .normal, title: "Call") { action, index in
            //print("call button tapped")
            //callPhoneNumber(currentCell.employee.phone)
            if (cleanPhoneNumber(currentCell.employee.phone) != "No Number Saved"){
                UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(currentCell.employee.phone))")! as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            tableView.setEditing(false, animated: true)
        }
        call.backgroundColor = self.layoutVars.buttonColor1
        let text = UITableViewRowAction(style: .normal, title: "Text") { action, index in
            if (cleanPhoneNumber(currentCell.employee.phone) != "No Number Saved"){
                if (MFMessageComposeViewController.canSendText()) {
                    self.controller = MFMessageComposeViewController()
                    self.controller.recipients = [currentCell.employee.phone]
                    self.controller.messageComposeDelegate = self
                    
                    self.controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EmployeeListViewController.dismissMessage))
                    
                    self.present(self.controller, animated: true, completion: nil)
                    tableView.setEditing(false, animated: true)
                }
            }
        }
        text.backgroundColor = UIColor.orange
        
        let group = UITableViewRowAction(style: .normal, title: "Group") { action, index in
            
            let sectionNumber = indexPath.section
            
            let groupMessageViewController:GroupMessageViewController!
            
            
            switch self.currentSortMode {
            case "DEPTS":
                groupMessageViewController = GroupMessageViewController(_employees: self.departmentArray[sectionNumber].employeeArray, _mode:"Dept.")
                
                break
            case "CREWS":
                groupMessageViewController = GroupMessageViewController(_employees: self.crewArray[sectionNumber].employeeArray, _mode:"Crew")
                
                break
            default:
                groupMessageViewController = GroupMessageViewController(_employees: self.departmentArray[sectionNumber].employeeArray, _mode:"Dept.")
                
                
            }
            
            
            
            
            self.navigationController?.pushViewController(groupMessageViewController, animated: false )
        }
        group.backgroundColor = UIColor.darkGray
        
        return [call,text,group]
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //print("didfinish")
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
        //getBatch()
        //print("try and send text")
        
    
    }
    
    
    @objc func dismissMessage(){
        //print("dismiss")
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
