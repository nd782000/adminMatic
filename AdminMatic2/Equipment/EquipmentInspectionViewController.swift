//
//  EquipmentInspectionViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//




import Foundation
import UIKit
import Alamofire
import SwiftyJSON


protocol EquipmentInspectionDelegate{
    func updateInspection(_index:Int,_answer:String)
}



class EquipmentInspectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, EquipmentInspectionDelegate{
    var indicator: SDevIndicator!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var serviceListDelegate:ServiceListDelegate!
    
    var equipment:Equipment!
    var equipmentService:EquipmentService!
    
    var questionArray:[InspectionQuestion] = []
    var questionsToLogJSON: [JSON] = []//data array
    
    var notes:String = ""
    
    
    
    var inspectionTableView:TableView!
    
    var notesLbl:GreyLabel!
    var notesTxtView:UITextView = UITextView()
    
    var editsMade:Bool = false
    var keyBoardShown:Bool = false
    
    var layoutVars:LayoutVars = LayoutVars()
    
    
    var submitBtn:Button = Button(titleText: "Submit")
    
    
    
    init(_equipment:Equipment,_equipmentService:EquipmentService){
        super.init(nibName:nil,bundle:nil)
        //print("init _equipmentService.ID = \(_equipmentService.ID)")
        //print("init current = \(_equipmentService.currentValue)")
        self.equipment = _equipment
        self.equipmentService = _equipmentService
        
        getInspection()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getInspection(){
        
        indicator = SDevIndicator.generate(self.view)!
        
        var parameters:[String:String]
        parameters = [
            "ID":self.equipmentService.ID
        ]
        
        print("parameters = \(parameters)")
        
        
        
        self.layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/get/inspection.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseString { response in
            print("inspection response = \(response)")}.responseJSON() {
            response in
            
            
            
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    
                    
                
                    let questions = json["questions"] as? [[String: Any]]
                    {
                        
                        print("json = \(json)")
                    for question in questions {
                        var ID:String = ""
                        var name:String = ""
                        var answer:String = ""
                        
                        if let _ID = question["questionID"] as? String {
                            //self.questionIDArray.append(ID)
                            ID = _ID
                            
                        }
                        if let _name = question["questionText"] as? String {
                            //self.questionNameArray.append(name)
                            name = _name
                        }
                        if let _answer = question["answer"] as? String {
                            //self.answerArray.append(answer)
                            answer = _answer
                        }
                        let inspectionQuestion:InspectionQuestion = InspectionQuestion(_ID: ID, _name: name, _answer: answer)
                        self.questionArray.append(inspectionQuestion)
                    }
                    
                    
                    
                    self.indicator.dismissIndicator()
                        
                    self.layoutViews()
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
 
                
                
        }
            
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
  
    
    
    
    
    func layoutViews(){
        
        
        title = "\(String(describing: self.equipment.name!)) Inspection"
        view.backgroundColor = layoutVars.backgroundColor
        
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        DispatchQueue.main.async {
            
            
            self.notesTxtView.contentOffset = CGPoint.zero
            self.notesTxtView.scrollRangeToVisible(NSRange(location:0, length:0))
        }
        
        
        
        
        // Close Indicator
        
        self.inspectionTableView = TableView()
        
        self.inspectionTableView.delegate  =  self
        self.inspectionTableView.dataSource = self
        self.inspectionTableView.rowHeight = 88.0
        self.inspectionTableView.register(EquipmentInspectionTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.inspectionTableView)
        
        
        
        //instructions
        self.notesLbl = GreyLabel()
        self.notesLbl.text = "Inspection Notes:"
        self.notesLbl.textAlignment = .left
        self.notesLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.notesLbl)
        
        self.notesTxtView.layer.borderWidth = 1
        self.notesTxtView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.notesTxtView.layer.cornerRadius = 4.0
        
        self.notesTxtView.backgroundColor = UIColor.white
        
        self.notesTxtView.font = layoutVars.smallFont
        self.notesTxtView.translatesAutoresizingMaskIntoConstraints = false
        self.notesTxtView.text = self.equipmentService.notes
        self.view.addSubview(self.notesTxtView)
        
        
        self.notesTxtView.returnKeyType = .done
        
        self.notesTxtView.delegate = self
        
        
        let notesToolBar = UIToolbar()
        notesToolBar.barStyle = UIBarStyle.default
        notesToolBar.barTintColor = UIColor(hex:0x005100, op:1)
        notesToolBar.sizeToFit()
        let closeNotesButton = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelNotesInput))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let setNotesButton = UIBarButtonItem(title: "Set", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.handleNotesChange))
        notesToolBar.setItems([closeNotesButton,spaceButton,setNotesButton], animated: false)
        notesToolBar.isUserInteractionEnabled = true
        self.notesTxtView.inputAccessoryView = notesToolBar
        
        
        
        
       
        
        self.submitBtn.addTarget(self, action: #selector(self.submit), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.submitBtn)
        
        
        self.inspectionTableView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.inspectionTableView.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        self.inspectionTableView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.inspectionTableView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor, constant:-158.0).isActive = true
        
        self.notesLbl.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant:10.0).isActive = true
        self.notesLbl.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor, constant:-128.0).isActive = true
        self.notesLbl.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20.0).isActive = true
        self.notesLbl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.notesTxtView.leftAnchor.constraint(equalTo: view.safeLeftAnchor, constant:10.0).isActive = true
        self.notesTxtView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor, constant:-48.0).isActive = true
        self.notesTxtView.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20.032).isActive = true
        self.notesTxtView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.submitBtn.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.submitBtn.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor).isActive = true
        self.submitBtn.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.submitBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
    }
    
    
    
    
   
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
        
    }
    
    
   
    
    

    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
        return self.questionArray.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = inspectionTableView.dequeueReusableCell(withIdentifier: "cell") as! EquipmentInspectionTableViewCell
        cell.index = indexPath.row
        
        cell.inspectionQuestion = self.questionArray[indexPath.row]
        cell.inspectionDelegate = self
        
       
        cell.layoutViews()
        
       
        
        
        
        return cell
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("shouldChangeTextInRange")
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textFieldDidBeginEditing")
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y -= 256
            
            
        }, completion: { finished in
            // //print("Napkins opened!")
        })
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textFieldDidEndEditing")
        if(self.view.frame.origin.y < 0){
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.view.frame.origin.y += 256
                
                
            }, completion: { finished in
            })
        }
        
    }
    
    
    @objc func cancelNotesInput(){
        print("Cancel Notes Input")
        self.notesTxtView.resignFirstResponder()
    }
    @objc func handleNotesChange(){
        print("Set Notes Input")
        self.notesTxtView.resignFirstResponder()
        self.notes = self.notesTxtView.text
        
        editsMade = true
    }
    
    
    
    
    
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            if(!keyBoardShown){
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.view.frame.origin.y -= keyboardFrame.height
                    
                }, completion: { finished in
                })
            }
        }
        keyBoardShown = true
    }
    
    
    @objc func keyboardDidHide(notification: NSNotification) {
        keyBoardShown = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame.origin.y = 0
            
        }, completion: { finished in
        })
        
    }
    
    
   
   
    
   
    
   
    
    
    
    func updateInspection(_index:Int,_answer:String){
        print("updateInspection with index: \(_index) value:\(_answer)")
        
       
        editsMade = true
        
        self.questionArray[_index].answer = _answer
        
    }
    
    func verify()->Bool{
        print("verify")
        
        for question in self.questionArray{
            if question.answer == "0"{
                indicateAllFields()
                return false
            }
        }
        
        return true
        
        
    }
    
    func indicateAllFields(){
        self.layoutVars.simpleAlert(_vc: self, _title: "Indicate All Fields", _message: "")
    }
    
    @objc func submit(){
        print("submit")
        
        if self.equipmentService.status == "2" || self.equipmentService.status == "3"{
            //need userLevel greater then 1 to access this
            if self.layoutVars.grantAccess(_level: 2,_view: self) {
                
                return
            }
        }
        
        if !self.verify(){
            return
        }
        
        
        
        indicator = SDevIndicator.generate(self.view)!
        
        
       
        questionsToLogJSON = []
        
        
        for (index, question) in self.questionArray.enumerated() {
            
                        let JSONString = question.toJSONString(prettyPrint: true)
                        questionsToLogJSON.append(JSON(JSONString ?? ""))
                        print("usage JSONString = \(String(describing: JSONString))")
            
            
            }
        
        
        
        
        
        var parameters:[String:String]
        parameters = [
            "ID":self.equipmentService.ID,
            "completedBy":(self.appDelegate.loggedInEmployee?.ID)!,
            "completeValue":self.equipmentService.completionMileage,
            "completionNotes":self.notesTxtView.text,
            "nextValue":self.equipmentService.nextValue,
            "questions": "\(questionsToLogJSON)",
            "status":"2"
            
        ]
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.atlanticlawnandgarden.com/cp/app/functions/update/equipmentServiceComplete.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
            response in
            
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // URL response
            print(response.data ?? "")     // server data
            print(response.result)   // result of response serialization
            
           
            
            self.serviceListDelegate.updateServiceList()
            
            self.editsMade = false
            
            self.indicator.dismissIndicator()
            
            //if equipment isn't already set to broken
            //loop through questions to see if any have a "Bad" answer
                //ask user to set equipment status to "needs service" or "broken"
            if self.equipment.status != "2" {
                var shouldUpdateEquipmentStatus:Bool = false
                for question in self.questionArray{
                    if question.answer == "2"{
                        shouldUpdateEquipmentStatus = true
                    }
                }
                
                if shouldUpdateEquipmentStatus{
                    let alertController = UIAlertController(title: "Update Equipment", message: "You marked a question to BAD, do you want to update equipment status?", preferredStyle: UIAlertController.Style.alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                        (result : UIAlertAction) -> Void in
                        print("Cancel")
                        self.serviceListDelegate.updateServiceList()
                        self.goBack()
                    }
                    
                    let serviceAction = UIAlertAction(title: "Service", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        print("Service")
                        self.equipment.status = "1"
                        self.serviceListDelegate.updateServiceList()
                        self.serviceListDelegate.updateEquipmentStatus(_equipment: self.equipment)
                        self.goBack()
                    }
                    
                    let brokenAction = UIAlertAction(title: "Broken", style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        print("Broken")
                        self.equipment.status = "2"
                        self.serviceListDelegate.updateServiceList()
                        self.serviceListDelegate.updateEquipmentStatus(_equipment: self.equipment)
                        self.goBack()
                    }
                    
                    alertController.addAction(cancelAction)
                    //check if equipment isn't already set to needsService
                    if self.equipment.status != "1"{
                        alertController.addAction(serviceAction)
                    }
                    
                    alertController.addAction(brokenAction)
                    self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                }else{
                    self.serviceListDelegate.updateServiceList()
                    self.goBack()
                }
            }else{
                self.serviceListDelegate.updateServiceList()
                self.goBack()
            }
            
           
            
            
            self.layoutVars.playSaveSound()
            
            
            }.responseString() {
                response in
                print(response)  // original URL request
        }
        
        
        
    }
    
    
    @objc func goBack(){
        
        if(self.editsMade == true){
            print("editsMade = true")
            let alertController = UIAlertController(title: "Edits Made", message: "Leave without submitting?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
                //self.submit()
                
                
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            
            _ = navigationController?.popViewController(animated: true)
        }
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


