//
//  AnonymousCallViewController.h
//  beaver
//
//  Created by wangyuliang on 14-6-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBHouse.h"
#import "EBClient.h"

typedef NS_ENUM(NSInteger , EAlertType)
{
    EAlertTypeInput = 101,
    EAlertTypeTip = 102
};

typedef NS_ENUM(NSInteger , EAnonymousPageType)
{
    EAnonymousUnstart = 1,
    EAnonymousStart = 2,
    EAnonymousWait = 3
};

@interface AnonymousCallViewController : BaseViewController <UIAlertViewDelegate>

@property (nonatomic)  BOOL isHouse;
@property (nonatomic)  NSInteger pageType;
@property (nonatomic, strong) EBHouse *house;
@property (nonatomic, strong) EBClient *client;
@property (nonatomic, strong) NSString *anonymousNum;

- (void)refreshView;

@end
