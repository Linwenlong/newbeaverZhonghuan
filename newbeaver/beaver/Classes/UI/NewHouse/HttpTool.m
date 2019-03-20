//
//  HttpTool.m
//  CollegeProject
//
//  Created by 刘海伟 on 16/9/27.
//  Copyright © 2016年 zhdc. All rights reserved.
//

#import "HttpTool.h"


@implementation HttpTool
+ (void)get:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSString *baseUrl;
    if (![URLString containsString:@"http"]) {
        baseUrl = [NSString stringWithFormat:@"%@/%@",NewHttpBaseUrl,URLString];
    }else{
        baseUrl = URLString;
    }
    
//    NSString *baseUrl = [NSString stringWithFormat:@"%@/%@",NewHttpBaseUrl,URLString];
    NSLog(@"baseUrl = %@",baseUrl);
    // 获取http请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain",@"text/json", @"text/javascript",@"text/html",nil];
    // 发送请求
    [mgr GET:baseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

+ (void)post:(NSString *)URLString parameters:(id )parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSString *baseUrl = nil;
    if (![URLString containsString:@"http"]) {
       baseUrl = [NSString stringWithFormat:@"%@/%@",NewHttpBaseUrl,URLString];
    }else{
        baseUrl = URLString;
    }
    
    NSLog(@"baseUrl = %@",baseUrl);
    // 获取请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    mgr.responseSerializer = [AFHTTPResponseSerializer  serializer];
    
    // 发送请求
    [mgr POST:baseUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


//上传json数据
+ (void)postForJson:(NSString *)URLString parameters:(id )parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *access_token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1MTY4MTk2OTcsInVzZXJfbmFtZSI6InRyYWRlLWFwcCIsImF1dGhvcml0aWVzIjpbIlJPTEVfUVVBTl9KSSIsIlJPTEVfUUlBTllVRV9aSFVMSSIsIlJPTEVfWkhFTkdfU0hFTiIsIlJPTEVfWk9OR19KSUFOIiwiUk9MRV9MSU5HX1pIRU5HIiwiUk9MRV9PRkZTSVRFX0JVU0lORVNTX01BTkFHRVIiLCJST0xFX0pJRV9TVUFOIiwiVVNFUiIsIlJPTEVfT05TSVRFX0NMSUVOVF9NQU5BR0VSIiwiUk9MRV9aSFVfR1VBTiIsIlJPTEVfWkhVX1pIQUlfSklBT19TSFVJIiwiUk9MRV9ESV9ZQSIsIlJPTEVfUUlBTllVRV9KSU5HTEkiLCJST0xFX01BVEVSSUFMX0FETUlOSVNUUkFUT1IiLCJST0xFX0ZFSV9aSFVfWkhBSV9KSUFPX1NIVUkiLCJBRE1JTiIsIlJPTEVfQ0hVX05BIiwiUk9MRV9LVUFJX0pJIiwiUk9MRV9DSEFJX1FJQU5fSFUiXSwianRpIjoiODA5NGFiNGQtOWQ5Ni00YjkxLWJiZGItMWI1YzY0MTI2ZjYyIiwiY2xpZW50X2lkIjoiYWNtZSIsInNjb3BlIjpbIm9wZW5pZCJdfQ.LuFRuMqVMjklIxLzGK-ujpVeTDoCZy7zVUJzcM7At03FWNiHUCvRWqSXtmOa_Fz6PkbzYoVOloa4a5Mf_NjFVrHHiVH9liAwaFfbXlNrHMhMAw46C-VZKnk_cA9wncyQ9tDdA5BMlRy2TLYIqnMo4w81xAtkW8v4h9WLdwlq_D7YEL7mWOb2Sg_iB74-RVR7SYCt-Y9aqXVefu09SrTO2rXk3chddT23Wu6p_fi2r1psr01CzgP6-AUabqv1x2TE2LGVQGXYqJmRN4eTKWredeKA4fEX3WNl3o44snEoY079Fqw3A1ez_zjNVwB_NlvlVSdgD7Sa1RbnNPm0DyHz8w";
    
    [manager.requestSerializer setValue:access_token forHTTPHeaderField:@"token-id"];
    
    //添加多的请求格式
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain",@"text/json", @"text/javascript",@"text/html",nil];
    NSString *baseUrl = [NSString stringWithFormat:@"%@/%@",NewHttpBaseUrl,URLString];
    NSLog(@"baseUrl = %@",baseUrl);
    [manager POST:baseUrl parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

+(void)uploadImageWithUrl:(NSString* )strUrl dataParams:(NSMutableDictionary *)dataParams imageParams:(UIImage* ) image Success:(void(^)(NSDictionary *resultDic)) success Failed:(void(^)(NSError *error))fail
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //接收类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/html",
                                                         @"image/jpeg",
                                                         @"image/png",
                                                         @"application/octet-stream",
                                                         @"text/json",
                                                         nil];
    [manager POST:strUrl parameters:dataParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        NSData *imageData =UIImageJPEGRepresentation(image,1);
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imageData
                                    name:@"file"
                                fileName:fileName
                                mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"上传成功");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error=%@",error.localizedDescription);
    }];
}

+ (NSURLSessionDataTask*)updateImageWithUrl:(NSString *)urlString HTTPMethod:(NSString *)method params:(NSMutableDictionary *)params fileData:(NSMutableDictionary *)fileData successBlock:(void (^)(id))success failureBlock:(void (^)(NSError *))failure{
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    if (fileData != nil) {
        return [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (NSString *key in fileData) {
                NSData *data = [fileData objectForKey:key];
                [formData appendPartWithFileData:data name:@"image_file"  fileName:@"image_file.jpg"  mimeType:@"image/jpeg"];
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
             failure(error);
        }];
    }
    
    return nil;
}


//创建一个随机的文件名
+ (NSString *)createFileName{
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    
    CFRelease(uuidRef);
    
    NSString *uniqueId = (__bridge_transfer NSString *)uuidStringRef;
    
    return [NSString stringWithFormat:@"%@.jpg",uniqueId];
}


@end
