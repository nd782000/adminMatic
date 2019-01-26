//
//  EquipmentInspectionTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
// 

import Foundation
import UIKit

class EquipmentInspectionTableViewCell: UITableViewCell {
    var layoutVars:LayoutVars = LayoutVars()
    
    
    
    var inspectionDelegate:EquipmentInspectionDelegate!
    
    var index:Int!
    //var questionID:String!
    //var questionName:String!
    //var answer:String!
    
    var inspectionQuestion:InspectionQuestion!
    
    
    var nameLbl: UILabel!
    var buttons:[Button]!
    var goodBtn:Button!
    var badBtn:Button!
    var naBtn:Button!
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
    }
    
    
    
    func layoutViews(){
        
        print("layout views")
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.selectionStyle = .none
        
        nameLbl = UILabel()
        nameLbl.font = layoutVars.labelBoldFont
        nameLbl.text = self.inspectionQuestion.name
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        
        self.buttons = [Button]()
        // create button1
        self.goodBtn = Button(titleText: "Good")
        self.goodBtn.backgroundColor = UIColor.lightGray
        self.goodBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
        self.goodBtn.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.goodBtn.layer.borderWidth = 1.0
        self.goodBtn.tag = 1
        
        self.goodBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.contentView.addSubview(self.goodBtn)
        buttons.append(self.goodBtn)
        
        self.badBtn = Button(titleText: "Bad")
        self.badBtn.backgroundColor = UIColor.lightGray
        self.badBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
        self.badBtn.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.badBtn.layer.borderWidth = 1.0
        self.badBtn.tag = 2
        
        self.badBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.contentView.addSubview(self.badBtn)
        buttons.append(self.badBtn)
        
        self.naBtn = Button(titleText: "N/A")
        self.naBtn.backgroundColor = UIColor.lightGray
        self.naBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
        self.naBtn.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.naBtn.layer.borderWidth = 1.0
        self.naBtn.tag = 3
        
        self.naBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.contentView.addSubview(self.naBtn)
        buttons.append(self.naBtn)
        
        
        
        switch (self.inspectionQuestion.answer) {
        case "1":
            self.setGoodBtn()
            break
        case "2":
            self.setBadBtn()
            break
        case "3":
            self.setNaBtn()
            break
        
        default:
            print("default")
            //do nothing
           
        }
       
        
        
        
         let sizeVals = ["width": (layoutVars.fullWidth - 40)/3] as [String : Any]
        
        let viewsDictionary = ["nameLbl":nameLbl,"goodBtn":goodBtn,"badBtn":badBtn,"naBtn":naBtn] as [String : Any]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameLbl]-|", options: [], metrics: nil, views: viewsDictionary))
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[goodBtn(width)]-10-[badBtn(width)]-10-[naBtn(width)]-10-|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][goodBtn(40)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][badBtn(40)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][naBtn(40)]-|", options: [], metrics: nil, views: viewsDictionary))
        
        
        
        
        
        
        
        
        
        
    }
    
    func setGoodBtn(){
        
        goodBtn.backgroundColor = UIColor(hex:0x005100, op: 1.0)
        goodBtn.setTitleColor(UIColor.white, for: .normal)
        
        badBtn.backgroundColor = UIColor.lightGray
        badBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
        
        naBtn.backgroundColor = UIColor.lightGray
        naBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
    }
    
    func setBadBtn(){
        
        badBtn.backgroundColor = UIColor(hex:0x005100, op: 1.0)
        badBtn.setTitleColor(UIColor.white, for: .normal)
        
        goodBtn.backgroundColor = UIColor.lightGray
        goodBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
        
        naBtn.backgroundColor = UIColor.lightGray
        naBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
    }
    
    func setNaBtn(){
        
        naBtn.backgroundColor = UIColor(hex:0x005100, op: 1.0)
        naBtn.setTitleColor(UIColor.white, for: .normal)
        
        badBtn.backgroundColor = UIColor.lightGray
        badBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
        
        goodBtn.backgroundColor = UIColor.lightGray
        goodBtn.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
    }
    
    @objc func buttonAction(sender: Button!){
        for button in buttons {
            //button.isSelected = false
            button.backgroundColor = UIColor.lightGray
            button.setTitleColor(UIColor(hex:0x005100, op: 1.0), for: .normal)
        }
        //sender.isSelected = true
        sender.backgroundColor = UIColor(hex:0x005100, op: 1.0)
        sender.setTitleColor(UIColor.white, for: .normal)
        self.inspectionDelegate.updateInspection(_index: self.index, _answer:"\(sender.tag)")
        // you may need to know which button to trigger some action
        // let buttonIndex = buttons.indexOf(sender)
    }
    
    
   
    
}
