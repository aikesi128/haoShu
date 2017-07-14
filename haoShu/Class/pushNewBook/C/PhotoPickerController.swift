//
//  PhotoPickerController.swift
//  haoShu
//
//  Created by x on 17/7/14.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

/// 点击图书封面，present这个控制器，用来选择和裁剪图书封面


import UIKit

protocol PhotoPickerDelegate{
    
    func getImageFromPicker(image:UIImage)
    
    
}

class PhotoPickerController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

     var delegate: PhotoPickerDelegate?
    
    var alert: UIAlertController?
    
    var picker:UIImagePickerController?
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor.clear
        
//        self.view.alpha = 0.2
        
        self.modalPresentationStyle = .overFullScreen
        
        self.picker = UIImagePickerController()
        
        self.picker?.delegate = self
        
        self.picker?.allowsEditing = false
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not implemeted")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.alert == nil{
        
            self.alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
            
            self.alert?.addAction(UIAlertAction.init(title: "从相册选择", style: .default, handler: { (action) in
                
                self.localPhoto()
            }))
        
            self.alert?.addAction(UIAlertAction.init(title: "打开相机", style: .default, handler: { (action) in
                
                self.takePhoto()
            }))
            
            self.alert?.addAction(UIAlertAction.init(title: "取消", style: .default, handler: { (action) in
                
                self.backToBookCover()
                
            }))
        
            
            self.present(self.alert!, animated: true, completion: nil)
            
        }
        
        
        
    }
    

    func takePhoto()
    {
    
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            //支持相机
            self.picker?.sourceType = .camera
            
            self.present(self.picker!, animated: true, completion: nil)
            
            
            
        }else
        {
            
            //不支持相机
            let alert = UIAlertController.init(title: "不支持相机", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction.init(title: "确定", style: .default, handler: {(action) in
                
                self.backToBookCover()
                
            }))
            
            self.present(alert, animated: true, completion:nil)
        
        }
  
    
    }
    
    
    func localPhoto()
    {
    
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        {
           
            //!< 可以打来相册
            self.picker?.sourceType = .photoLibrary
            
            self.present(self.picker!, animated: true, completion: nil)
            
        }else
        {
        
            //!< 不能打开相册
            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction.init(title: "不支持打开相册", style: .default, handler: nil))
        
        }
    
    
    
    }
    
    
    func backToBookCover()
    {
        
        self.alert?.dismiss(animated: true, completion:nil)
        
        self.dismiss(animated: true, completion: nil)
    
    
    }
    
    //!< imagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        let image = info[UIImagePickerControllerOriginalImage]
        
        self.delegate?.getImageFromPicker(image: image as! UIImage)
        
        picker.dismiss(animated: true, completion: nil)
        
        self.dismiss(animated: false, completion: nil)
        
        
    }
    
}





















































