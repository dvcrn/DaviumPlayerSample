//
//  AloeUtil.swift
//  Pods
//
//  Created by kawase yu on 2015/09/16.
//
//

import UIKit
import Alamofire  

open class Aloe: NSObject {
    
    open class func isNull(_ val:AnyObject?)->Bool{
        return val == nil || val is NSNull
    }
    
    open class func isNotNull(_ val:AnyObject?)->Bool{
        return !isNull(val)
    }
    
    open class func probabilityOf(_ r:Int)->Bool{
        return randOf(r) == 0
    }
    
    // 0 ..< r
    open class func randOf(_ r:Int)->Int{
        return Int(arc4random_uniform(UInt32(r)))
    }
    
    open class func openBrowser(_ url:String){
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
   
}
