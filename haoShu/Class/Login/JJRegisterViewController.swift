//
//  JJRegisterViewController.swift
//  haoShu
//
//  Created by x on 17/7/24.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class JJRegisterViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func register(_ sender: Any) {
    }
    
    
    @IBAction func goback(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
   

}
