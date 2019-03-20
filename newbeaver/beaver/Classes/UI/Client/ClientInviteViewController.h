//
//  ClientInviteViewController.h
//  beaver
//
//  Created by wangyuliang on 14-5-21.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"
#import "HouseListViewController.h"

@class EBClient;
@class EBHouse;

typedef NS_ENUM(NSInteger , EClientInviteViewType)
{
    EClientInviteViewTypeAddInvite = 0,//邀请
    EClientInviteViewTypeAddVisited = 1,//带看
    EClientInviteViewTypeShareNewHouse = 2//分享新房
};

@interface ClientInviteViewController : BaseViewController

@property (nonatomic, strong) EBClient *clientDetail;
@property (nonatomic, strong) EBHouse *houseDetail;
@property (nonatomic, strong) NSArray *preSelectedHouses;
@property (nonatomic, assign) EClientInviteViewType viewType;
@property (nonatomic, copy) void(^handleCompleted)(NSArray *result);

@end
