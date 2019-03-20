//
//  HttpTool.h
//  CollegeProject
//
//  Created by 刘海伟 on 16/9/27.
//  Copyright © 2016年 zhdc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface HttpTool : NSObject

+ (void)get:(NSString *)URLString
 parameters:( id)parameters
    success:(void (^)(id responseObject))success
    failure:(void (^)(NSError *error))failure;

+ (void)post:(NSString *)URLString
  parameters:( id)parameters
     success:(void (^)(id responseObject))success
     failure:(void (^)(NSError *error))failure;

+ (NSURLSessionDataTask *)updateImageWithUrl:(NSString *)urlString
                              HTTPMethod:(NSString *)method
                                  params:(NSMutableDictionary *)params
                                fileData:(NSMutableDictionary *)fileData
                            successBlock:(void(^)(id result))success
                            failureBlock:(void(^)(NSError *error))failure;

@end
