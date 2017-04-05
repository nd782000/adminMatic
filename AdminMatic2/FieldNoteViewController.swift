//
//  FieldNoteViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/11/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class FieldNoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UITextViewDelegate, UIActionSheetDelegate{
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var delegate:FieldNoteDelegate!
    
    var loadingView:UIView!
    
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var noteTxtView: UITextView!
    var notePlaceHolder:String = "Write Field Note Here..."
    
    var fieldNote:FieldNote!
    
    var backButton: UIButton!
    var defaultImage : UIImage = UIImage(named:"cameraIcon.png")!
    var baseUrl = "https://atlanticlawnandgarden.com/uploads/general/"
    var imageView:UIImageView!
    var progressView:UIProgressView!
    var progressValue:Float!
    var progressLbl:Label!
    var drawButton:Button!
    var submitNoteButton:Button!
    let picker = UIImagePickerController()
    var imagePicked:Bool = false
    //var editsMade:Bool = false
    var imageEdit:Bool = false
    var fieldNotes:[FieldNote] = []
    
    let fieldNoteCount:Int = 0
    
    init(_fieldNote:FieldNote){
        super.init(nibName:nil,bundle:nil)
        self.fieldNote = _fieldNote
        //print("pic = \(self.fieldNote.pic)")
        //print("note = \(self.fieldNote.note)")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: layoutVars.fullHeight))
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Field Note"
        
        
        //custom back button
        backButton = UIButton(type: UIButtonType.custom)
        backButton.addTarget(self, action: #selector(FieldNoteViewController.goBack), for: UIControlEvents.touchUpInside)
        backButton.setTitle("Back", for: UIControlState.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        
        
        self.picker.delegate = self
        
        
        self.noteTxtView = UITextView()
        if(self.fieldNote.note == ""){
            //empty text box
            self.noteTxtView.text = notePlaceHolder
            self.noteTxtView.textColor = UIColor.lightGray
            
        }else{
            //set text box
            self.noteTxtView.text = self.fieldNote.note
            self.noteTxtView.textColor = UIColor.black
        }
        
        
        self.noteTxtView.translatesAutoresizingMaskIntoConstraints = false
        self.noteTxtView.delegate = self
        self.noteTxtView.contentInset = UIEdgeInsetsMake(-65.0,10.0,0,0.0);
        self.noteTxtView.font = layoutVars.smallFont
        self.noteTxtView.returnKeyType = UIReturnKeyType.done
        self.noteTxtView.layer.borderWidth = 2
        self.noteTxtView.layer.borderColor = layoutVars.borderColor
        self.noteTxtView.backgroundColor = layoutVars.backgroundLight
        self.noteTxtView.showsHorizontalScrollIndicator = false;
        self.view.addSubview(self.noteTxtView)
    
        self.imageView = UIImageView()
        self.imageView.backgroundColor = layoutVars.backgroundLight
        self.imageView.layer.borderWidth = 2
        self.imageView.layer.borderColor = layoutVars.borderColor
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.isUserInteractionEnabled = true
    
        
        /*
        if(self.fieldNote.pic == "0"){
            setBlankImage()
        }else{
            setImageUrl(_url: self.fieldNote.pic)
        }
 
 */
        
        
        self.imageView.clipsToBounds = true
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.imageView)
        
        
       
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(FieldNoteViewController.imageTapped(gesture:)))
        
        self.imageView.addGestureRecognizer(imageTapGesture)
        
        self.progressView = UIProgressView()
        self.progressView.tintColor = layoutVars.buttonColor1
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingView.addSubview(self.progressView)
        
        self.progressLbl = Label(text: "Uploading...", valueMode: false)
        self.progressLbl.font = self.progressLbl.font.withSize(20)
        self.progressLbl.translatesAutoresizingMaskIntoConstraints = false
        self.progressLbl.textAlignment = NSTextAlignment.center
        self.loadingView.addSubview(self.progressLbl)
        
        
        
        self.drawButton = Button(titleText: "Doodler")
        self.drawButton.addTarget(self, action: #selector(FieldNoteViewController.draw), for: UIControlEvents.touchUpInside)
        
        
        /*
        if(self.fieldNote.pic == "0"){
            self.drawButton.isEnabled = false
            self.drawButton.alpha = 0.0
        }
        
        self.view.addSubview(self.drawButton)
 */
        
        
        
        self.submitNoteButton = Button(titleText: "Submit Note")
        self.submitNoteButton.addTarget(self, action: #selector(FieldNoteViewController.saveData), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.submitNoteButton)
        
        
        /////////////////  Auto Layout   ////////////////////////////////////////////////
        
        //apply to each view
        
        //auto layout group
        let viewsDictionary = [
            "note":self.noteTxtView,
            "image":self.imageView,
            "draw":self.drawButton,
            "submit":self.submitNoteButton
        ] as [String : Any]
        
        
        let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40] as [String : Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[note(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[image(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[draw(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[submit(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[note(80)]-15-[image(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[draw(40)]-[submit(40)]-15-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        let progressDictionary = [
            "bar":self.progressView,
            "label":self.progressLbl
        ] as [String : Any]
        
        
        self.loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[bar]-15-|", options: [], metrics: sizeVals, views: progressDictionary))
        self.loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[label]-15-|", options: [], metrics: sizeVals, views: progressDictionary))
        
        self.loadingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[label(height)]-4-[bar(4)]", options: [], metrics: sizeVals, views: progressDictionary))
        
        self.loadingView.backgroundColor = UIColor.white
        self.loadingView.alpha = 0
        self.view.addSubview(loadingView)
    }
    
    
    func setImageUrl(_url:String?){
        //print("setImageUrl")
        //print("ID = \(self.fieldNote.ID)")
        //print("url = \(baseUrl)\(_url!)")
        
        if(_url == nil){
            setBlankImage()
        }else{
            
            
            let imgUrl = URL(string: "\(baseUrl)\(_url!)")
            
            
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imgUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    self.self.imageView.image = UIImage(data: data!)
                }
            }
        }
    }
    
    func setBlankImage(){
        //print("setBlankImage")
        self.imageView.image = self.defaultImage
        
    }
    
    
    func imageTapped(gesture: UIGestureRecognizer) {
        //print("displayCamera")
        self.showActionSheet()
        
        self.noteTxtView.resignFirstResponder()
    }
    
    func showActionSheet() {
        //print("showActionSheet")
        
        
        if self.presentedViewController == nil {
            
            
            let actionSheet = UIAlertController(title: "Add Picture to Field Note", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            actionSheet.addAction(UIAlertAction(title: "Take New Picture", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                //print("show cam 1")
                self.camera()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "From Camera Roll", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                self.library()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert:UIAlertAction!) -> Void in
            }))
            
            self.present(actionSheet, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: {
                let actionSheet = UIAlertController(title: "Add Picture to Field Note", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                actionSheet.view.backgroundColor = UIColor.white
                actionSheet.view.layer.cornerRadius = 5;
                
                actionSheet.addAction(UIAlertAction(title: "Take New Picture", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                    //print("show cam 1")
                    self.camera()
                }))
                
                actionSheet.addAction(UIAlertAction(title: "From Camera Roll", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
                    self.library()
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert:UIAlertAction!) -> Void in
                }))
                
                self.present(actionSheet, animated: true, completion: nil)
            })
            
        }
        
    }
    
    func camera()
    {
        //print("Camera")
        
        self.picker.sourceType = UIImagePickerControllerSourceType.camera
        self.picker.cameraCaptureMode = .photo
        self.picker.allowsEditing = true
        self.picker.delegate = self
        
        
        _ = [self .present(self.picker, animated: true , completion: nil)]
        
    }
    
    func library()
    {
        //print("photoLibrary")
        self.picker.delegate = self;
        self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        _ = [self .present(self.picker, animated: true , completion: nil)]
        
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //print("didFinishPickingMediaWithInfo")
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            //print("image not nil")
            self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            self.imagePicked = true
            self.imageEdit = true
            UIView.animate(withDuration: 0.75, animations: {() -> Void in
                self.drawButton.alpha = 1
                self.drawButton.isEnabled = true
            })
        } else{
            //print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    

    
    
    //cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    func draw(){
        
        //print("Draw")
        /*
        let imageDrawingViewController = ImageDrawingViewController(_image:self.imageView.image!)
        imageDrawingViewController.delegate = self
        navigationController?.pushViewController(imageDrawingViewController, animated: false )
        imageEdit = true;
 */
        
        
    }
    
    
    
    
    
    
    
    
    func saveData(){
        //print("Save Data")
        
        
        if(self.noteTxtView.text != nil){
            //print("not nil")
            
            //if(self.fieldNote.note != self.noteTxtView.text!){
               // editsMade = true
            //}
            
           // //print("editsMade = \(self.editsMade)")
            
            self.fieldNote.note = self.noteTxtView.text!
            if(self.fieldNote.note == notePlaceHolder){
                self.fieldNote.note = ""
                if(self.imagePicked == false){
                    //print("show alert")
                    //show alert
                    
                    
                    
                    
                    let alertController = UIAlertController(title: "Give a Note or Image", message: "Simple alertView demo with Cancel and Ok.", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
                    let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                        (result : UIAlertAction) -> Void in
                        //print("Cancel")
                    }
                    
                    // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        //print("OK")
                    }
                    
                    alertController.addAction(DestructiveAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    /*
                    let alert = UIAlertView()
                    alert.title = "Give a Note or Image"
                    alert.addButton(withTitle: "OK")
                    alert.show()*/
                    return
                }
                
            }
        }
        
         showProgressScreen()
        
        var parameters:[String:String]
            parameters = [
                "ID": self.fieldNote.ID,
                "createdBy": self.fieldNote.createdBy,
                "workOrderID": self.fieldNote.workOrderID,
                "customerID": self.fieldNote.customerID,
                "note"      : self.fieldNote.note,
                "status":"0",
                "imageEdit":String(self.imageEdit)
            ]
        
        
        //print("parameters = \(parameters)")
        
        let URL = try! URLRequest(url: "https://www.atlanticlawnandgarden.com/cp/app/functions/new/fieldNote.php", method: .post, headers: nil)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            //print("alamofire upload")
            
            if(self.imagePicked == true || self.imageEdit == true){
                
                multipartFormData.append(UIImageJPEGRepresentation(self.imageView.image!.fixedOrientation(), 1)!, withName: "pic", fileName: "swift_file.jpeg", mimeType: "image/jpg")
            }
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, with: URL, encodingCompletion: { (result) in
            
           //print("result = \(result)")
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    //print("Upload Progress: \(Progress.fractionCompleted)")
                    
                    self.progressView.alpha = 1.0
                    DispatchQueue.main.async() {
                        self.progressView.setProgress(Float(Progress.fractionCompleted), animated: true)
                        
                        if  (Progress.fractionCompleted == 1.0) {
                            //print("upload finished")
                            self.hideProgressScreen()
                        }
                    }
                    
                })
                
                upload.responseJSON { response in
                    //print(response.request ?? "")  // original URL request
                    //print(response.response ?? "") // URL response
                    //print(response.data ?? "")     // server data
                    //print(response.result)   // result of response serialization
                    
                    
                    if let result = response.result.value {
                        let json = result as! NSDictionary
                        //print(json)
                        
                        
                        let fieldNotesJSON =  JSON(json)["fieldNotes"]
                        
                        //print("fieldNotesJSON = \(fieldNotesJSON.count)")
                        
                        
                        
                        self.fieldNotes = []
                        
                        //FieldNotes
                        for n in 0 ..< fieldNotesJSON.count {
                            
                            var picUrl = "0"
                            var thumbUrl = "0"
                            
                            if(fieldNotesJSON[n]["pic"].stringValue != "0" && fieldNotesJSON[n]["image"] != nil){
                                picUrl = "\(fieldNotesJSON[n]["image"]["name"].stringValue)(\(fieldNotesJSON[n]["pic"].stringValue)).\(fieldNotesJSON[n]["image"]["type"].stringValue)"
                                thumbUrl = "\(fieldNotesJSON[n]["image"]["name"].stringValue)(\(fieldNotesJSON[n]["pic"].stringValue)).\(fieldNotesJSON[n]["image"]["type"].stringValue)"
                            }
                            
                            //print("pic url = \(picUrl)")
                            //print("thumb url = \(thumbUrl)")
                            
                            
                            
                          //  let fieldNote = FieldNote(_ID: fieldNotesJSON[n]["ID"].stringValue, _note: fieldNotesJSON[n]["note"].stringValue, _customerID: fieldNotesJSON[n]["customerID"].stringValue, _workOrderID: fieldNotesJSON[n]["workOrderID"].stringValue, _createdBy: fieldNotesJSON[n]["createdBy"].stringValue, _status: fieldNotesJSON[n]["status"].stringValue, _pic: picUrl, _thumb: thumbUrl)
                            
                            
                           // self.fieldNotes.append(fieldNote)
                            
                        }
                        
                       // let scoreJSON =  JSON(json)["scoreAdjust"]
                        
                        
                        //add appPoints
                        var points:Int = JSON(json)["scoreAdjust"].intValue
                        //print("points = \(points)")
                        if(points > 0){
                            self.appDelegate.showMessage(_message: "earned \(points) App Points!")
                        }else if(points < 0){
                            points = points * -1
                            self.appDelegate.showMessage(_message: "lost \(points) App Points!")
                            
                        }
                        
                        
                    }
                    
                    if((self.delegate) != nil){
                       // self.delegate.updateTable(_fieldNotes: self.fieldNotes)
                    }
                    
                    
                    
                   
                    
                    
                    
                    
                }
                
                upload.responseString { response in
                    print("SUCCESS RESPONSE: \(response)")
                }
                
                
                
            case .failure(let encodingError):
                print(encodingError)
                            }
        })
    }
 
 
 
 
    func showProgressScreen(){
        //print("showProgressScreen")
        self.view.isUserInteractionEnabled = false
        self.submitNoteButton.isUserInteractionEnabled = false
        self.backButton.isUserInteractionEnabled = false
        self.progressView.alpha = 1.0
        UIView.animate(withDuration: 0.75, animations: {() -> Void in
            self.loadingView.alpha = 1
        })
    }
    
    func hideProgressScreen(){
        //print("hideProgressScreen")
        //self.progressLbl.text = "New Field Note Added. Thanks"
        
        
        UIView.animate(withDuration: 0.75, animations: {
            self.progressView.alpha = 0.0
            
        }, completion: {(finished:Bool) in
            // the code you put here will be compiled once the animation finishes
            self.resetForm()
        })
    }
    
    func resetForm(){
        //print("Reset Form")
        
        imagePicked = false
        imageEdit = false
        
        for view in self.view.subviews {
            if let fld = view as? PaddedTextField {
                fld.reset()
            }
        }
        self.progressView.setProgress(0, animated: false)
        
        UIView.animate(withDuration: 0.75, animations: {() -> Void in
            self.loadingView.alpha = 0
            self.view.isUserInteractionEnabled = true
        })
        
        self.backButton.isUserInteractionEnabled = true
        self.submitNoteButton.isUserInteractionEnabled = true
        self.noteTxtView.text = notePlaceHolder
        self.noteTxtView.textColor = UIColor.lightGray
        self.imageView.image = self.defaultImage
        
        UIView.animate(withDuration: 0.75, animations: {() -> Void in
            self.drawButton.alpha = 0
            self.drawButton.isEnabled = false
        })
        
    }
 
 
 
 
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.noteTxtView.textColor == UIColor.lightGray {
            self.noteTxtView.text = nil
            self.noteTxtView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.noteTxtView.text.isEmpty {
            self.noteTxtView.text = notePlaceHolder
            self.noteTxtView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    
    
    
    
    func goBack(){
        //print("Go Back")
        
        if(self.imageEdit == true){
            //print("edits made, should update list and wo")
            
            let alertController = UIAlertController(title: nil, message: "Leave without submitting?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let DestructiveAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
                //print("Cancel")
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                _ = self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(okAction)
            alertController.addAction(DestructiveAction)
            self.present(alertController, animated: true, completion: nil)
            
            
            
            
            
            
            
        }else{
            _ = navigationController?.popViewController(animated: true)
        }
        
        
        
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //print("text should return")
        textField.resignFirstResponder()
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateImage(_image: UIImage) {
        self.imageView.image = _image
    }
 
}




 
