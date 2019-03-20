//
// Created by 何 义 on 14-3-20.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "DDGPreferences.h"

@interface EBPreferences : DDGPreferences

+ (EBPreferences *)sharedInstance;

//lwl
@property (nonatomic, copy) NSString *photo;//头像
@property (nonatomic, copy) NSString *dept_id;//部门id
@property (nonatomic, copy) NSString *dept_name;//部门名称
@property (nonatomic, copy) NSString *image_num_limit;//图片限制


// login related
@property (nonatomic, copy) NSString *token;// 旧token
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSString *ticket;
@property (nonatomic) NSTimeInterval loginTime;
@property (nonatomic) NSTimeInterval tokenLife;
@property (nonatomic) BOOL deviceTokenGot;


// user related

@property (nonatomic, copy) NSString *city_name;//城市

@property (nonatomic, copy) NSString *cityName;//用户账号

@property (nonatomic, copy) NSString *userAccount;//用户账号
@property (nonatomic, copy) NSString *userPassword;//用户密码
@property (nonatomic, copy) NSString *companyCode;//公司编号
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, assign) BOOL enableExtensionNumber;
@property (nonatomic, copy) NSString *wapToken;//旧wapToken

/**
 *  登录时授权文件
 */
@property (nonatomic, strong) NSDictionary *loginAuthorizeUrls;

// 地址
@property (nonatomic, copy) NSString *baseUrl;
@property (nonatomic, copy) NSString *wapUrl;
@property (nonatomic, copy) NSString *wapMainUrl;
@property (nonatomic, copy) NSString *xmppDomainUrl;
@property (nonatomic, copy) NSString *xmppDomainPort;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *cal_url;
// 工作台缓存
@property (nonatomic, strong) NSDictionary *workBenchDatas;
// 发现缓存
@property (nonatomic, strong) NSDictionary*foundListDatas;
//美丽屋直接打开房源id
@property (nonatomic, copy) NSString *houseIdForOpen;
//无网时候的通知
@property (nonatomic, assign) BOOL rememberNoneImageChoice;
//没网是否可以下载
@property (nonatomic, assign) BOOL allowImageDownloadViaWan;

@property (nonatomic, assign) BOOL rememberAnonymousNavChoice; //记住匿名的消息

- (BOOL)isTokenValid;
+ (NSString *)systemIMIDEALL;
+ (NSString *)systemIMIDCompany;
+ (NSString *)systemIMIDNewHouse;
- (void)resetPref;

@end
