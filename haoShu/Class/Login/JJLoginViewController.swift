//
//  JJLoginViewController.swift
//  haoShu
//
//  Created by x on 17/7/24.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class JJLoginViewController: UIViewController {

    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        //!< 监听键盘起落
        XKeyBoard.registerShow(self)
        XKeyBoard.registerHide(self)
        
    }

 
     //!< 点击注册按钮
    @IBAction func login(_ sender: Any) {
        
        AVUser.logInWithUsername(inBackground: self.userName.text!, password: self.passWord.text!) { (user, error) in
            
            if error == nil
            {
            
                self.dismiss(animated: true, completion: nil)
            
            }else
            {
            
                ProgressHUD.showError("登录失败")
                
                print(error!)
            
            }
            
            
            
            
        }
        
    }
    
    //!< 响应键盘的抬起和落下
    func keyboardWillHideNotification(_ noti:NSNotification){
        
        UIView .animate(withDuration: 0.25) {
            
            self.topLayout.constant = 8
            
            self.view.layoutIfNeeded()
            
        }
        
    }
    func keyboardWillShowNotification(_ noti:NSNotification){
        
        UIView .animate(withDuration: 0.25) {
            
            self.topLayout.constant = -200
            
            self.view.layoutIfNeeded()
            
        }
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
