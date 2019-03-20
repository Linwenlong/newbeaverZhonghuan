//
//  CCMD5.m
//  chow
//
//  Created by LiuLian on 9/16/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "CCMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CCMD5

+ (NSString *)md5:(NSString *)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];;
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (NSInteger i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x", result[i]];
    }
    return ret;
}

@end
