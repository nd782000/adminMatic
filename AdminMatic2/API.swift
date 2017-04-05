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
/*
 extension String: ParameterEncoding {
 
 public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
 var request = try urlRequest.asURLRequest()
 request.httpBody = data(using: .utf8, allowLossyConversion: false)
 return request
 }
 
 }
 */

/*
extension Alamofire.SessionManager{
    @discardableResult
    open func requestWithoutCashe(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            print(error)
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}
*/




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
        
        case deleteFieldNote([String: AnyObject])
        
        case itemList([String: AnyObject])
        
        case item([String: AnyObject])
        
        case vendorList([String: AnyObject])
        
        case vendor([String: AnyObject])
        
        case images([String: AnyObject])
        
        case bugs([String: AnyObject])
        
        //case newAlbum([String: AnyObject])
        
        
        var method: HTTPMethod {
            
            switch self {
            case .fields, .employeeList, .logIn, .currentShiftByEmployee, .workOrderList, .bugs:
                return .get
            case .updateUsage, .updateTaskStatus, .updateWoStatus, .images:
                return .post
            default:
                return .get
            }
        }
        
        
        
        
        
        var path: String {
            
            //cache buster
            let now = Date()
            let timeInterval = now.timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            
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
                //print("/functions/update/usage.php")
                return ("/functions/update/usage.php")
            case .updateTaskStatus:
                return ("/functions/update/taskStatus.php")
            case .updateWoStatus:
                return ("/functions/update/workOrderStatus.php")
            case .deleteFieldNote:
                return ("/functions/delete/fieldNote.php")
            case .itemList:
                return ("/functions/get/items.php")
            case .item:
                return ("/functions/get/item.php")
            case .vendorList:
                return ("/functions/get/vendors.php")
            case .vendor:
                return ("/functions/get/vendor.php")
            case .images:
                return ("/functions/get/images.php?cb=\(timeStamp)")
            case .bugs:
                return ("/functions/get/bugs.php?cb=\(timeStamp)")
           // case .newAlbum:
              //  return ("/functions/new/album.php")
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
            case .deleteFieldNote(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .itemList(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .item(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .vendorList(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .vendor(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .images(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            case .bugs(let parameters):
                return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
            //case .newAlbum(let parameters):
               // return try Alamofire.URLEncoding.default.encode(urlRequest, with: parameters)
                
            }
            ////print("urlRequest = \(urlRequest)")
            return urlRequest
        }
    }
}












