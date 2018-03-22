//
//  EquipmentServiceTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 12/17/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit

class EquipmentServiceTableViewCell: UITableViewCell {
    
    
    var layoutVars:LayoutVars = LayoutVars()
    var equipmentService:EquipmentService!
    var serviceMode:String = "CURRENT"
    
    var statusIcon: UIImageView!
    
    var nameLbl: UILabel!
    
    var dueByLbl: UILabel!
    var dueByValueLbl: UILabel!
    
    var frequencyLbl: UILabel!
    
    var completedByLbl: UILabel!
    var completionDateLbl: UILabel!
    
    let dateFormatter = DateFormatter()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func layoutViews(){
        self.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.selectionStyle = .none
        
        if equipmentService.status == "0" || equipmentService.status == "1" {
            serviceMode = "CURRENT"
        }else{
            serviceMode = "HISTORY"
        }
        
        dateFormatter.dateFormat = "MM/dd/yy"
        
        
        statusIcon = UIImageView()
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        contentView.addSubview(statusIcon)
        
        setStatus(status: equipmentService.status)
        
        nameLbl = UILabel()
        nameLbl.font = layoutVars.smallFont
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        nameLbl.text = equipmentService.name!
        contentView.addSubview(nameLbl)
        
        dueByLbl = UILabel()
        dueByLbl.font = layoutVars.textFieldFont
        dueByLbl.text = "Due:"
        dueByLbl.translatesAutoresizingMaskIntoConstraints = false
        
        
        dueByValueLbl = UILabel()
        dueByValueLbl.font = layoutVars.textFieldFont
        
        frequencyLbl = UILabel()
        frequencyLbl.font = layoutVars.textFieldFont
        frequencyLbl.textAlignment = .right
        frequencyLbl.translatesAutoresizingMaskIntoConstraints = false
        
        
        switch equipmentService.type {
        case "0":
            dueByValueLbl.text = "Now"
            dueByValueLbl.textColor = UIColor.red
            frequencyLbl.text = "One Time Service"
            break
        case "1":
            let date = dateFormatter.date(from: layoutVars.determineUpcomingDate(_equipmentService: equipmentService))
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "MM/dd/yy"
            let date2 = dateFormatter2.string(from: date!)
            
            print("date = \(date2)")
            dueByValueLbl.text = date2
            if date! < Date()  {
                print("date1 is earlier than Now")
                
                dueByValueLbl.textColor = UIColor.red
            }else{
                //dueByValueLbl.text = date2
                dueByValueLbl.textColor = UIColor.black
            }
            
            frequencyLbl.text = "Every \(equipmentService.frequency!) Days"
            
            break
        case "2":
            dueByValueLbl.text = "\(equipmentService.nextValue!)"
            if self.equipmentService.serviceDue {
                dueByValueLbl.textColor = UIColor.red
            }else{
                dueByValueLbl.textColor = UIColor.black
            }
            frequencyLbl.text = "Every \(equipmentService.frequency!) Mi./Km."
            break
        case "3":
            dueByValueLbl.text = "\(equipmentService.nextValue!)"
            if self.equipmentService.serviceDue {
                dueByValueLbl.textColor = UIColor.red
            }else{
                dueByValueLbl.textColor = UIColor.black
            }
            frequencyLbl.text = "Every \(equipmentService.frequency!) Hours"
            break
        default:
            dueByValueLbl.text = "Now"
            dueByValueLbl.textColor = UIColor.red
            frequencyLbl.text = "One Time Service"
        }
        
        
        
        
        dueByValueLbl.translatesAutoresizingMaskIntoConstraints = false
        
        
        completedByLbl = UILabel()
        completedByLbl.font = layoutVars.textFieldFont
        completedByLbl.text = "By: \(equipmentService.completedBy!)"
        completedByLbl.translatesAutoresizingMaskIntoConstraints = false
        
        
        completionDateLbl = UILabel()
        completionDateLbl.font = layoutVars.textFieldFont
        completionDateLbl.text = "On: \(equipmentService.completionDate!)"
        completionDateLbl.translatesAutoresizingMaskIntoConstraints = false
        

        let viewsDictionary = ["statusIcon":statusIcon,"nameLbl":nameLbl,"completedByLbl":completedByLbl,"completionDateLbl":completionDateLbl, "dueByLbl":self.dueByLbl, "dueByValueLbl":self.dueByValueLbl, "frequencyLbl":self.frequencyLbl] as [String : Any]
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusIcon(30)]-[nameLbl]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[statusIcon(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)]", options: [], metrics: nil, views: viewsDictionary))
        
        
        switch (self.serviceMode){
        case "CURRENT":
            
           contentView.addSubview(dueByLbl)
           contentView.addSubview(dueByValueLbl)
           contentView.addSubview(frequencyLbl)
           
           contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusIcon(30)]-[dueByLbl(30)][dueByValueLbl]", options: [], metrics: nil, views: viewsDictionary))
           contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[frequencyLbl(150)]-|", options: [], metrics: nil, views: viewsDictionary))
           contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][dueByLbl(20)]", options: [], metrics: nil, views: viewsDictionary))
           contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][dueByValueLbl(20)]", options: [], metrics: nil, views: viewsDictionary))
           contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][frequencyLbl(20)]", options: [], metrics: nil, views: viewsDictionary))
            break
        case "HISTORY":
            
            contentView.addSubview(completedByLbl)
            contentView.addSubview(completionDateLbl)
            
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusIcon(30)]-[completedByLbl]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[completionDateLbl(80)]-|", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][completedByLbl(20)]", options: [], metrics: nil, views: viewsDictionary))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLbl(30)][completionDateLbl(20)]", options: [], metrics: nil, views: viewsDictionary))
            
            break
        default:
            print("cell type not set")
            
        }
        
    }
    
    
    
    func setStatus(status: String) {
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        case "1":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            break;
        case "2":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            break;
        case "3":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            break;
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            break;
        }
    }
    
    
   /*
    func determineUpcomingDate()->String{
        print("determineUpcomingDate")
        
        
        //var dateString = "2014-07-15" // change to your date format
        
        let dbDateFormatter = DateFormatter()
        dbDateFormatter.dateFormat = "MM/dd/yy"
        
        let dbDate = dbDateFormatter.date(from: equipmentService.creationDate)
        print("equipmentService.nextValue = \(equipmentService.nextValue)")
         print("equipmentService.creationDate = \(equipmentService.creationDate)")
        print("dbDate = \(dbDate)")
        
        
        
        let daysToAdd = Int(equipmentService.nextValue)!
        let futureDate = Calendar.current.date(byAdding:
            .day, // updated this params to add hours
            value: daysToAdd,
            to: dbDate!)
        
        print(dateFormatter.string(from: futureDate!))
        return dateFormatter.string(from: futureDate!)
        
    }
 */
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

