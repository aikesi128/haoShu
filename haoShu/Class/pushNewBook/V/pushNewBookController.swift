
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
    
    var scoreStart:LDXScore?
    
    var showStart = false
    
    var type = "文学"
    
    var detailType = "文学"
    
    var comment = ""
    
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
        
        scoreStart = LDXScore.init(frame: CGRect(x:100,y:10 ,width:100 ,height: 22))
        
        scoreStart?.max_star = 5
        
        scoreStart?.show_star = 5
        
        scoreStart?.isSelect = true
        
        scoreStart?.normalImg = UIImage.init(named: "btn_star_evaluation_normal")
        
        scoreStart?.highlightImg = UIImage.init(named: "btn_star_evaluation_press")
        
        NotificationCenter.default.addObserver(self, selector: Selector(("pushNotification:")), name: NSNotification.Name(rawValue: "pushBookNotification"), object: nil)
        
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
        
        let dict = [
            
            "BookName":(self.BookTitle?.BookName?.text)!,
            "BookEditor":(self.BookTitle?.BookEditor?.text)!,
            "BookCover":(self.BookTitle?.BookCover?.currentImage)!,
            "title":self.Book_Title,
            "score":String((self.scoreStart?.show_star)!),
            "type":self.type,
            "detaileType":self.detailType,
            "description":self.comment
        ] as [String : Any]
        
        pushBook.pushBookInBack(dict: dict as NSDictionary)
        
        
    
    
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
        
        if self.showStart && indexPath.row == 2 {
            
            cell?.contentView.addSubview(self.scoreStart!)
            
            cell?.accessoryType = .none
            
        }
        
        var row = indexPath.row
        if self.showStart && row>1
        {
            row = row - 1
            
        }
        
        if row == 2 {
            
            cell?.detailTextLabel?.text = type + "->" + detailType
            
        }
        
        if row == 4
        {
            
            cell?.accessoryType = .none
            
            let commentView = UITextView.init(frame: CGRect(x:4,y:4,width:SCREEN_WIDTH - 8,height:80))
//            commentView.backgroundColor = UIColor.red
            commentView.text = comment
            commentView.font = UIFont.init(name: MY_FONT, size: 14)
            commentView.isEditable = false
            cell?.contentView.addSubview(commentView)
            
            
            
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var row = indexPath.row
        
        
        if self.showStart && row > 1{
            
            row = row - 1
        }
        
        switch row {
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if showStart && indexPath.row > 5
        {
            
            return 88
            
        }else if !self.showStart && indexPath.row > 4
        {
            return 88
        
        }else
        {
            return 44
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
        
        self.tableView?.beginUpdates()
        
        let indexPaths = [NSIndexPath.init(row: 2, section: 0)]
        
        if self.showStart {
        
            //!< 取消星星
            self.dataSource.remove(at: 2)
            
            self.tableView?.deleteRows(at: indexPaths as [IndexPath], with: .right)
            
            self.showStart = false
            
            
        }else
        {
            //!< 展示星星
            self.dataSource.insert("", at: 2)
            
            self.tableView?.insertRows(at: indexPaths as [IndexPath], with: .left)
            
            self.showStart = true
        
        
        
        }

        self.tableView?.endUpdates()
        
    }
    
    //!< 选择分类
    func didSelectType(){
        
        let vc = Push_TypeController()
        
        GeneralFactory.addTitleWithTitle(target: vc)
        
        //!< 取出俩个按钮，修改按钮字体颜色
        let btn1 = vc.view.viewWithTag(1234) as? UIButton
        
        let btn2 = vc.view.viewWithTag(1235) as? UIButton
        
        btn1?.setTitleColor(RGB(r: 38, g: 82, b: 67), for: .normal)
        btn2?.setTitleColor(RGB(r: 38, g: 82, b: 67), for: .normal)
        
        vc.modalTransitionStyle = .crossDissolve
        vc.type = type
        vc.detaileType = detailType
        
        //!< callback 回传值过来
        vc.callBack = ({(type,detailType) -> Void in
        
            
            self.type = type
            
            self.detailType = detailType
            
            self.tableView?.reloadData()
            
        
        
        })
        
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    //!< 选择书评
    func didSelectComment(){
        
        let vc = Push_CommentController()
        
        GeneralFactory.addTitleWithTitle(target: vc)
        
        vc.textView?.text = self.comment
        
        vc.callBack = ({(comment) -> Void in
        
            self.comment = comment
            
            if self.dataSource.last == "" {
                self.dataSource.removeLast()
            }
            if comment != "" {
                self.dataSource.append("")
            }
            self.tableView?.reloadData()
        
        
        })
        
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
     deinit{
    
        print("push controller deinit")
    
    }
   
    
    
    
    func pushNotification(_ noti: NSNotification){
    
        let dic = noti.userInfo
        
        if ((dic?["success"]! as! String) == "true")
        {
            
            ProgressHUD.showSuccess("上传成功")
            
            self.dismiss(animated: true, completion: nil)
            
        }else
        {
            ProgressHUD.showError("上传失败")
        
        }
    
    
    }

}
