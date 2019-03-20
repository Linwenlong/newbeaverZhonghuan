//
// Created by 何 义 on 14-3-26.
// Copyright (c) 2014 eall. All rights reserved.
//

@class EBHouse;
@class EBClient;

@interface EBCrypt : NSObject
//encrypt 将…编码
+(NSString *)encryptHouse:(EBHouse *)house;
+(NSString *)encryptClient:(EBClient *)client;

//decrypt 解码
+ (NSArray *)decrypt:(NSString *)code;

+(NSString *)decryptText:(NSString *)code;
+(NSString *)encryptText:(NSString *)code;

//+ (NSString*) rsaEncryptString:(NSString*) string;

//+(NSString *)encryptByTranslate:(NSString *)str;

@end