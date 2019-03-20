//
//  FinancialHeaderView.h
//  beaver
//
//  Created by mac on 17/11/26.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FinancialHeaderViewDelegate <NSObject>

- (void)currentPage:(NSInteger)current;

@end

@interface FinancialHeaderView : UIView

@property (nonatomic, strong)UIView *sliderview;

@property (nonatomic, weak)id<FinancialHeaderViewDelegate> financiaDelegate;//代理

@end
