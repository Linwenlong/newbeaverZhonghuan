//
// Created by 何 义 on 14-3-18.
// Copyright (c) 2014 eall. All rights reserved.
//


@interface EBPhoneButton : UIView



@property (nonatomic, strong) void(^HiddenClickCall)(NSString *document_id,NSString *cust_name);//隐号通话电话点击
@property (nonatomic, strong) void(^HiddenClickSms)(NSString *document_id);//隐号通话发送短信

@property (nonatomic, copy) NSDictionary *phoneNumberDic;//隐号通话的dic

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *contactName;
@property (nonatomic, strong) UIView *view;

@property (nonatomic, strong) NSArray *phoneNumbers;
@property (nonatomic, assign) BOOL isMutliPhone;
@property (nonatomic, assign) BOOL isHouse;
@property (nonatomic, assign) BOOL isorNotHidden;    //是否是隐号

- (id)initWithFrameCustom:(CGRect)frame;

- (id)initWithFrameHidden:(CGRect)frame;

@end
