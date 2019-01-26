//
//  API.swift
//  AdminMatic2
//
//  Created by Nick on 1/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//

 

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

public protocol ResponseCollectionSerializable {
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Self]
}

struct API {
    
    enum Method {
        case get
        case put
        case post
        case patch
        case delete
        
        func toAFMethod() -> Alamofire.HTTPMethod {
            switch self {
            case .get:
                return Alamofire.HTTPMethod.get
            case .put:
                return Alamofire.HTTPMethod.put
            case .post:
                return Alamofire.HTTPMethod.post
            case .patch:
                return Alamofire.HTTPMethod.patch
            case .delete:
                return Alamofire.HTTPMethod.delete
            }
        }
    }
    
    
    
    enum Router: URLRequestConvertible {
        
        static let baseURLString = "https://atlanticlawnandgarden.com/cp/app"
        
        case fields([String: AnyObject])
        
        case employeeList([String: AnyObject])
        
        case employee([String: AnyObject])
        
        case workShiftStart([String: AnyObject])
        
        case workShiftStop([String: AnyObject])
        
        case logIn( [String: AnyObject])
        
        case currentShiftByEmployee([String: AnyObject])
        
        
        case workOrderList([String: AnyObject])
        
        case workOrder([String: AnyObject])
        
        case usage([String: AnyObject])
        
        case customerList([String: AnyObject])
        
        case customer([String: AnyObject])
        
        case changeField([String: AnyObject])
        
        case updateUsage([String: AnyObject])
        
        case updateTaskStatus([String: AnyObject])
        
        case updateWoStatus([String: AnyObject])
        
        case deleteAttachment([String: AnyObject])
        
        case itemList([String: AnyObject])
        
        
        case vendorList([String: AnyObject])
        
        case vendor([String: AnyObject])
        
        case bugs([String: AnyObject])
        
        case newLike([String: AnyObject])
        
        case deleteLike([String: AnyObject])
        
        
        var method: HTTPMethod {
            
            switch self {
            case .fields, .employeeList, .logIn, .currentShiftByEmployee, .workOrderList, .bugs:
                return .get
            case .updateUsage, .updateTaskStatus, .updateWoStatus, .newLike, .deleteLike:
                return .post
            default:
                return .get
            }
        }
        
        
        var path: String {
            
            
            switch self {
            case .fields:
                //print("field /functions/get/fields.php")
                return  "/functions/get/fields.php"
            case .employeeList:
                return ("/functions/get/employees.php")
            case .employee:
                return ("/functions/get/employeeInfo.php")
            case .workShiftStart:
                return ("/functions/update/workShiftStart.php")
            case .workShiftStop:
                return ("/functions/update/workShiftStop.php")
            case .logIn:
                print("api trying to log in")
                return "/functions/other/logIn.php"
            case .currentShiftByEmployee:
                return "/functions/get/currentShiftByEmployee.php"
            case .workOrderList:
                return ("/functions/get/workOrders.php")
            case .workOrder:
                return ("/functions/get/workOrder.php")
            case .usage:
                return ("/functions/get/woItemUsage.php")
            case .customerList:
                return ("/functions/get/customers.php")
            case .customer:
                return ("/functions/get/customer.php")
            case .changeField:
                return ("/functions/update/changeField.php")
            case .updateUsage:
                return ("/functions/update/usage.php")
            case .updateTaskStatus:
                return ("/functions/update/taskStatus.php")
            case .updateWoStatus:
                return ("/functions/update/workOrderStatus.php")
            case .deleteAttachment:
                return ("/functions/delete/fieldNote.php")
            case .itemList:
                return ("/functions/get/items.php")
            
            case .vendorList:
                return ("/functions/get/vendors.php")
            case .vendor:
                return ("/functions/get/vendor.php")
            case .bugs:
                return ("/functions/get/bugs.php")
                
            case .newLike:
                return ("/functions/new/like.php")
            case .deleteLike:
                return ("/functions/delete/like.php")
                
            }
        }
        
        
        func asURLRequest() throws -> URLRequest {
            
            let url = Foundation.URL(string: Router.baseURLString)!
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content")
            urlRequest.setValue("keep-alive", forHTTPHeaderField: "Connection")
            
            
            
            switch self {
            case .fields(let parameters):
                //print("fields")
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            case .employeeList(let parameters):
                //print("employeeList")
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            case .employee(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .workShiftStart(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .workShiftStop(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
                
            case .logIn(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .currentShiftByEmployee(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .workOrderList(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .workOrder(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .usage(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .customerList(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .customer(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .changeField(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .updateUsage(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .updateTaskStatus(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .updateWoStatus(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .deleteAttachment(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .itemList(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .vendorList(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .vendor(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .bugs(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            
            case .newLike(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .deleteLike(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            }
            ////print("urlRequest = \(urlRequest)")
            return urlRequest
        }
    }
}








 



