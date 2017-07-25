//
//  JJRegisterViewController.swift
//  haoShu
//
//  Created by x on 17/7/24.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class JJRegisterViewController: UIViewController {

   
   
    @IBOutlet weak var toplayout: NSLayoutConstraint!
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var email: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //!< 监听键盘的抬起和落下
        XKeyBoard.registerHide(self)
        XKeyBoard.registerShow(self)
    
        
        
    }

    
    //!< 点击注册按钮
    @IBAction func register(_ sender: Any) {
        
        let user = AVUser()
        
        user.username = self.userName.text
        
        user.password = self.passWord.text
        
        user.email = self.email.text
        
        user.signUpInBackground{ (success, error) in
            
            if success{
                //!< 注册成功
                ProgressHUD.showSuccess("注册成功，请验证邮箱")
                
                self.dismiss(animated: true, completion: nil)
            
            }else
            {
                //!< 注册失败
                 ProgressHUD.showError("注册失败")
                
                 print(error!)
            
            
            }
            
            
            
            
        }
        
        
        
    }
    
    
    @IBAction func goback(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    //!< 响应键盘的抬起和落下
    func keyboardWillHideNotification(_ noti:NSNotification){
    
        UIView .animate(withDuration: 0.25) {
            
            self.toplayout.constant = 8
            
            self.view.layoutIfNeeded()
            
        }
    
    }
    func keyboardWillShowNotification(_ noti:NSNotification){
    
        UIView .animate(withDuration: 0.25) { 
            
            self.toplayout.constant = 200
            
            self.view.layoutIfNeeded()
            
        }
    
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   

}
