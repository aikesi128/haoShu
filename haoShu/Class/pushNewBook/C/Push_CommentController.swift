//
//  Push_CommentController.swift
//  haoShu
//
//  Created by x on 17/7/18.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

typealias Push_CommentControllerBlock = (_ comment: String) -> Void

class Push_CommentController: UIViewController {

    var callBack: Push_CommentControllerBlock?
    
    var textView: JVFloatLabeledTextView?
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        self.textView = JVFloatLabeledTextView.init(frame: CGRect(x:8,y:58,width:SCREEN_WIDTH - 16,height:SCEREEN_HEIGHT - 64))
        
        self.view.addSubview(textView!)
        
        textView?.placeholder = "    可以在这里撰写你的详细评论哦"
        
        textView?.font = UIFont.init(name: MY_FONT, size: 17)
        
        textView?.becomeFirstResponder()
        
        textView?.tintColor = UIColor.gray
        
        XKeyBoard.registerHide(self)
        
        XKeyBoard.registerShow(self)
        
    }
 
  
    func close()
    {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func sure()
    {
        
        self.callBack!((textView?.text)!)
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    
    
    /**
     *  键盘遮挡
     */
    func keyboardWillHideNotification(_ notification:Notification){
        self.textView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    func keyboardWillShowNotification(_ notification:Notification){
        let rect = XKeyBoard.returnWindow(notification)
        self.textView?.contentInset = UIEdgeInsetsMake(0, 0, rect.size.height, 0)
        
    }


}
