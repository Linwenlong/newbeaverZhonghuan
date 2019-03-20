//
//  KWWebAnalyzer.m
//  webTest
//
//  Created by 凯文马 on 15/11/12.
//  Copyright © 2015年 kevin. All rights reserved.
//

#import "KWWebAnalyzer.h"

@interface KWWebAnalyzer ()
@property (nonatomic, copy) NSString *url;
@end

@implementation KWWebAnalyzer

- (instancetype)initWithAnalyzeHeader:(NSString *)header
{
    if (self = [self init]) {
        _header = header;
    }
    return self;
}

- (void)setRequestURL:(NSURL *)requestURL
{
    requestURL = requestURL;
    _url = requestURL.absoluteString;
    _enableAnalyze = [self analyze];
}


- (BOOL)analyze
{
    if (![_url hasPrefix:_header]) {
        return NO;
    }
//    _url = [_url stringByRemovingPercentEncoding];
//    NSString *infos = [_url componentsSeparatedByString:@"://"].lastObject;
//    NSArray *infoArray = [infos componentsSeparatedByString:@"?"];
//    _actionName = infoArray.firstObject;
//    NSString *paramStr = infoArray.lastObject;
//    NSArray *paramArray = [paramStr componentsSeparatedByString:@"&"];
//    NSMutableDictionary *tempDict = [self paramDictingWithArray:paramArray];
//    _callback = tempDict[@"callback"];
//    [tempDict removeObjectForKey:@"callback"];
//    _params = [tempDict copy];
    
    
    _url = [_url stringByRemovingPercentEncoding];
    
    NSArray *actArray = [_url componentsSeparatedByString:@"eallios://"];
    _actionName = [actArray[1] componentsSeparatedByString:@"?"][0];
    
    NSArray *infoArray = [actArray[1] componentsSeparatedByString:[NSString stringWithFormat:@"%@?",_actionName]];
    NSString *paramStr = infoArray.lastObject;
    NSArray *paramArray = [paramStr componentsSeparatedByString:@"&"];
    NSMutableDictionary *tempDict = [self paramDictingWithArray:paramArray];
    _callback = tempDict[@"callback"];
    [tempDict removeObjectForKey:@"callback"];
    _params = [tempDict copy];
    

    
    return YES;
}


- (NSMutableDictionary *)paramDictingWithArray:(NSArray *)array
{
    NSMutableDictionary *parames = [@{} mutableCopy];
    for (NSString *keyValue in array) {
        NSArray *KVs = [keyValue componentsSeparatedByString:@"="];
        parames[KVs.firstObject] = KVs.lastObject;
    }
    return parames;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"解析地址：%@；执行操作：%@；参数表列：%@；回调函数：%@",_url,_actionName,_params,_callback];
}

- (void)callbackActionWithParam:(NSString *)param withWebView:(UIWebView *)webView
{
    NSString *action = [NSString stringWithFormat:@"%@('%@')",_callback,param];
    NSLog(@"callback check :%@  -kevin",action);
    [webView stringByEvaluatingJavaScriptFromString:action];
}

@end
