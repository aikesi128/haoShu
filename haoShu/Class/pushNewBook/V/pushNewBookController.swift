
//
//  pushNewBookController.swift
//  haoShu
//
//  Created by x on 17/7/12.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit



class pushNewBookController: UIViewController,BookTitleViewDelegate,PhotoPickerDelegate,UITableViewDelegate,UITableViewDataSource{

    var BookTitle: BookTitleView?
    
    var tableView: UITableView?
    
    var dataSource: Array<String> = []
    
    var Book_Title = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        GeneralFactory.addTitleWithTitle(target: self, title1: "关闭", title2: "发布")
        
        self.BookTitle = BookTitleView.init(frame: CGRect(x: 0,y: 40,width: SCREEN_WIDTH,height: 160))
        
        self.BookTitle?.delegate = self
        
        self.BookTitle?.tintColor = UIColor.red
        
        self.view.addSubview(self.BookTitle!)
        
        //!< tableview
        self.tableView = UITableView.init(frame: CGRect(x: 0,y: 200,width: SCREEN_WIDTH,height: SCEREEN_HEIGHT - 200), style: .grouped)
        
        self.tableView?.delegate = self
        
        self.tableView?.dataSource = self
        
        self.tableView?.backgroundColor = UIColor.clear
        
        self.tableView?.tableFooterView = UIView()
        
        self.view.addSubview(self.tableView!)
        
        self.dataSource = ["标题","评分","分类","书评"]
        
        
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
        
        //!< 不能直接设置图片，必须要经过裁剪
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
    
    //!< tableview 代理方法
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil{
        
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
            
        
        }
        
        if indexPath.row != 1
        {
        
            cell?.accessoryType = .disclosureIndicator
        
        }
        
        cell?.textLabel?.text = self.dataSource[indexPath.row]
        
        cell?.textLabel?.font = UIFont.init(name: MY_FONT, size: 15)
        
        cell?.detailTextLabel?.font = UIFont.init(name: MY_FONT, size: 13)
        
        if indexPath.row == 0 {
            
            cell?.detailTextLabel?.text = self.Book_Title
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            
            self.didSelectTitle()
           
            break
            
        case 1:
            
            self.didSelectSocer()
            
            break
            
        case 2:
            
            self.didSelectType()
           
            break
            
         case 3:
            
            self.didSelectComment()
            
            break
            
        default: break
            
        }
        
        
    }
    
    
    //!< 选择标题
    
    func didSelectTitle(){
    
        let vc = Push_TitleController()
        
        GeneralFactory.addTitleWithTitle(target: vc)
        
        vc.callBack = ({(title:String) -> Void in
            
            self.Book_Title = title
            
            self.tableView?.reloadData()
            
        
        
        })
        
        self.present(vc, animated: true, completion: nil)
        
        
    
    }
    
    //!< 选择评分
    
    func didSelectSocer(){
        
        let vc = Push_SocerController()
        
        GeneralFactory.addTitleWithTitle(target: vc)
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    //!< 选择分类
    func didSelectType(){
        
        let vc = Push_TypeController()
        
        GeneralFactory.addTitleWithTitle(target: vc)
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    //!< 选择书评
    func didSelectComment(){
        
        let vc = Push_CommentController()
        
        GeneralFactory.addTitleWithTitle(target: vc)
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
   

}
