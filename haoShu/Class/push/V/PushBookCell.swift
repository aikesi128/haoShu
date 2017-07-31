//
//  PushBookCell.swift
//  haoShu
//
//  Created by x on 17/7/29.
//  Copyright © 2017年 cesiumai. All rights reserved.
//

import UIKit

class PushBookCell: UITableViewCell {

    
    var BookName: UILabel?
    var Editor: UILabel?
    var more:UILabel?
    var cover: UIImageView?
    
    
    
   override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        for view in self.contentView.subviews
        {
    
            view.removeFromSuperview()
    
        }

        //!< 创建子控件
    self.BookName = UILabel.init(frame: CGRect(x: 78,y:8,width:242,height:25))
    self.Editor = UILabel.init(frame: CGRect(x: 78,y:33,width:242,height:25))
    self.more = UILabel.init(frame: CGRect(x: 78,y:66,width:242,height:25))
    
    self.BookName?.font = UIFont.init(name: MY_FONT, size: 15)
    
    self.Editor?.font = UIFont.init(name: MY_FONT, size: 15)
    self.more?.font = UIFont.init(name: MY_FONT, size: 13)
    self.more?.textColor = UIColor.gray
    
    self.contentView.addSubview(self.BookName!)
    self.contentView.addSubview(self.more!)
    self.contentView.addSubview(self.Editor!)
    
    self.cover = UIImageView.init(frame: CGRect(x: 8,y:9,width:56,height:70))
    self.contentView.addSubview(self.cover!)
    
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemetion")
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
