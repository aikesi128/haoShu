//
//  Push_TypeController.swift
//  haoShu
//
//  Created by x on 17/7/18.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class Push_TypeController: UIViewController,IGLDropDownMenuDelegate {

    var segmentController1: AKSegmentedControl?
    var segmentController2: AKSegmentedControl?

    var type = "文学"
    
    var detaileType = "文学"
    
    var literatureArray1:Array<NSDictionary> = []
    var literatureArray2:Array<NSDictionary> = []
    
    var humanitiesArray1:Array<NSDictionary> = []
    var humanitiesArray2:Array<NSDictionary> = []
    
    var livelihoodArray1:Array<NSDictionary> = []
    var livelihoodArray2:Array<NSDictionary> = []
    
    var economiesArray1:Array<NSDictionary> = []
    var economiesArray2:Array<NSDictionary> = []
    
    var technologyArray1:Array<NSDictionary> = []
    var technologyArray2:Array<NSDictionary> = []
    
    var NetworkArray1:Array<NSDictionary> = []
    var NetworkArray2:Array<NSDictionary> = []

    var dropDownMenu1:IGLDropDownMenu?
    var dropDownMenu2:IGLDropDownMenu?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = RGB(r: 231, g: 231, b: 231)
        
        //!< 添加标题
        let titleLabel = UILabel.init(frame: CGRect(x:(SCREEN_WIDTH - 300)/2,y:20,width:300,height:20))
        
        titleLabel.font = UIFont.init(name: MY_FONT, size: 17)
        
        titleLabel.text = "请选择分类"

        titleLabel.shadowOffset = CGSize(width:0,height:1)
        
        titleLabel.shadowColor = RGB(r: 82, g: 113, b: 131)
        
        titleLabel.textAlignment = .center
        
        self.view.addSubview(titleLabel)
    
        
        //!< 创建segmentcontroller
        self.initSegment()
        
        //!< 创建menu数组
        self.initDroparray()
        
    }

    
    //!< 初始化dropDownMenu
    
    func creatDropMenu(array1:Array<NSDictionary>,array2:Array<NSDictionary>){
    
    
        let dropDownItem1 = NSMutableArray()
        
        for dic in array1 {
            
            let item = IGLDropDownItem()
            
            item.text = dic["title"] as! String
            
            dropDownItem1.add(item)
            
         }
        
        
        let dropDownItem2 = NSMutableArray()
        
        for dic in array2 {
            
            let item = IGLDropDownItem()
            
            item.text = dic["title"] as! String
            
            dropDownItem2.add(item)
            
        }
        
        dropDownMenu1?.removeFromSuperview()
        
        dropDownMenu1 = IGLDropDownMenu()
        
        dropDownMenu1?.menuText = "点我，展开详细列表"
        
        dropDownMenu1?.menuButton.textLabel.adjustsFontSizeToFitWidth = true
        
        dropDownMenu1?.menuButton.textLabel.textColor = RGB(r: 38, g: 82, b: 67)
        
        dropDownMenu1?.paddingLeft = 15
        
        dropDownMenu1?.delegate = self
        
        dropDownMenu1?.type = .stack
        
        dropDownMenu1?.itemAnimationDelay = 0.1
        
        dropDownMenu1?.gutterY = 5
        
        dropDownMenu1?.dropDownItems = dropDownItem1 as [AnyObject]
        
        dropDownMenu1?.frame = CGRect(x:20,y:150,width:(SCREEN_WIDTH/2 - 30),height:(SCEREEN_HEIGHT - 200)/7)
        
        self.view.addSubview(dropDownMenu1!)
        
        dropDownMenu1?.reloadView()
        
        
        
        dropDownMenu2?.removeFromSuperview()
        
        dropDownMenu2 = IGLDropDownMenu()
        
        dropDownMenu2?.menuText = "点我，展开详细列表"
        
        dropDownMenu2?.menuButton.textLabel.adjustsFontSizeToFitWidth = true
        
        dropDownMenu2?.menuButton.textLabel.textColor = RGB(r: 38, g: 82, b: 67)
        
        dropDownMenu2?.paddingLeft = 15
        
        dropDownMenu2?.delegate = self
        
        dropDownMenu2?.type = .stack
        
        dropDownMenu2?.itemAnimationDelay = 0.1
        
        dropDownMenu2?.gutterY = 5
        
        dropDownMenu2?.dropDownItems = dropDownItem2 as [AnyObject]
        
        dropDownMenu2?.frame = CGRect(x:20 + SCREEN_WIDTH/2,y:150,width:(SCREEN_WIDTH/2 - 30),height:(SCEREEN_HEIGHT - 200)/7)
        
        self.view.addSubview(dropDownMenu2!)
        
        dropDownMenu2?.reloadView()
        
    
    }
    
    
    
    //!< 创建menu数组
    func initDroparray(){
    
    
        self.literatureArray1 = [
            ["title":"小说"],
            ["title":"漫画"],
            ["title":"青春文学"],
            ["title":"随笔"],
            ["title":"现当代诗"],
            ["title":"戏剧"],
        ];
        self.literatureArray2 = [
            ["title":"传记"],
            ["title":"古诗词"],
            ["title":"外国诗歌"],
            ["title":"艺术"],
            ["title":"摄影"],
        ];
        self.humanitiesArray1 = [
            ["title":"历史"],
            ["title":"文化"],
            ["title":"古籍"],
            ["title":"心理学"],
            ["title":"哲学/宗教"],
            ["title":"政治/军事"],
        ];
        self.humanitiesArray2 = [
            ["title":"社会科学"],
            ["title":"法律"],
        ];
        self.livelihoodArray1 = [
            ["title":"休闲/爱好"],
            ["title":"孕产/胎教"],
            ["title":"烹饪/美食"],
            ["title":"时尚/美妆"],
            ["title":"旅游/地图"],
            ["title":"家庭/家居"],
        ];
        self.livelihoodArray2 = [
            ["title":"亲子/家教"],
            ["title":"两性关系"],
            ["title":"育儿/早教"],
            ["title":"保健/养生"],
            ["title":"体育/运动"],
            ["title":"手工/DIY"],
        ];
        self.economiesArray1  = [
            ["title":"管理"],
            ["title":"投资"],
            ["title":"理财"],
            ["title":"经济"],
        ];
        self.economiesArray2  = [
            ["title":"没有更多了"],
        ];
        self.technologyArray1 =  [
            ["title":"科普读物"],
            ["title":"建筑"],
            ["title":"医学"],
            ["title":"计算机/网络"],
        ];
        self.technologyArray2 = [
            ["title":"农业/林业"],
            ["title":"自然科学"],
            ["title":"工业技术"],
        ];
        self.NetworkArray1 =    [
            ["title":"玄幻/奇幻"],
            ["title":"武侠/仙侠"],
            ["title":"都市/职业"],
            ["title":"历史/军事"],
        ];
        self.NetworkArray2 =    [
            ["title":"游戏/竞技"],
            ["title":"科幻/灵异"],
            ["title":"言情"],
        ];

    
    }
    
    
    
    //!< 创建segmentcontroller
    func initSegment(){
    
        let bunArr1 = [
        
            ["image":"ledger","title":"文学","font":MY_FONT],
            ["image":"drama masks","title":"人文社科","font":MY_FONT],
            ["image":"aperture","title":"生活","font":MY_FONT]
        
        ]
        
        self.segmentController1 = AKSegmentedControl.init(frame: CGRect(x:10,y:60,width:SCREEN_WIDTH - 20,height:37))
        
        self.segmentController1?.initButton(withTitleandImage: bunArr1)
        
        self.view.addSubview(segmentController1!)
        
        let bunArr2 = [
            
            ["image":"atom","title":"经管","font":MY_FONT],
            ["image":"alien","title":"科技","font":MY_FONT],
            ["image":"fire element","title":"网络流行","font":MY_FONT]
            
        ]
        
        self.segmentController2 = AKSegmentedControl.init(frame: CGRect(x:10,y:110,width:SCREEN_WIDTH - 20,height:37))
        
        self.segmentController2?.initButton(withTitleandImage: bunArr2)
        
        self.view.addSubview(segmentController2!)
    
        self.segmentController1?.addTarget(self, action: #selector(self.segmentControllerAction(segment:)), for: .valueChanged)
        
        self.segmentController2?.addTarget(self, action: #selector(self.segmentControllerAction(segment:)), for: .valueChanged)
        
    }
   

    //!< 响应segmengt点击事件
    func segmentControllerAction(segment:AKSegmentedControl){
    
        var index = segment.selectedIndexes.first
        
        self.type = (segment.buttonsArray[index!] as! UIButton).currentTitle!
        
        if segment == segmentController1
        {
            //!< 点击第一个seg 将第二个segment滞空
            segmentController2?.setSelectedIndex(3)
            
            
        }else
        {
        
            //!< 点击第2个seg 将第1个segment滞空
            segmentController1?.setSelectedIndex(3)
        
            index! += 3
            
        
        }
        
        if self.dropDownMenu1 != nil {
            
            self.dropDownMenu1?.resetParams()
        }
        
        if self.dropDownMenu2 != nil {
            
            self.dropDownMenu2?.resetParams()
        }
        
        switch (index!) {
        case 0:
            
            self.creatDropMenu(array1: literatureArray1, array2: literatureArray2)
            
            break
            
        case 1:
            
            self.creatDropMenu(array1: humanitiesArray1, array2: humanitiesArray2)
            
            break
            
        case 2:
            
            self.creatDropMenu(array1: livelihoodArray1, array2: livelihoodArray2)
            
            break
            
        case 3:
            
            self.creatDropMenu(array1: economiesArray1, array2: economiesArray2)
            
            break
            
        case 4:
            
            self.creatDropMenu(array1: technologyArray1, array2: technologyArray2)
            
            break
            
        case 5:
        
            self.creatDropMenu(array1: NetworkArray1, array2: NetworkArray2)
            
            break
            
            
        default:
            
            
            
            break
        }
        
        
    
    
    }
    
    //!< dropDownDelegate
    func dropDownMenu(_ dropDownMenu: IGLDropDownMenu!, selectedItemAt index: Int) {
        
        if dropDownMenu == dropDownMenu1 {
            
            let item = dropDownMenu1?.dropDownItems[index] as? IGLDropDownItem
            
            self.detaileType = (item?.text)!
            
            self.dropDownMenu2?.menuButton.text = self.detaileType
            
            self.dropDownMenu2?.foldView()
            
        }else
        {
            let item = dropDownMenu2?.dropDownItems[index] as? IGLDropDownItem
            
            self.detaileType = (item?.text)!
            
            self.dropDownMenu1?.menuButton.text = self.detaileType
            
            self.dropDownMenu1?.foldView()
        }
        
        
        
        
    }
    
    //!< 顶部按钮的返回值
    func close(){
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func sure(){
        
    }

}
