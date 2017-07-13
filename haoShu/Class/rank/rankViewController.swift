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
        
        let label = UILabel.init(frame: CGRect(x: 0,y: 0,width: 200,height: 20))
        
        label.center = self.view.center
        
        label.textAlignment = NSTextAlignment.center
        
        label.adjustsFontSizeToFitWidth = true
        
        label.text = "Joyce is 朱俊武"
        
        label.font = UIFont.init(name: MY_FONT, size: 19)
        
        label.textColor = UIColor.green
        
        self.view.addSubview(label)
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
