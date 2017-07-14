
//
//  pushNewBookController.swift
//  haoShu
//
//  Created by x on 17/7/12.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class pushNewBookController: UIViewController,BookTitleViewDelegate,PhotoPickerDelegate{

    var BookTitle: BookTitleView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        GeneralFactory.addTitleWithTitle(target: self, title1: "关闭", title2: "发布")
        
        self.BookTitle = BookTitleView.init(frame: CGRect(x: 0,y: 40,width: SCREEN_WIDTH,height: 160))
        
        self.BookTitle?.delegate = self
        
        self.BookTitle?.tintColor = UIColor.red
        
        self.view.addSubview(self.BookTitle!)
        
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //BookViewDelegate 点击封面回调的代理方法
    func choiceCover() {
        
        let vc = PhotoPickerController()
        
        vc.delegate = self
        
        self.present(vc, animated: true, completion: nil)
      
        
        
        
    }
    
    //!< PhotoPickerDelegate
    func getImageFromPicker(image: UIImage) {
        
        self.BookTitle?.BookCover?.setImage(image, for: .normal)
    }
    
    
    //按钮的点击方法
    func close() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func sure(){
    
    
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
   

}
