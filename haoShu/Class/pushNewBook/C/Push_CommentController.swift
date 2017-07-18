//
//  Push_CommentController.swift
//  haoShu
//
//  Created by x on 17/7/18.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class Push_CommentController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view.
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
    func close(){
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func sure(){
        
    }

}
