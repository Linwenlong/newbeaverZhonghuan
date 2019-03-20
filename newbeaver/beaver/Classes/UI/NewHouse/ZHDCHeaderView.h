//
//  ZHDCHeaderView.h
//  CentralManagerAssistant
//
//  Created by mac on 17/1/8.
//  Copyright © 2017年 wenlongLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZHDCHeaderViewDelegate <NSObject>

- (void)menuCellDidSelected:(NSInteger)MenuIndex andDetailIndex:(NSInteger)DetailIndex;


@end



@interface ZHDCHeaderView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,assign) id<ZHDCHeaderViewDelegate>delegate;

- (void)createOneMenuTitleArray:(NSArray *)menuTitleArray FirstArray:(NSArray *)FirstArray;
- (void)createTwoMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr;

- (void)createThreeMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr threeArr:(NSArray *)threeArr;

- (void)createFourMenuTitleArray:(NSArray *)menuTitleArray FirstArr:(NSArray *)firstArr SecondArr:(NSArray *)secondArr threeArr:(NSArray *)threeArr fourArr:(NSArray *)fourArr;

@end

