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

       
        if AVUser.current() == nil
        {
            
            let story = UIStoryboard.init(name: "Login", bundle: nil)
            
            let vc = story.instantiateViewController(withIdentifier: "login")
            
            vc.modalTransitionStyle = .crossDissolve
            
            self.present(vc, animated: true, completion: nil)
            
            
        }

        
    }

    
    
    


}
