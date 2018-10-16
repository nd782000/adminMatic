//
//  DepartmentListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/16/18.
//  Copyright © 2018 Nick. All rights reserved.
//



import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import MessageUI



class DepartmentListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate{
    var indicator: SDevIndicator!
    
    var empID:String!
    var empFirstName:String!
    var totalDepartments:Int!
    
    var departmentTableView:TableView!
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    var noDepartmentLabel:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var sections : [(index: Int, length :Int, title: String, color: String)] = Array()
    
    var departments: JSON!
    
    var departmentArray:[Department] = []
    
    var employeeArray:[Employee] = []
    
    var addDepartmentBtn:Button = Button(titleText: "Add Department")
    var editDepartmentsBtn:Button = Button(titleText: "Edit")
    
    var employeeViewController:EmployeeViewController!
    
    var controller:MFMessageComposeViewController = MFMessageComposeViewController()
    
    init(){
        super.init(nibName:nil,bundle:nil)
        print("init")
    }
    
    
    init(_empID:String,_empFirstName:String){
        super.init(nibName:nil,bundle:nil)
        print("init _empID = \(_empID)")
        self.empID = _empID
        self.empFirstName = _empFirstName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(self.empFirstName!)'s Departments"
        view.backgroundColor = layoutVars.backgroundColor
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(DepartmentListViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
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
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/departments.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("department response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    
                    
                    //print("JSON: \(json)")
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
            
            print("department name = \(department.name)")
            
            let empCount = self.departments["departments"][i]["employees"].count
            //self.totalItems = jsonCount
            print("emp count: \(empCount)")
            for n in 0 ..< empCount {
                
                
                let employee = Employee(_ID: self.departments["departments"][i]["employees"][n]["ID"].stringValue, _name: self.departments["departments"][i]["employees"][n]["name"].stringValue, _lname: self.departments["departments"][i]["employees"][n]["lname"].stringValue, _fname: self.departments["departments"][i]["employees"][n]["fname"].stringValue, _username: self.departments["departments"][i]["employees"][n]["username"].stringValue, _pic: self.departments["departments"][i]["employees"][n]["pic"].stringValue, _phone: self.departments["departments"][i]["employees"][n]["phone"].stringValue, _depID: self.departments["departments"][i]["employees"][n]["depID"].stringValue, _payRate: self.departments["departments"][i]["employees"][n]["payRate"].stringValue, _appScore: self.departments["departments"][i]["employees"][n]["appScore"].stringValue, _userLevel: self.departments["departments"][i]["employees"][n]["level"].intValue, _userLevelName: self.departments["departments"][i]["employees"][n]["levelName"].stringValue)
                
                employee.deptName = department.name!
                employee.deptColor = department.color!
                
                print("employee.deptColor = \(employee.deptColor)")
                
                self.employeeArray.append(employee)
                department.employeeArray.append(employee)
            }
            
            self.departmentArray.append(department)
            
        }
        
        createSections()
        
        
        self.layoutViews()
        
    }
    
    func createSections(){
        sections = []
        
        
        
        // build sections based on first letter(json is already sorted alphabetically)
        print("build sections")
        
        print("self.employeeArray.count = \(self.employeeArray.count)")
        
        var index = 0;
        var titleArray:[String] = [" "]
        var colorArray:[String] = [" "]
        for i in 0 ..< self.employeeArray.count {
            let stringToTest = self.employeeArray[i].deptName!
            let colorToTest = self.employeeArray[i].deptColor!
            
            
            //let firstCharacter = String(stringToTest[stringToTest.startIndex])
            if(i == 0){
                titleArray.append(stringToTest)
                colorArray.append(colorToTest)
                
            }
            if !titleArray.contains(stringToTest) {
                print("new")
                let title = titleArray[titleArray.count - 1]
                let color = colorArray[colorArray.count - 1]
                titleArray.append(stringToTest)
                colorArray.append(colorToTest)
                //let color = self.employeeArray[i].deptColor!
                let newSection = (index: index, length: i - index, title: title, color: color)
                sections.append(newSection)
                index = i;
            }
            if(i == self.employeeArray.count - 1){
                let title = titleArray[titleArray.count - 1]
                let color = colorArray[colorArray.count - 1]
                let newSection = (index: index, length: i - index + 1, title: title, color: color)
                self.sections.append(newSection)
            }
        }
        
        print("sections \(sections)")
    }
    
    
    func layoutViews(){
        
        // Close Indicator
        indicator.dismissIndicator()
        
       
        self.departmentTableView.delegate  =  self
        self.departmentTableView.dataSource = self
        departmentTableView.rowHeight = 60.0
        self.departmentTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        self.view.addSubview(self.departmentTableView)
        
        noDepartmentLabel.text = "No Departments"
        noDepartmentLabel.textAlignment = NSTextAlignment.center
        noDepartmentLabel.font = layoutVars.largeFont
        self.view.addSubview(self.noDepartmentLabel)
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        
        self.addDepartmentBtn.addTarget(self, action: #selector(DepartmentListViewController.addDepartment), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.addDepartmentBtn)
        
        
        //auto layout group
        let viewsDictionary = [
            "table":self.departmentTableView,
            "noDepartmentLbl":self.noDepartmentLabel,
            "count":self.countView,
            "addBtn":self.addDepartmentBtn,
            
            ] as [String : Any]
        
        let sizeVals = ["halfWidth": layoutVars.halfWidth, "fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noDepartmentLbl(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[count(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addBtn(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[table][count(30)][addBtn(40)]|", options:[], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[noDepartmentLbl(40)]", options:[], metrics: sizeVals, views: viewsDictionary))
        
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    
    
    @objc func addDepartment(){
        print("add department")
       
    }
    
    
    
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return sections.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        ////print("titleForHeaderInSection")
            return "                " + sections[section].title //hack way of indenting section text
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //print("heightForHeaderInSection")
            return 60
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        
        
        return sections[section].length
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        print("viewForHeaderInSection")
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: 60.0))
        headerView.backgroundColor = UIColor.clear
        //headerView.alpha = 0.5
        // Do your customization
        
        let lblBg = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth , height: 60.0))
        lblBg.backgroundColor = UIColor.lightGray
        lblBg.alpha = 0.5
        headerView.addSubview(lblBg)
        
        let titleLbl = Label(text: "\(sections[section].title) Department")
        titleLbl.font = layoutVars.buttonFont
        titleLbl.frame = CGRect(x: 70.0, y: 10.0, width: layoutVars.fullWidth - 80.0, height: 40.0)
        titleLbl.translatesAutoresizingMaskIntoConstraints = true
        
        headerView.addSubview(titleLbl)
        
        print("color = \(sections[section].color)")
        
        let colorSwatch = UIView(frame: CGRect(x: 10.0, y: 5.0, width: 50.0, height: 50.0))
        colorSwatch.backgroundColor = layoutVars.hexStringToUIColor(hex: sections[section].color)
        colorSwatch.layer.cornerRadius = 5.0
        colorSwatch.layer.borderWidth = 1
        colorSwatch.layer.borderColor = layoutVars.borderColor
        headerView.addSubview(colorSwatch)
        
        print("colorSwatch.width = \(colorSwatch.frame.width)")
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cell for row \(indexPath.row)")
        
        let cell:EmployeeTableViewCell = departmentTableView.dequeueReusableCell(withIdentifier: "cell") as! EmployeeTableViewCell
        
        
        cell.employee = self.employeeArray[sections[indexPath.section].index + indexPath.row]
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
                UIApplication.shared.open(NSURL(string: "tel://\(cleanPhoneNumber(currentCell.employee.phone))")! as URL, options: [:], completionHandler: nil)
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
            let groupMessageViewController = GroupMessageViewController(_employees: self.departmentArray[sectionNumber].employeeArray, _mode:"Dept.")
            
            
            self.navigationController?.pushViewController(groupMessageViewController, animated: false )
        }
        group.backgroundColor = UIColor.darkGray
        
        return [call,text,group]
    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print("didfinish")
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
        //getBatch()
        //print("try and send text")
        
    
    }
    
    
    @objc func dismissMessage(){
        print("dismiss")
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


