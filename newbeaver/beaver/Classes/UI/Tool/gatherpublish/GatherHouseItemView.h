//
//  GatherHouseItemView.h
//  beaver
//
//  Created by ChenYing on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBIconLabel;
@class RTLabel;
@class EBGatherHouse;

@interface GatherHouseItemView : UIView

@property (nonatomic, readonly) UILabel *titleView;
@property (nonatomic, readonly) EBIconLabel *headerLabel;
@property (nonatomic, readonly) RTLabel *footerLabel;
@property (nonatomic, readonly) EBIconLabel *clickLabel;
@property (nonatomic, readonly) EBIconLabel *reportLabel;
@property (nonatomic, readonly) EBIconLabel *gatherLabel;
@property (nonatomic, readonly) UIButton *phoneButton;
@property (nonatomic, readonly) UILabel *tagLabel;
@property (nonatomic, strong) EBGatherHouse *house;
@property (nonatomic, assign) BOOL showHouseType;

@end
