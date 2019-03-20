//
//  FeeTableViewHeaderView.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FeeTableViewHeaderView.h"

@interface FeeTableViewHeaderView ()

@property (nonatomic, strong)UIView *backHeader;//阴影背景

@property (nonatomic, strong)UILabel *jieyongDate;//结佣日期

@property (nonatomic, strong)UIView * line1;//线条1

@property (nonatomic, strong)UILabel *customer;//客户
@property (nonatomic, strong)UILabel *customerReceipts;//客户实收
@property (nonatomic, strong)UILabel *customerOutof;//客户实付
@property (nonatomic, strong)UILabel *customerBalance;//客户余额

@property (nonatomic, strong)UIView * line2;//线条2

@property (nonatomic, strong)UILabel *ower;//业主
@property (nonatomic, strong)UILabel *owerReceipts;//业主实收
@property (nonatomic, strong)UILabel *owerOutof;//业主实付
@property (nonatomic, strong)UILabel *owerBalance;//业主余额

@property (nonatomic, strong)UIView *line3;//线条3

@property (nonatomic, strong)UILabel *gainPrice;//盈利总额
@property (nonatomic, strong)UILabel *receiptsPrice;//实收合计
@property (nonatomic, strong)UILabel *outofPrice;//实付合计
@property (nonatomic, strong)UILabel *balancePrice;//余额合计

@property (nonatomic, strong)UILabel *businessLoanPrice;//商贷金额
@property (nonatomic, strong)UILabel *evaluatePrice;//评估价
@property (nonatomic, strong)UILabel *wagesPrice;//公积金金额

@end

@implementation FeeTableViewHeaderView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self = [super initWithFrame:(CGRect)frame]) {
        [self setUI];
    }
    return self;
}
- (void)setUI{
    _backHeader = [UIView new];
    _backHeader.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    _jieyongDate = [UILabel new];
    _jieyongDate.textAlignment = NSTextAlignmentLeft;
    _jieyongDate.text = @"结佣日: 2017-12-07";
    _jieyongDate.textColor = UIColorFromRGB(0x404040);
    _jieyongDate.font = [UIFont systemFontOfSize:14.0f];
    
    _line1 = [UIView new];
    _line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    //客户
    _customer = [UILabel new];
    _customer.textAlignment = NSTextAlignmentLeft;
    _customer.text = @"客户";
    _customer.textColor = UIColorFromRGB(0x404040);
    _customer.font = [UIFont boldSystemFontOfSize:14.0f];
    
    _customerReceipts = [UILabel new];
    _customerReceipts.textAlignment = NSTextAlignmentLeft;
    _customerReceipts.text = @"客户";
    _customerReceipts.textColor = UIColorFromRGB(0x404040);
    _customerReceipts.font = [UIFont boldSystemFontOfSize:14.0f];
}

@end
