//
//  HouseNewForceFollowUpViewController.h
//  beaver
//
//  Created by mac on 17/11/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger , ForceFollowUpType)
{
    ZHForceFollowUpTypeNO = 1,//不需要
    ZHForceFollowUpTypeYES  = 2,//需要强制写跟进
};

@interface HouseNewForceFollowUpViewController : BaseViewController

@property (nonatomic, assign) ForceFollowUpType followUptype;

@property (nonatomic, strong) void(^returnBlock )(BOOL succeed);

@property (nonatomic, strong) NSString *house_id;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *house_code;

@property (nonatomic, strong) NSArray *phoneNum;//手机号

@property (nonatomic, strong) NSString *call_flags;//隐号呼叫

@property (nonatomic, assign) BOOL isForceFollow;//是否是强制跟进


@end
