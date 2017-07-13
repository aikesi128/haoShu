//
//  pushViewController.swift
//  haoShu
//
//  Created by x on 17/7/12.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class pushViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        self.setNavigationBar()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavigationBar() {
        
        
        let navigationView = UIView.init(frame: CGRect(x: 0,y: -20,width:SCREEN_WIDTH,height: 65))
        
//        navigationView.backgroundColor = UIColor.green
        
        navigationView.backgroundColor = UIColor.white
        
        self.navigationController?.navigationBar.addSubview(navigationView)
        
        let addBookBtn = UIButton.init(frame: CGRect(x: 20,y: 20,width: SCREEN_WIDTH,height: 45))
        
//        addBookBtn.backgroundColor = UIColor.red
        
        addBookBtn.setImage(UIImage.init(named: "plus circle"), for: .normal)
        
        addBookBtn.setTitleColor(UIColor.black, for: .normal)
        
        addBookBtn.setTitle("    新建书评", for: .normal)
        
        addBookBtn.titleLabel?.font = UIFont.init(name: MY_FONT, size: 15)
        
        addBookBtn.contentHorizontalAlignment = .left
        
        addBookBtn.addTarget(self, action: #selector(pushViewController.pushNewBook), for: .touchUpInside)
        
         
        navigationView.addSubview(addBookBtn)
       
        
        
    }

    func pushNewBook() {
        
        let vc = pushNewBookController()
        
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
}
