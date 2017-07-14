//
//  rankViewController.swift
//  haoShu
//
//  Created by x on 17/7/12.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class rankViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let label = UILabel.init(frame: CGRect(x: 0,y: 0,width: 200,height: 80))
        
        label.center = self.view.center
        
        label.textAlignment = .center
        
        label.adjustsFontSizeToFitWidth = true
        
        label.text = "Joyce is 朱俊武"
        
        label.font = UIFont.init(name: MY_FONT, size: 19)
        
        label.textColor = UIColor.green
        
        self.view.addSubview(label)

        
    }

    
    
    


}
