//
//  pushBook.swift
//  haoShu
//
//  Created by x on 17/7/26.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class pushBook: NSObject {
    
    static func pushBookInBack(dict:NSDictionary){
        
       let object  = AVObject.init(className: "Joyce")
        
        object.setObject(dict["BookName"], forKey: "BookName")
         object.setObject(dict["BookEditor"], forKey: "BookEditor")
         object.setObject(dict["title"], forKey: "title")
         object.setObject(dict["score"], forKey: "score")
         object.setObject(dict["type"], forKey: "type")
         object.setObject(dict["detailType"], forKey: "detialType")
         object.setObject(dict["description"], forKey: "description")
         object.setObject(AVUser.current(), forKey: "user")
        
        let image = dict["BookCover"] as! UIImage
        
        let coverFile = AVFile.init(data: UIImagePNGRepresentation(image)!)
        
        coverFile.saveInBackground { (success, error) in
            
            if success{
            
                object.saveInBackground({ (success, error) in
                    
                    if success{
                        
                    
                    
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushBookNotification"), object: nil, userInfo: ["success":"true"])
                    
                    }else
                    {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushBookNotification"), object: nil, userInfo: ["success":"false"])
                    
                    }
                    
                    
                })
            
            
            
            }else
            {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushBookNotification"), object: nil, userInfo: ["success":"false"])
            
            
            }
            
            
            
            
            
        }
        
        
    }
}
