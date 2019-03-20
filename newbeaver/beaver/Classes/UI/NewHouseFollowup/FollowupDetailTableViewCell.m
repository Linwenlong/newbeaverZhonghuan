//
//  FollowupDetailTableViewCell.m
//  beaver
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FollowupDetailTableViewCell.h"
#import "SDAutoLayout.h"
#import "FollowupDetailModel.h"

@interface FollowupDetailTableViewCell ()

@property (nonatomic, strong)UILabel *status;//状态
@property (nonatomic, strong)UILabel *memo;//详情
@property (nonatomic, strong)UILabel *time;//创建时间

@end

@implementation FollowupDetailTableViewCell


- (void)setModel:(FollowupDetailModel *)model{
    _status.text = model.status;
    _memo.text = model.memo;
    _time.text = model.update_time;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addUI];
    }
    return self;
}

- (void)addUI{
    _status = [UILabel new];
    _status.backgroundColor=  [UIColor orangeColor];
    _status.textColor = [UIColor whiteColor];
    _status.clipsToBounds = YES;
    _status.textAlignment = NSTextAlignmentCenter;
    _status.layer.cornerRadius = 5.0f;
    _status.font = [UIFont systemFontOfSize:18.0f];

    
    _memo = [UILabel new];
    _memo.font = [UIFont systemFontOfSize:17.0f];
    _memo.textAlignment = NSTextAlignmentCenter;
    _memo.textColor  = UIColorFromRGB(0x747476);
    
    _time = [UILabel new];
    _time.font = [UIFont systemFontOfSize:17.0f];
    _time.textAlignment = NSTextAlignmentRight;
    _time.textColor  = UIColorFromRGB(0x747476);
    
    [self sd_addSubviews:@[_status,_memo,_time]];
    
    CGFloat top = 15;
    CGFloat x = 20;
    CGFloat margin =10;
    
    _status.sd_layout
    .topSpaceToView(self,top)
    .leftSpaceToView(self,x)
    .heightIs(30)
    .widthIs(120);
    
    _memo.sd_layout
    .topSpaceToView(_status,margin)
    .leftSpaceToView(self,x)
    .heightIs(30);
    [_memo setSingleLineAutoResizeWithMaxWidth:(kScreenW-2*x)/2];
    
    _memo.sd_layout
    .topSpaceToView(_status,margin)
    .leftSpaceToView(self,x)
    .heightIs(30);
    [_memo setSingleLineAutoResizeWithMaxWidth:kScreenW-2*x];
    
    _time.sd_layout
    .topSpaceToView(self,top)
    .rightSpaceToView(self,x)
    .heightIs(30);
    [_time setSingleLineAutoResizeWithMaxWidth:(kScreenW-2*x)/2];
    
}



@end
