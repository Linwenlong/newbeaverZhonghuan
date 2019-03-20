//
//  PerformanceRankingView.h
//  beaver
//
//  Created by mac on 17/8/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PerformanceRankingViewDelegate <NSObject>

- (void)selectedMonth:(UITapGestureRecognizer *)tap;

@end

@interface PerformanceRankingView : UIView

@property (nonatomic, strong)UILabel *Ranking;//排名

@property (nonatomic, strong)UILabel *month;//月份

@property (nonatomic, strong)UILabel *myRankingNumber;//我的排名数字

@property (nonatomic, weak)id<PerformanceRankingViewDelegate> rankingDelegate;

@end
