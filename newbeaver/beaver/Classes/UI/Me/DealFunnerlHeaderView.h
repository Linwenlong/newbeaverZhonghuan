//
//  DealFunnerlHeaderView.h
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DealFunnerlHeaderViewDelegate <NSObject>

- (void)selected:(NSInteger)tag;

@end

@interface DealFunnerlHeaderView : UIView

@property (nonatomic, strong)UILabel *deparment;//部门

@property (nonatomic, strong)UILabel *month;//月份

@property (nonatomic, weak) id<DealFunnerlHeaderViewDelegate> headerViewDelegate;

@end
