//
//  CostCountDetailView.m
//  beaver
//
//  Created by mac on 17/10/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "CostCountDetailView.h"

@interface CostCountDetailView ()

@property (nonatomic, weak) UIView *currentView;

@property (nonatomic, weak) UIView *currentleftView;
@property (nonatomic, weak) UIView *currentrightView;

@property (nonatomic, weak) UIView *lineView;

@end

@implementation CostCountDetailView

-(instancetype)initWithFrame:(CGRect)frame arr:(NSArray *)arr{
    self = [super initWithFrame:frame];
    if (self) {
//        [self setUI:arr];
         [self setTestUI:arr];
    }
    return self;
}


- (void)setTestUI:(NSArray *)arr{
//    NSDictionary *dic = arr.firstObject;
//    NSArray *keys = dic.allKeys;
    
    //     NSLog(@"keys1 = %@",keys);
    //    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //        NSDictionary *dic = (NSDictionary *)obj;
    //        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    //            NSLog(@"key = %@",key);
    //        }];
    //        NSLog(@"dic = %@",dic);
    //    }];
    
    CGFloat currleft = 0;//当前的左边高度
    CGFloat currright = 0;//当前的又边高度
    CGFloat padding_x = 15;
    CGFloat padding_y = 20;
    CGFloat bg_h = 0;
    CGFloat bg_w = (kScreenW-padding_x*2)/2.0f;
    CGFloat view_padding = 0;
    
    for (int i = 0; i < arr.count; i++) {
         NSArray *tmpArr = arr[i];//这里面数组 //name  value
        
        for (int j = 0; j < tmpArr.count; j++) {
            NSDictionary *dic = tmpArr[j];
            NSString *key = dic[@"name"];
            NSString *value = dic[@"value"];
            //文字高度
            CGFloat title_h = [self sizeToHeight:[UIFont systemFontOfSize:12.0f] content:key];
            //内容高度
            CGFloat content_h = [self sizeToHeight:[UIFont systemFontOfSize:12.0f] content:value];
            CGFloat height = title_h + content_h + 5 + 21;
            if (j % 2 == 0) {//leftView
                bg_h = currleft;
            }else{
                bg_h = currright;
            }
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(padding_x + (j % 2) * (bg_w+padding_x),CGRectGetMaxY(_lineView.frame)+ padding_y +(bg_h)+(j/2)*view_padding, bg_w, height)];
            //            _currentView = view;
            
            UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bg_w, title_h)];
            titleLable.font = [UIFont systemFontOfSize:12.0f];
            titleLable.text = key;
            titleLable.textColor = UIColorFromRGB(0x404040);
            titleLable.textAlignment = NSTextAlignmentLeft;
            titleLable.numberOfLines = 0;
            [view addSubview:titleLable];
            UILabel *contentLable = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLable.frame)+5, bg_w, content_h)];
            contentLable.textColor = UIColorFromRGB(0x808080);
            contentLable.font = [UIFont systemFontOfSize:12.0f];
            contentLable.textAlignment = NSTextAlignmentLeft;
            if ([key containsString:@"时间"]||[key containsString:@"日期"]) {
                if ([self isPureInt:value]) {
                    contentLable.text = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",value]];
                }else{
                    contentLable.text = value;
                }
            }else{
                contentLable.text = value;
            }
            contentLable.numberOfLines = 0;
            [view addSubview:contentLable];
            
            if (j % 2 == 0) {//左边
                currleft += height;
                _currentleftView = view;
            }else{//右边
                currright += height;
                _currentrightView = view;
            }
            [self addSubview:view];
        }
        if (currleft > currright) {
            _currentView = _currentleftView;
        }else{
            _currentView = _currentrightView;
        }
        
        UIView *shuzhi = [[UIView alloc]initWithFrame:CGRectMake(kScreenW/2.0f, padding_y+CGRectGetMaxY(_lineView.frame), 1, CGRectGetMaxY(_currentView.frame)-CGRectGetMaxY(_lineView.frame)-padding_y)];
        shuzhi.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        [self addSubview:shuzhi
         ];
        
        //加载线条view
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_currentView.frame)+padding_y, kScreenW, 10)];
        _lineView = lineView;
        lineView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        //清空
        currleft = 0;
        currright = 0;
        [self addSubview:lineView];
        
    }
    self.contentSize = CGSizeMake(kScreenW, CGRectGetMaxY(_lineView.frame));

}

//宽度一个 高度不一样
- (void)setUI:(NSArray *)arr{
    
    NSDictionary *dic = arr.firstObject;
    NSArray *keys = dic.allKeys;
    
//     NSLog(@"keys1 = %@",keys);
//    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSDictionary *dic = (NSDictionary *)obj;
//        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//            NSLog(@"key = %@",key);
//        }];
//        NSLog(@"dic = %@",dic);
//    }];
    
    CGFloat currleft = 0;//当前的左边高度
    CGFloat currright = 0;//当前的又边高度
    CGFloat padding_x = 15;
    CGFloat padding_y = 20;
    CGFloat bg_h = 0;
    CGFloat bg_w = (kScreenW-padding_x*2)/2.0f;
    CGFloat view_padding = 0;
    
    for (int i = 0; i < arr.count; i++) {
        NSDictionary *dic = arr[i];
        
        for (int j = 0; j < keys.count; j++) {
            //文字高度
            CGFloat title_h = [self sizeToHeight:[UIFont systemFontOfSize:12.0f] content:dic.allKeys[j]];
            //内容高度
            CGFloat content_h = [self sizeToHeight:[UIFont systemFontOfSize:12.0f] content:dic[dic.allKeys[j]]];
            CGFloat height = title_h + content_h + 5 + 21;
            if (j % 2 == 0) {//leftView
                bg_h = currleft;
            }else{
                bg_h = currright;
            }

            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(padding_x + (j % 2) * (bg_w+padding_x),CGRectGetMaxY(_lineView.frame)+ padding_y +(bg_h)+(j/2)*view_padding, bg_w, height)];
//            _currentView = view;
            
            NSString *key = keys[j];
            
            UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, bg_w, title_h)];
            titleLable.font = [UIFont systemFontOfSize:12.0f];
            titleLable.text = key;
            titleLable.textColor = UIColorFromRGB(0x404040);
            titleLable.textAlignment = NSTextAlignmentLeft;
            titleLable.numberOfLines = 0;
            [view addSubview:titleLable];
            UILabel *contentLable = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLable.frame)+5, bg_w, content_h)];
            contentLable.textColor = UIColorFromRGB(0x808080);
            contentLable.font = [UIFont systemFontOfSize:12.0f];
            contentLable.textAlignment = NSTextAlignmentLeft;
            if ([key containsString:@"时间"]||[key containsString:@"日期"]) {
                contentLable.text = [self timeWithTimeIntervalString:[NSString stringWithFormat:@"%@",dic[key]]];
            }else{
                contentLable.text = dic[key];
            }
            contentLable.numberOfLines = 0;
            [view addSubview:contentLable];
            
            if (j % 2 == 0) {//左边
                currleft += height;
                _currentleftView = view;
            }else{//右边
                currright += height;
                _currentrightView = view;
            }
            [self addSubview:view];
        }
        if (currleft > currright) {
            _currentView = _currentleftView;
        }else{
            _currentView = _currentrightView;
        }
        
        UIView *shuzhi = [[UIView alloc]initWithFrame:CGRectMake(kScreenW/2.0f, padding_y+CGRectGetMaxY(_lineView.frame), 1, CGRectGetMaxY(_currentView.frame)-CGRectGetMaxY(_lineView.frame)-padding_y)];
        shuzhi.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        [self addSubview:shuzhi
         ];
        
        //加载线条view
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_currentView.frame)+padding_y, kScreenW, 10)];
        _lineView = lineView;
        lineView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        //清空
        currleft = 0;
        currright = 0;
        [self addSubview:lineView];
        
    }
    self.contentSize = CGSizeMake(kScreenW, CGRectGetMaxY(_lineView.frame));
}

- (CGFloat)sizeToHeight:(UIFont *)font content:(NSString *)content{
    CGFloat image_h = 100;
    CGFloat image_w = image_h*250/150;
    CGSize size = CGSizeMake(kScreenW-30-image_w,40);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    return actualsize.height;
}

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

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}



@end
