//
//  SignatureViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/8/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON


protocol EditTermsDelegate{
    func updateTerms(_terms:String)
}

 

class SignatureViewController: UIViewController, YPSignatureDelegate, EditTermsDelegate{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    var delegate:EditContractDelegate!
    
    var termsBtn:Button = Button(titleText: "By signing I accept the terms.")
    
    var signatureView:YPDrawSignatureView = YPDrawSignatureView()
    
    var clearBtn:Button = Button(titleText: "Clear")
    var acceptBtn:Button = Button(titleText: "Accept")
    
    
    var contract:Contract!
    var employee:Employee!
    
    var signatureImage:UIImage!
    
    
   
    let saveURLString:String = "https://www.atlanticlawnandgarden.com/cp/app/functions/update/signature.php"
    
    var progressLbl: UILabel! = UILabel()
    var progressView:UIProgressView!
    var progressValue:Float!

    
    
    //from contract view
    init(_contract:Contract){
        self.contract = _contract
        
        super.init(nibName:nil,bundle:nil)
    }
    
    //from employee view
    init(_employee:Employee){
        self.employee = _employee
        
        super.init(nibName:nil,bundle:nil)
    }
    
    //from contract view for employee signature
    init(_employee:Employee, _contract:Contract){
        self.employee = _employee
        self.contract = _contract
        super.init(nibName:nil,bundle:nil)
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Signature View"
        
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(CustomerViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        
        signatureView.delegate = self
    
        layoutViews()
    }
    
    
   
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        layoutViews()
        
    }

    
    
    
    func layoutViews(){
        //print("customer view layoutViews")
        //////////   containers for different sections
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.termsBtn.addTarget(self, action: #selector(SignatureViewController.terms), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.termsBtn)
        
        self.signatureView.backgroundColor = UIColor.clear
        self.signatureView.layer.borderWidth = 1
        self.signatureView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.signatureView.layer.cornerRadius = 4.0
        
        self.signatureView.translatesAutoresizingMaskIntoConstraints = false
        
        safeContainer.addSubview(self.signatureView)
        
        self.clearBtn.addTarget(self, action: #selector(SignatureViewController.clear), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.clearBtn)
        
        self.acceptBtn.addTarget(self, action: #selector(SignatureViewController.accept), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.acceptBtn)
        
        
        self.progressLbl = Label(text: "", valueMode: false)
        self.progressLbl.font = self.progressLbl.font.withSize(20)
        self.progressLbl.textAlignment = .right
        self.progressLbl.translatesAutoresizingMaskIntoConstraints = false
        self.progressLbl.isHidden = true
        safeContainer.addSubview(self.progressLbl)
        
        self.progressView = UIProgressView()
        self.progressView.tintColor = layoutVars.buttonColor1
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.isHidden = true
        safeContainer.addSubview(self.progressView)
        
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 24,"halfWidth": layoutVars.halfWidth] as [String:Any]
        
        
        //print("1")
        //auto layout group
        let viewsDictionary = [
            "termsBtn":self.termsBtn,
            "signView":self.signatureView,
            "clearBtn":self.clearBtn,
            "acceptBtn":self.acceptBtn,
            "progressLbl":self.progressLbl,
            "progressView":self.progressView
            ] as [String:Any]
        
        
        
        //////////////   auto layout position constraints   /////////////////////////////
        
        if self.employee == nil{
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[termsBtn]-|", options: [], metrics: nil, views: viewsDictionary))
        }
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[signView]-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[clearBtn(halfWidth)]-[acceptBtn]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[progressLbl][progressView(80)]-|", options: [], metrics: nil, views: viewsDictionary))
       
        if self.employee == nil{
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[termsBtn(40)]-[signView]-[clearBtn(40)]-10-|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[termsBtn(40)]-[signView]-[acceptBtn(40)]-10-|", options: [], metrics: nil, views: viewsDictionary))
        }else{
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[signView]-[clearBtn(40)]-10-|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[signView]-[acceptBtn(40)]-10-|", options: [], metrics: nil, views: viewsDictionary))
        }
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-52-[progressLbl(20)]", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-52-[progressView(10)]", options: [], metrics: nil, views: viewsDictionary))
        
    }
    
    
    
    
    
    // MARK: - Delegate Methods
    
    // The delegate functions gives feedback to the instanciating class. All functions are optional,
    // meaning you just implement the one you need.
    
    // didStart(_ view: YPDrawSignatureView) is called right after the first touch is registered in the view.
    // For example, this can be used if the view is embedded in a scroll view, temporary
    // stopping it from scrolling while signing.
    func didStart(_ view: YPDrawSignatureView) {
        //print("Started Drawing")
    }
    
    // didFinish(_ view: YPDrawSignatureView) is called rigth after the last touch of a gesture is registered in the view.
    // Can be used to enabe scrolling in a scroll view if it has previous been disabled.
    func didFinish(_ view: YPDrawSignatureView) {
        //print("Finished Drawing")
    }
    
    
    
    
    
    
    
    @objc func terms(){
        //print("terms")
        let termsViewController:TermsViewController = TermsViewController(_terms: self.contract.terms, _contractID: self.contract.ID, _editable: false)
        termsViewController.delegate = self
        navigationController?.pushViewController(termsViewController, animated: false )
    }
    
    
    
    
    @objc func clear(){
        //print("clear")
        self.signatureView.clear()
        
    }
    
    @objc func accept(){
        //print("accept")
        
        if self.signatureView.getSignature() != nil {
            
            self.signatureImage = self.signatureView.getCroppedSignature()
            
            self.uploadSignature()
            
        }else{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Please Sign", _message: "")
        }
        
        
        
        
    }
    
    
    
    
    func uploadSignature(){
        //print("start customer upload")
       
        
        var parameters:[String:String]
        
        //types
            //1 = customer
            //2 = company
        if self.employee == nil{
            parameters = [
                "type":"1",
                "contractID": self.contract.ID,
                "customerID": self.contract.customer
            ]
        }else{
            parameters = [
                "type":"2",
                "employeeID":self.employee.ID
            ]
        }
        
        
        //print("parameters = \(parameters)")
        
        let URL = try! URLRequest(url: self.saveURLString, method: .post, headers: nil)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            //print("alamofire upload")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
            
            
            if  let imageData = self.signatureImage!.fixedOrientation().jpegData(compressionQuality: 0.85) {
                multipartFormData.append(imageData, withName: "pic", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
                
            }
            
            
        }, with: URL, encodingCompletion: { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                //print("success")
                self.progressLbl.isHidden = false
                upload.uploadProgress(closure: { (Progress) in
                    //print("Upload Progress: \(Progress.fractionCompleted)")
                    
                    DispatchQueue.main.async() {
                        
                        self.progressView.progress = Float(Progress.fractionCompleted)
                        self.progressLbl.text = "Uploading Signature \(Float(Progress.fractionCompleted))%"
                        if  (Progress.fractionCompleted == 1.0) {
                            //print("upload finished")
                            self.progressLbl.isHidden = true
                            
                            if self.employee == nil{
                                self.contract.customerSignature = "1"
                                self.updateContractStatus()
                            }else{
                                if self.contract != nil{
                                    self.contract.repSignature = "1"
                                }
                                self.completeEmployeeUpload()
                            }
                            
                            
                        }
                    }
                })
                
                upload.responseJSON { response in
                    // //print(response.request ?? "")  // original URL request
                    ////print(response.response ?? "") // URL response
                    // //print(response.data ?? "")     // server data
                    //print("result = \(response.result)")   // result of response serialization
                    
                    if("\(response.result)" == "FAILURE") {
                        self.layoutVars.playErrorSound()
                        self.progressLbl.text = "Upload Failed"
                        self.progressLbl.textColor = UIColor.red
                        self.progressView.progressTintColor = UIColor.red
                    }
                    
                    if let result = response.result.value {
                        self.layoutVars.playSaveSound()
                        let json = result as! NSDictionary
                        let thumbBase = JSON(json)["thumbBase"].stringValue
                        let mediumBase = JSON(json)["mediumBase"].stringValue
                        let rawBase = JSON(json)["rawBase"].stringValue
                        let thumbPath = "\(thumbBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                        let mediumPath = "\(mediumBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                        let rawPath = "\(rawBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                        
                       
                        let image = Image(_id: JSON(json)["images"][0]["ID"].stringValue, _thumbPath: thumbPath, _mediumPath: mediumPath, _rawPath: rawPath, _name: JSON(json)["images"][0]["name"].stringValue, _width: JSON(json)["images"][0]["width"].stringValue, _height: JSON(json)["images"][0]["height"].stringValue, _description: JSON(json)["images"][0]["description"].stringValue, _dateAdded: JSON(json)["images"][0]["dateAdded"].stringValue, _createdBy: JSON(json)["images"][0]["createdBy"].stringValue, _type: JSON(json)["images"][0]["type"].stringValue)
                        
                        image.customer = JSON(json)["images"][0]["customer"].stringValue
                        image.woID = JSON(json)["images"][0]["woID"].stringValue
                        image.tags = JSON(json)["images"][0]["tags"].stringValue
                        
                    }
                }
                upload.responseString { response in
                    //print("RESPONSE: \(response)")
                }
            case .failure(let encodingError):
                //print("fail \(encodingError)")
                
                self.layoutVars.playErrorSound()
                
                self.progressLbl.text = "Failed"
                self.progressLbl.textColor = UIColor.red
                self.progressView.progressTintColor = UIColor.red
                
            }
        })
        
    }
    
    
    
    @objc func updateContractStatus() {
        
        //print("update contract status")
        ////print("contract status = \(self.contract.status)")
        
        
        if self.contract.status == "2"{
            //contract is already set to ACCEPTED
            self.delegate.updateContract(_contract: self.contract)
            self.goBack()
            
        }else{
            let alertController = UIAlertController(title: "Update Contract Status?", message: "Do you want to set the contract to ACCEPTED?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                self.signatureView.clear()
                self.delegate.updateContract(_contract: self.contract)
                self.goBack()
            }
            let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
                self.signatureView.clear()
                self.contract.status = "2"
                self.delegate.updateContract(_contract: self.contract,_status:"2")
                self.goBack()
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
        
    
    }
    
    
    
    @objc func completeEmployeeUpload() {
        
        //print("completeEmployeeUpload")
        
            let alertController = UIAlertController(title: "Your Signature is All Set", message: "", preferredStyle: UIAlertController.Style.alert)
        
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
                if(self.delegate != nil){
                    self.delegate.updateContract(_contract: self.contract)
                }
                
                self.appDelegate.loggedInEmployee?.hasSignature = true
                
                for rep in self.appDelegate.salesRepArray {
                    //print("looping through sales rep array to update")
                    if self.contract != nil{
                        if self.contract.salesRep == rep.ID{
                            rep.hasSignature = true
                        }
                    }
                    
                }
                
                
                self.goBack()
                
            }
            alertController.addAction(okAction)
            present(alertController, animated: true)
       
        
        
    }
    
    
    
    
  
    
    
    
     @objc func canRotate() -> Void {}
   
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    func updateTerms(_terms:String){
        self.contract.terms = _terms
        if(self.delegate != nil){
            self.delegate.updateContract(_contract: self.contract)
        }
    }
    
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
