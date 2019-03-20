//
//  MyMemorandumTableViewCell.m
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyMemorandumTableViewCell.h"
#import "MyMemoranduModel.h"

@interface MyMemorandumTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleContent;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end

@implementation MyMemorandumTableViewCell

- (void)setModel:(MyMemoranduModel*)model{
     _titleContent.text = model.title;
    _content.text = model.content;
    _date.text = model.create_time;
}

- (void)setNum:(NSString *)str{
    _titleContent.text = str;
}

- (void)awakeFromNib {
    _titleContent.textColor = [UIColor colorWithRed:0.46 green:0.46 blue:0.47 alpha:1.00];
    _content.textColor = UIColorFromRGB(0xa4a4a4);
    _date.textColor = UIColorFromRGB(0xa4a4a4);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

///**
// *  不重写此方法，cell左边会默认有一个选的圆圈
// */
//- (void)setEditing:(BOOL)editing animated:(BOOL)animated
//{
//    
//}

@end
