//
//  Push_TitleController.swift
//  
//
//  Created by x on 17/7/18.
//
//

import UIKit

typealias Push_CallBack = (_ title:String) -> Void

class Push_TitleController: UIViewController {

    
    var textField: UITextField?
    
    var callBack: Push_CallBack?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white

        self.textField = UITextField.init(frame: CGRect(x: 15,y: 60,width:SCREEN_WIDTH - 30,height: 30))
        
        self.textField?.borderStyle = .roundedRect
        
        self.textField?.placeholder = "书评标题"
        
        self.textField?.font = UIFont.init(name: MY_FONT, size: 15)
        
        self.view.addSubview(self.textField!)
        
        self.textField?.becomeFirstResponder()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func close(){
    
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    func sure(){
    
        self.callBack?((self.textField?.text!)!)
        
        self.dismiss(animated: true, completion: nil)
    }

}
