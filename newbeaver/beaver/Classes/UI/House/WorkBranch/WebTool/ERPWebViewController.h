//
//  ERPWebViewController.h
//  chowRentAgent
//  与WEB交互页面控制器
//  Created by 凯文马 on 15/11/13.
//  Copyright © 2015年 eallcn. All rights reserved.
//

#pragma clang diagnostic ignored "-Wignored-attributes"
typedef void(^getHouseCode)(NSDictionary *);
#import "EBWebViewController.h"

@interface ERPWebViewController : EBWebViewController

+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL isHiddenRightBarItem;

@property (nonatomic, copy) NSString *titleDate;

/**
 *  与WEB交互协议头
 */
@property (nonatomic, copy) NSString *protocal;

/**
 *  用户token信息
 */
@property (nonatomic,copy) NSString *token;

/**
 *  通过js方法打开网页页面
 *
 *  @param param 网页信息('title'/'url')
 */
- (void)openWebPage:(NSDictionary *)param;

/**
 *  清空缓存信息
 */
- (void)cleanCache;

# pragma mark -

- (void)mapActWithLine:(NSArray*)acts;


- (void)setHouse:(getHouseCode)getHouseCode;
@property (nonatomic,copy)getHouseCode  houseCode;

@end
