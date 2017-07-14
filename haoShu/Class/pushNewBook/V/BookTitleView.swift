//
//  BookTitleView.swift
//  haoShu
//
//  Created by x on 17/7/13.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit


@objc protocol BookTitleViewDelegate{

    @objc optional func choiceCover()


}

class BookTitleView: UIView {
    
    var BookCover: UIButton?
    
    var BookName: JVFloatLabeledTextField?
    
    var BookEditor: JVFloatLabeledTextField?
    
    weak var delegate:BookTitleViewDelegate?
    
    override init(frame:CGRect){
    
        super.init(frame: frame)
        
        //封面
        self.BookCover = UIButton.init(frame: CGRect(x: 10,y: 8,width: 110,height: 141))
        
        self.BookCover?.setImage(UIImage.init(named: "Cover"), for: .normal)
        
        self.BookCover?.addTarget(self, action: #selector(BookTitleViewDelegate.choiceCover), for: .touchUpInside)
        
        self.addSubview(self.BookCover!)
        
        //书名
        self.BookName = JVFloatLabeledTextField.init(frame: CGRect(x: 128,y: 48,width: SCREEN_WIDTH - 128 - 15,height: 30))
        
        self.BookName?.placeholder = "书名"
        
        self.BookName?.font = UIFont.init(name: MY_FONT, size: 14)
        
        self.BookName?.floatingLabelFont = UIFont.init(name: MY_FONT, size: 14)
        
        self.addSubview(self.BookName!)
        
        
        //作者
        self.BookEditor = JVFloatLabeledTextField.init(frame: CGRect(x: 128,y: 79 + 39,width: SCREEN_WIDTH - 128 - 15,height: 30))
        
        self.BookEditor?.placeholder = "作者"
        
        self.BookEditor?.font = UIFont.init(name: MY_FONT, size: 14)
        
        self.BookEditor?.floatingLabelFont = UIFont.init(name: MY_FONT, size: 14)
        
        self.addSubview(self.BookEditor!)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func choiceCover(){
        
        
        self.delegate?.choiceCover!()
        
        
    }

    
}
