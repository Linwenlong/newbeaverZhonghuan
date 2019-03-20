//
//  FinancialDetailTableViewCell.m
//  beaver
//
//  Created by mac on 17/11/27.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinancialDetailTableViewCell.h"
#import "SDAutoLayout.h"

@interface FinancialDetailTableViewCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong)UILabel *type; //款项的类型
@property (nonatomic, strong)UILabel *date; //日期
@property (nonatomic, strong)UILabel *price;//价格
@property (nonatomic, strong)UILabel *seek; //盈利
@property (nonatomic, strong)UILabel *pay; //是否支付

@end

@implementation FinancialDetailTableViewCell

#pragma mark -- 时间戳转时间
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}

- (void)setDic:(NSDictionary *)dic isEdit:(BOOL)edit{ //是否处理编辑状态
    _type.text = dic[@"price_name"];
    _date.text = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[@"finance_date"]]]; //时间错
    _price.text = [NSString stringWithFormat:@"¥%@",dic[@"price_num"]];   //价格
    _seek.text = dic[@"price_type"];
    _pay.text = dic[@"order_no_status"];
    
    if ([dic[@"order_no_status"] isEqualToString:@"未支付"]) {
        _pay.textColor = UIColorFromRGB(0x2EB2EF);
    }else{
        _pay.textColor = UIColorFromRGB(0x808080);
    }
    
    if ([dic[@"order_no"] isEqualToString:@""]) {
        _qrcode.image = [UIImage imageNamed:@"ashcode"];
    }else{
        _qrcode.image = [UIImage imageNamed:@"bulecode"];
    }
    CGFloat x = 15;
    CGFloat h = 20;
    CGFloat w = 80;
    CGFloat spacing = 10;
    BOOL is_edit = [dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"];
    if (edit == YES) {//处理编辑状态时
        if (!is_edit) {
            //改变frame 往左移 4
                CGFloat offx = 40;
                _type.sd_resetLayout
                .topSpaceToView(self.contentView,x)
                .leftSpaceToView(self.contentView,x+offx)
                .widthIs(100)
                .heightIs(h);
                
                _date.sd_layout
                .topSpaceToView(_type,spacing)
                .leftSpaceToView(self.contentView,x+offx)
                .widthIs(w)
                .heightIs(h);
                
                _price.sd_layout
                .topSpaceToView(_date,spacing)
                .leftSpaceToView(self.contentView,x+offx)
                .widthIs(w)
                .heightIs(h);
  
       }
    }else{
        if (!is_edit) {
            //还原
        
                _type.sd_resetLayout
                .topSpaceToView(self.contentView,x)
                .leftSpaceToView(self.contentView,x)
                .widthIs(100)
                .heightIs(h);
                
                _date.sd_layout
                .topSpaceToView(_type,spacing)
                .leftSpaceToView(self.contentView,x)
                .widthIs(w)
                .heightIs(h);
                
                _price.sd_layout
                .topSpaceToView(_date,spacing)
                .leftSpaceToView(self.contentView,x)
                .widthIs(w)
                .heightIs(h);
  
        }
    }
}

- (void)handleSwipeGesture:(UIPanGestureRecognizer *)sender{
    NSLog(@"左滑");
    CGPoint point = [sender translationInView:self];
    CGFloat absX = fabs(point.x);
    CGFloat absY = fabs(point.y);
    NSLog(@"absX = %f",absX);
    NSLog(@"absY = %f",absY);
    
   
    if (absX >= absY ) {
        self.editing=NO;
        if (self.contentView.center.x == kScreenW / 2.0f-60) {
            if (point.x < 0) {
                return;
            }else{
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.contentView.center = CGPointMake(kScreenW/2.0f, self.contentView.center.y);
                }];
            }
        }else{
            if (point.x > 0) {
                return;
            }else{
                [UIView animateWithDuration:0.3 animations:^{
                    // 放大
                    self.contentView.center = CGPointMake(kScreenW/2.0f-60, self.contentView.center.y);
                }];
                
            }
        }
        [sender setTranslation:CGPointZero inView:self];
    }else{

        UIView *view =sender.view.superview.superview.superview.superview.superview;
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            scrollView.scrollEnabled = YES;
        }
        UIView *view1 =sender.view.superview.superview.superview;

        if ([view1 isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            tableView.scrollEnabled = YES;
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
//        // 移动结束后
//        if ([self.delegate respondsToSelector:@selector(tableView:EndSlidingCell:)]) {
//            [self.delegate tableView:self.tableView EndSlidingCell:self];
//        }
        NSInteger XONE = 0 - (kScreenW / 5.0);
        // 当滑动的距离没超过屏幕的五分之一时恢复原状
        if (self.frame.origin.x > XONE){
            XONE = kScreenW / 5.0;
            // 当滑动距离超过屏幕五分之一时移除当前cell
            if (self.frame.origin.x > XONE){
//                [self DeleteCurrentCell];
            }else{
//                [self Restitution];
            }
        }else if (self.frame.origin.x < XONE){
            // 右滑超过屏幕的五分之一时移除当前cell
//            [self DeleteCurrentCell];
        }
    }

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"self.with = %f",self.width);
        self.width += 60;
        self.contentView.backgroundColor = [UIColor whiteColor];
        NSLog(@"self.with = %f",self.width);
        //添加左滑手势
        //左右滑动
        _swipeGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
        _swipeGesture.delegate = self;
        [self.contentView addGestureRecognizer:_swipeGesture];
        
        [self setUI];
    }
    return self;
}

- (void)setUI{
    CGFloat x = 15;

    CGFloat spacing = 10;
    _type = [UILabel new];
    _type.text = @"";
    _type.textAlignment = NSTextAlignmentLeft;
    _type.font = [UIFont fontWithName:@"PingFang-SC-Medium" size:14];
    _type.textColor = UIColorFromRGB(0x404040);
    
    _date = [UILabel new];
    _date.text = @"";
    _date.textAlignment = NSTextAlignmentLeft;
    _date.font = [UIFont systemFontOfSize:12.0f];
    _date.textColor = UIColorFromRGB(0x808080);
    
    _price = [UILabel new];
    _price.text = @"¥6104.00";
    _price.textAlignment = NSTextAlignmentLeft;
    _price.font = [UIFont systemFontOfSize:14.0f];
    _price.textColor = UIColorFromRGB(0xff3800);
    
    _seek = [UILabel new];
    _seek.text = @"盈利";
    _seek.textAlignment = NSTextAlignmentLeft;
    _seek.font = [UIFont systemFontOfSize:14.0f];
    _seek.textColor = UIColorFromRGB(0x404040);
    
    _pay = [UILabel new];
    _pay.text = @"未支付";
    _pay.textAlignment = NSTextAlignmentCenter;
    _pay.font = [UIFont systemFontOfSize:13.0f];
    _pay.textColor = UIColorFromRGB(0x2EB2EF);
    
    
    _qrcode = [UIImageView new];
    _qrcode.userInteractionEnabled = YES;
    
  
    _btn = [UIButton new];
    [_btn setImage:[UIImage imageNamed:@"garbage"] forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btn.backgroundColor = [UIColor redColor];
    _btn.titleLabel.font = [UIFont systemFontOfSize:15.0f];

    [self addSubview:_btn];
    CGFloat btn_w = 60;
    
    _btn.sd_layout
    .topSpaceToView(self,0)
    .rightSpaceToView(self,0)
    .widthIs(btn_w)
    .heightIs(110);
    NSLog(@"btn=%@",NSStringFromCGRect(_btn.frame));
   
    
    [self.contentView sd_addSubviews:@[_type,_date,_price,_seek,_pay,_qrcode]];
    
    CGFloat h = 20;
    CGFloat w = 80;
    
    _type.sd_layout
    .topSpaceToView(self.contentView,x)
    .leftSpaceToView(self.contentView,x)
    .widthIs(100)
    .heightIs(h);
    
    _date.sd_layout
    .topSpaceToView(_type,spacing)
    .leftSpaceToView(self.contentView,x)
    .widthIs(w)
    .heightIs(h);
    
    _price.sd_layout
    .topSpaceToView(_date,spacing)
    .leftSpaceToView(self.contentView,x)
    .widthIs(w)
    .heightIs(h);
    
    _seek.sd_layout
    .topSpaceToView(_type,spacing)
    .leftSpaceToView(_date,35)
    .widthIs(60)
    .heightIs(h);
    
    _pay.sd_layout
    .topSpaceToView(self.contentView,x)
    .rightSpaceToView(self.contentView,x)
    .widthIs(60)
    .heightIs(h);
    
    _qrcode.sd_layout
    .topSpaceToView(_pay,spacing)
    .centerXEqualToView(_pay)
    .widthIs(30)
    .heightIs(30);
    
//    CGFloat btn_w = 60;
    
//    _btn.sd_layout
//    .topSpaceToView(self.contentView,0)
//    .rightSpaceToView(self.contentView,-btn_w)
//    .widthIs(btn_w)
//    .heightIs(110);
    
    [self bringSubviewToFront:self.contentView];
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    
    return YES;
}

@end
