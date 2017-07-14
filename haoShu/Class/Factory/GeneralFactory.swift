//
//  GeneralFactory.swift
//  haoShu
//
//  Created by x on 17/7/12.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class GeneralFactory: NSObject {

    /// 创建两个按钮，并且添加到传进来的target的View上，并设置点击事件
    ///
    /// - Parameters:
    ///   - target: 目标
    ///   - title1: 按钮标题一
    ///   - title2: 标题二
    class func addTitleWithTitle(target:UIViewController,title1:String = "关闭",title2:String = "确认"){
    
    
        let btn1  = UIButton.init(frame: CGRect(x: 10,y: 20,width: 40,height: 20))
        
        btn1.setTitle(title1, for: .normal)
        
        btn1.contentHorizontalAlignment = .left
        
        btn1.setTitleColor(MAIN_RED, for: .normal)
        
        btn1.titleLabel?.font = UIFont.init(name: MY_FONT, size: 14)
        
        target.view.addSubview(btn1)
        
        
        let btn2  = UIButton.init(frame: CGRect(x:SCREEN_WIDTH - 50,y: 20,width: 40,height: 20))
        
        btn2.setTitle(title2, for: .normal)
        
        btn2.contentHorizontalAlignment = .right
        
        btn2.setTitleColor(MAIN_RED, for: .normal)
        
        btn2.titleLabel?.font = UIFont.init(name: MY_FONT, size: 14)
        
        target.view.addSubview(btn2)
        
        btn1.addTarget(target, action: #selector(AVSession.close), for: .touchUpInside)
        btn1.addTarget(target, action: Selector(("sure")), for: .touchUpInside)

        
    
    
    }
    
    
    
    
    
    
    
    
}
