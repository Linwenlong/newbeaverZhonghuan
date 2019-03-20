//
//  ClientItemView.h
//  beaver
//
//  Created by wangyuliang on 14-5-20.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientDataSource.h"
#import "EBStyle.h"
#import "EBHttpClient.h"
#import "EBClient.h"
#import "EBHouse.h"
#import "EBViewFactory.h"
#import "RTLabel.h"
#import "EBIconLabel.h"
#import "EBClient.h"
#import "EBController.h"
#import "EBFilter.h"
#import "EBContact.h"

@interface ClientItemView : UIView

@property (nonatomic, readonly) EBIconLabel *nameView;
@property (nonatomic, readonly) UILabel *lastNameLabel;
@property (nonatomic, readonly) UILabel *statusLabel;
//@property (nonatomic, readonly) UIImageView *rcmdIcon;
@property (nonatomic, readonly) UIImageView *tagFullPaid;
@property (nonatomic, readonly) UIImageView *tagAccess;
@property (nonatomic, readonly) UIImageView *tagRental;
@property (nonatomic, readonly) UIImageView *tagUrgent;
@property (nonatomic, readonly) RTLabel *detailLabel;
@property (nonatomic, strong) EBClient *client;
@property (nonatomic, readonly) UIButton *markView;
@property (nonatomic, readonly) UIButton *clickView;
@property (nonatomic, assign) BOOL marking;
@property (nonatomic, assign) BOOL selecting;
@property (nonatomic, readonly) UIView *leftPartView;
@property (nonatomic, readonly) UIView *rightPartView;
@property (nonatomic, copy) NSString *targetHouseId;
@property (nonatomic, copy) void(^clickBlock)(EBClient *client);
@property (nonatomic, copy) void(^changeMarkedStausBlock)(BOOL marked);

- (void)moveLocation;

@end
