//
//  ZHDCDetailHeadView.h
//  beaver
//
//  Created by mac on 17/4/24.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZHDCDetailImageClickDelegate <NSObject>

- (void)image:(UIImageView *)imageView imageTitle:(NSString *)imageTitle images:(NSArray *)images;

@end

@interface ZHDCDetailHeadView : UIView

@property (nonatomic, assign)id<ZHDCDetailImageClickDelegate> imageClickDelegate;

//先加载头视图
- (instancetype)initWithFrame:(CGRect)frame ImageArray:(NSArray *)images andCommission:(NSDictionary*)commission otherDic:(NSDictionary *)dic;

@end
