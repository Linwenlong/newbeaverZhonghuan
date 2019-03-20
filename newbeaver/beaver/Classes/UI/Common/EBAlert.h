//
// Created by 何 义 on 14-3-21.
// Copyright (c) 2014 eall. All rights reserved.
//


@interface EBAlert : NSObject

+(void)alertError:(NSString *)string;
+(void)alertError:(NSString *)string length:(NSTimeInterval)length;
+(void)alertSuccess:(NSString *)string length:(NSTimeInterval)length;
+(void)alertSuccess:(NSString *)string;
+(void)alertSuccess:(NSString *)string allowUserInteraction:(BOOL)allowUserInteraction;
+(void)alertSuccess:(NSString *)string length:(NSTimeInterval)length allowUserInteraction:(BOOL)allowUserInteraction;

+(void)showLoading:(NSString *)string;
+(void)showLoading:(NSString *)string allowUserInteraction:(BOOL)allowUserInteraction;
+(void)hideLoading;
+(void)hideLoading:(void(^)(BOOL finished))completion;
+(void)confirmWithTitle:(NSString *)title message:(NSString *)message yes:(NSString *)yes action:(void(^)(void))action;
+(void)alertWithTitle:(NSString *)title message:(NSString *)message;
+(void)alertWithTitle:(NSString *)title message:(NSString *)message confirm:(void(^)())confirm;
+(void)alertWithTitle:(NSString *)title message:(NSString *)message yes:(NSString *)yes confirm:(void(^)())confirm;
+(void)alertWithTitle:(NSString *)title message:(NSString *)message yes:(NSString *)yes no:(NSString *)no confirm:(void(^)())confirm;

//+(void)

@end