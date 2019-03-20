//
//  NewHouseWebViewController.h
//  beaver
//
//  Created by ChenYing on 14-8-4.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "NJKWebViewProgress.h"
#import "EBNewHouseFollow.h"

typedef NS_ENUM(NSInteger , ENewHouseWebViewType)
{
    ENewHouseWebViewTypeList = 1,
    ENewHouseWebViewTypeDeatil = 2,
    ENewHouseWebViewTypeFollowDetail = 3
};

@interface NewHouseWebViewController : BaseViewController <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property(nonatomic, copy)NSString *requestURL;
@property(nonatomic, strong)EBNewHouseFollow *follow;

@end
