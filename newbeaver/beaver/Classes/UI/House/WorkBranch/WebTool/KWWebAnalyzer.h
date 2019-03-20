//
//  KWWebAnalyzer.h
//  webTest
//
//  Created by 凯文马 on 15/11/12.
//  Copyright © 2015年 kevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KWWebAnalyzer : NSObject

/**
 *  创建一个网页协议解析器
 *
 *  @param header 协议
 *
 *  @return 网页协议解析器
 */
- (instancetype)initWithAnalyzeHeader:(NSString *)header;

/**
 *  请求地址
 */
@property (nonatomic, strong) NSURL *requestURL;

/**
 *  协议
 */
@property (nonatomic, copy) NSString *header;

/**
 *  是否符合协议
 */
@property (nonatomic, assign, readonly) BOOL enableAnalyze;

/**
 *  要执行的方法的名字
 */
@property (nonatomic, copy, readonly) NSString *actionName;

/**
 *  JS方法回调
 */
@property (nonatomic, copy, readonly) NSString *callback;

/**
 *  要执行的方法参数
 */
@property (nonatomic, copy, readonly) NSDictionary *params;

/**
 *  执行回调方法
 *
 *  @param param   参数
 *  @param webView JS方法网页视图
 */
- (void)callbackActionWithParam:(NSString *)param withWebView:(UIWebView *)webView;
@end
