//
//  CodeVerifyViewController.h
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//
//第一次进行的短信认证

//verify 核对
//Anonymous 匿名的
typedef NS_ENUM(NSInteger , ECodeVerifyViewType)
{
    ECodeVerifyViewTypeLogin = 0,
    ECodeVerifyViewTypeAnonymousTel
};

#import "BaseViewController.h"
#import "RTLabel.h"

@interface CodeVerifyViewController : BaseViewController<UITextFieldDelegate,RTLabelDelegate>

@property (nonatomic, copy) NSString *verifyCode;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic) BOOL badPhoneNumber;
@property (nonatomic, assign) ECodeVerifyViewType viewType;
@property (nonatomic, strong) NSString *verifyType;
@property (nonatomic, copy) void(^verifySuccess)();


@end
