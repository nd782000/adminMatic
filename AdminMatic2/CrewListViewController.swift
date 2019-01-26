//
//  CrewListViewController.swift
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



class CrewListViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate{
    var indicator: SDevIndicator!
    
    var empID:String!
    var empFirstName:String!
    var totalCrews:Int!
    
    var crewTableView:TableView!
    
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    
    var noCrewLabel:Label = Label()
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var sections : [(index: Int, length :Int, title: String, color: String)] = Array()
    
    var crews: JSON!
    var crewArray:[Crew] = []
    
    var employeeArray:[Employee] = []
    
    
    
    var addCrewBtn:Button = Button(titleText: "Add Crew")
    var editCrewBtn:Button = Button(titleText: "Edit")
    
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
        title = "\(self.empFirstName!)'s Crews"
        view.backgroundColor = layoutVars.backgroundColor
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(DepartmentListViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        getCrewList()
    }
    
    
    func getCrewList() {
        //remove any added views (needed for table refresh
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        crewTableView = TableView()
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
        print("parameters = \(parameters)")
        
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/departments.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("crew response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    
                    print(" dismissIndicator")
                    self.indicator.dismissIndicator()
                    
                    
                    //print("JSON: \(json)")
                    self.crews = JSON(json)
                    self.parseJSON()
                }
                
        }
        
    }
    func parseJSON(){
        let jsonCount = self.crews["crews"].count
        self.totalCrews = jsonCount
        if self.totalCrews == 0{
            self.noCrewLabel.isHidden = false
            
        }else{
            self.noCrewLabel.isHidden = true
        }
        
        self.countLbl.text = "\(self.totalCrews!) Crew(s)"
        
        for i in 0 ..< jsonCount {
            
            //create an equipment object
            
            let crew = Crew(_ID: self.crews["crews"][i]["id"].stringValue, _name: self.crews["crews"][i]["name"].stringValue, _status: self.crews["crews"][i]["status"].stringValue, _color: self.crews["crews"][i]["subcolor"].stringValue, _crewHead: self.crews["crews"][i]["crewHead"].stringValue)
            
           // print("crew name = \(crew.name)")
            
            let empCount = self.crews["crews"][i]["employees"].count
            //self.totalItems = jsonCount
            print("emp count: \(empCount)")
            for n in 0 ..< empCount {
                
                
                let employee = Employee(_ID: self.crews["crews"][i]["employees"][n]["ID"].stringValue, _name: self.crews["crews"][i]["employees"][n]["name"].stringValue, _lname: self.crews["crews"][i]["employees"][n]["lname"].stringValue, _fname: self.crews["crews"][i]["employees"][n]["fname"].stringValue, _username: self.crews["crews"][i]["employees"][n]["username"].stringValue, _pic: self.crews["crews"][i]["employees"][n]["pic"].stringValue, _phone: self.crews["crews"][i]["employees"][n]["phone"].stringValue, _depID: self.crews["crews"][i]["employees"][n]["depID"].stringValue, _payRate: self.crews["crews"][i]["employees"][n]["payRate"].stringValue, _appScore: self.crews["crews"][i]["employees"][n]["appScore"].stringValue, _userLevel: self.crews["crews"][i]["employees"][n]["level"].intValue, _userLevelName: self.crews["crews"][i]["employees"][n]["levelName"].stringValue)
                
                employee.crewName = crew.name!
                employee.crewColor = crew.color!
                //employee.crewColor2 = crew.color2!
                
               // print("employee.crewColor = \(employee.crewColor)")
                
                
                //crew.employeeArray.append(employee)
                
                self.employeeArray.append(employee)
                
                crew.employeeArray.append(employee)
                
            }
            
            
            
            
            self.crewArray.append(crew)
            
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
            let stringToTest = self.employeeArray[i].crewName!
            let colorToTest = self.employeeArray[i].crewColor!
            
            
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
        
        
        self.crewTableView.delegate  =  self
        self.crewTableView.dataSource = self
        crewTableView.rowHeight = 60.0
        self.crewTableView.register(EmployeeTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        self.view.addSubview(self.crewTableView)
        
        noCrewLabel.text = "No Crews"
        noCrewLabel.textAlignment = NSTextAlignment.center
        noCrewLabel.font = layoutVars.largeFont
        self.view.addSubview(self.noCrewLabel)
        
        
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        
        self.addCrewBtn.addTarget(self, action: #selector(CrewListViewController.addCrew), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.addCrewBtn)
        
        
        //auto layout group
        let viewsDictionary = [
            "table":self.crewTableView,
            "noCrewLbl":self.noCrewLabel,
            "count":self.countView,
            "addBtn":self.addCrewBtn,
            
            ] as [String : Any]
        
        let sizeVals = ["halfWidth": layoutVars.halfWidth, "fullWidth": layoutVars.fullWidth,"width": layoutVars.fullWidth - 30,"navBottom":layoutVars.navAndStatusBarHeight,"height": self.view.frame.size.height - layoutVars.navAndStatusBarHeight] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[table(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noCrewLbl(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[count(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addBtn(fullWidth)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[table][count(30)][addBtn(40)]|", options:[], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-navBottom-[noCrewLbl(40)]", options:[], metrics: sizeVals, views: viewsDictionary))
        
        
        let viewsDictionary2 = [
            
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    
    
    @objc func addCrew(){
        print("add crew")
        
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
        //let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: 60.0))
        headerView.backgroundColor = UIColor.clear
        //headerView.alpha = 0.5
        // Do your customization
        
        //colorSwatch.layer.cornerRadius = 4.0
        //colorSwatch.alpha = 1.0
        
        let lblBg = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth , height: 60.0))
        lblBg.backgroundColor = UIColor.lightGray
        lblBg.alpha = 0.5
        headerView.addSubview(lblBg)
        
        
        
        let titleLbl = Label(text: "\(sections[section].title) Crew")
        titleLbl.font = layoutVars.buttonFont
        titleLbl.frame = CGRect(x: 70.0, y: 10.0, width: layoutVars.fullWidth - 80.0, height: 40.0)
        titleLbl.translatesAutoresizingMaskIntoConstraints = true
        //titleLbl.text = sections[section].title
        
        //titleLbl.insets = UIEdgeInsetsMake(10.0, 50.0, 0.0, 0.0)
        
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
        
        let cell:EmployeeTableViewCell = crewTableView.dequeueReusableCell(withIdentifier: "cell") as! EmployeeTableViewCell
        
        
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
        let groupMessageViewController = GroupMessageViewController(_employees: self.crewArray[sectionNumber].employeeArray, _mode:"Crew")
            
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




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
