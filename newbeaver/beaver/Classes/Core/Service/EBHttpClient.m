//
// Created by 何 义 on 14-3-5.
// Copyright (c) 2014 eall. All rights reserved.
//

#import "EBHttpClient.h"
#import "EBHouseCategory.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "EBPreferences.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "EBAlert.h"
#import "EBController.h"
#import "EBUpdater.h"
#import "EBCache.h"
#import "AESCrypt.h"
#import "EBHouseVisitLog.h"
#import "EBClientVisitLog.h"
#import "EBAppointment.h"
#import "EBClientFollowLog.h"
#import "EBHouseFollowLog.h"
#import "EBNumberStatus.h"
#import "EBFollowLogAddView.h"
#import "EBNewHouseFollow.h"
#import "EBGatherHouse.h"
#import "VoteToAddViewController.h"
#import "EBCommunity.h"
#import "CCMD5.h"
#import "MBProgressHUD+CZ.h"

@implementation EBHttpClient

+ (EBHttpClient *)sharedInstance
{
    if (!BEAVER_BASE_URL) return nil;
    static dispatch_once_t pred;
    static EBHttpClient *_sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] initWithBaseURL:nil];
    });
    _sharedInstance.currentBaseUrl = BEAVER_BASE_URL;
    return _sharedInstance;
}

+ (EBHttpClient *)wapInstance
{
    if (!BEAVER_WAP_URL) return nil;
    static dispatch_once_t pred;
    static EBHttpClient *_wapInstance = nil;
    dispatch_once(&pred, ^{
        _wapInstance = [[self alloc] initWithBaseURL:nil];
        _wapInstance.requestSerializer = [AFHTTPRequestSerializer serializer];
        _wapInstance.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    _wapInstance.currentBaseUrl = BEAVER_WAP_URL;
    return _wapInstance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        self.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        [EBController observeNotification:NOTIFICATION_NETWORK_STATUS_CHANGED from:self selector:@selector(networkStatusChanged:)];
    }

    return self;
}

- (void)networkStatusChanged:(NSNotification *)notification
{
    NSOperationQueue *operationQueue = self.operationQueue;
    switch (self.reachabilityManager.networkReachabilityStatus)
    {
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [operationQueue setSuspended:NO];
            break;
        case AFNetworkReachabilityStatusNotReachable:
        default:
            [operationQueue setSuspended:YES];
            break;
    }
}
- (void)logUrl:(NSString *)url parameters:(NSDictionary *)parameters
{
    NSArray *keys = parameters.allKeys;
   
    NSMutableArray *Marray  = [[NSMutableArray alloc]init];
    for (NSInteger i = 0 ; i<keys.count; i++) {
        NSString *str = [NSString stringWithFormat:@"%@=%@",keys[i],parameters[keys[i]]];
        [Marray addObject:str];
    }
    
    NSLog(@"\n**********************\n url: \n%@%@?%@\n**********************",self.baseURL,url,[Marray componentsJoinedByString:@"&"]);
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#define KEY_UPDATE_FORCE @"EB_FORCED_UPDATE"
#define KEY_NEW_VERSION @"EB_ONLINE_VERSION"
#define KEY_NEW_VERSION_URL @"EB_ONLINE_VERSION_URL"
- (void)handleData:(NSDictionary *)data withHandler:(void(^)(BOOL successful, NSDictionary *response))handler
{
    NSLog(@"验证码=%@",data[@"desc"]);
//    [EBAlert hideLoading]; 
    NSInteger errorCode = [data[@"code"] integerValue];
    if (errorCode == 0)
    {
        if (self == [EBHttpClient wapInstance]) {
            NSDictionary *update = data[@"mseUpdate"];
            [[NSUserDefaults standardUserDefaults] setBool:[update[@"force"] boolValue] forKey:KEY_UPDATE_FORCE];
            [[NSUserDefaults standardUserDefaults] setObject:update[@"version"] forKey:KEY_NEW_VERSION];
            [[NSUserDefaults standardUserDefaults] setObject:update[@"url"] forKey:KEY_NEW_VERSION_URL];
            [[NSUserDefaults standardUserDefaults]synchronize];
             
            if (update)
            {
                if ([EBUpdater hasUpdate]) {
//                    [EBUpdater newVersionAvailable:update[@"version"] url:update[@"url"] force:[update[@"force"] boolValue]];
                }
            }
            else
            {
                [EBUpdater clearNewVersionReminder];
            }
        }
        
        NSDictionary *follow = data[@"follow"];
        if (follow)
        {
            if (![EBFollowLogAddView getShowState])
            {
                EBSetFollowLogType type;
                CGRect frame;
                if (follow[@"owner"])
                {
                    type = EBSetFollowLogForHouse;
                    frame = CGRectMake(0, 0, 270, 300);
                }
                else
                {
                    type = EBSetFollowLogForClient;
                    frame = CGRectMake(0, 0, 270, 280);
                }
                EBFollowLogAddView *alert = [EBFollowLogAddView sharedInstance];
                alert.follow = follow;
                alert.setFollowType = type;
                alert.curFrame = frame;
                alert.processType = EBProcessTypeBegin;
                [alert showSetFollowLogView:YES];
            }
        }

        id responseData = data[@"data"];
        handler(YES, responseData);
        if (responseData && [responseData isKindOfClass:[NSDictionary class]] && responseData[@"hint"])
        {
            id hintData = responseData[@"hint"];
            NSString *hint = @"";
            if ([hintData isKindOfClass:[NSArray class]])
            {
                hint = (NSString *)[(NSArray *)hintData firstObject];
            }
            else if ([hintData isKindOfClass:[NSString class]])
            {
                hint = (NSString *)hintData;
            }
            [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_RECEIVE_REMINDER object:hint]];
        }
    }
    else
    {
        if (errorCode == -411 || errorCode == -999)
        {
            if (errorCode == -411)
            {
                //屏蔽
                [EBController accountDataReset];
            }
            else if (errorCode == -999)
            {
                #pragma mark -- LWL
                [EBController accountVerifyCodeLoggedOut];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
                    [EBAlert alertWithTitle:nil message:data[@"desc"] confirm:^
                     {
                         
                     }];
                }else{
                    [MBProgressHUD showSuccess:data[@"desc"]];
                }
            }
        }
        else
        {
            handler(NO, data);
//            [EBAlert alertError:data[@"desc"]];
            [EBAlert alertWithTitle:nil message:data[@"desc"] confirm:^
            {

            }];
        }
    }
}

#pragma mark -- 隐藏数据
- (void)handleDataWithOutWarn:(NSDictionary *)data withHandler:(void(^)(BOOL successful, NSDictionary *response))handler
{
    [EBAlert hideLoading];
    NSInteger errorCode = [data[@"code"] integerValue];
    if (errorCode == 0)
    {
        if (self == [EBHttpClient wapInstance]) {
            NSDictionary *update = data[@"mseUpdate"];
            
            if (update)
            {
                if (![EBUpdater hasUpdate]) {
                    [EBUpdater newVersionAvailable:update[@"version"] url:update[@"url"] force:[update[@"force"] boolValue]];
                }
            }
            else
            {
                [EBUpdater clearNewVersionReminder];
            }
        }
        
        NSDictionary *follow = data[@"follow"];
        if (follow)
        {
            if (![EBFollowLogAddView getShowState])
            {
                EBSetFollowLogType type;
                CGRect frame;
                if (follow[@"owner"])
                {
                    type = EBSetFollowLogForHouse;
                    frame = CGRectMake(0, 0, 270, 300);
                }
                else
                {
                    type = EBSetFollowLogForClient;
                    frame = CGRectMake(0, 0, 270, 280);
                }
                EBFollowLogAddView *alert = [EBFollowLogAddView sharedInstance];
                alert.follow = follow;
                alert.setFollowType = type;
                alert.curFrame = frame;
                alert.processType = EBProcessTypeBegin;
                [alert showSetFollowLogView:YES];
            }
        }
        
        id responseData = data[@"data"];
        handler(YES, responseData);
        if (responseData && [responseData isKindOfClass:[NSDictionary class]] && responseData[@"hint"])
        {
            id hintData = responseData[@"hint"];
            NSString *hint = @"";
            if ([hintData isKindOfClass:[NSArray class]])
            {
                hint = (NSString *)[(NSArray *)hintData firstObject];
            }
            else if ([hintData isKindOfClass:[NSString class]])
            {
                hint = (NSString *)hintData;
            }
            [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_RECEIVE_REMINDER object:hint]];
        }
    }
    else
    {
        if (errorCode == -411 || errorCode == -999)
        {
            if (errorCode == -411)
            {
                [EBController accountDataReset];
            }
            else if (errorCode == -999)
            {
                [EBController accountLoggedOut];
                NSLog(@"desc=%@",data[@"desc"]);
                [EBAlert alertWithTitle:nil message:data[@"desc"] confirm:^
                 {
                     
                 }];
            }
        }
        else
        {
            handler(NO, data);
            //            [EBAlert alertError:data[@"desc"]];
            
//            [EBAlert alertWithTitle:nil message:data[@"desc"] confirm:^
//             {
//                 
//             }];
        }
    }
}

#pragma mark -- 处理错误的请求
- (void)handleError:(NSError *)error withHandler:(void(^)(BOOL successful, NSDictionary *response))handler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [EBAlert hideLoading];
        handler(NO, @{@"code":@-9487, @"desc": error.description});
    });
    static dispatch_once_t flag;
    if (error && error.code == -1009)
    {
//        "network_error" = "无法连接网络";
        dispatch_once(&flag, ^{
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"network_error", nil) confirm:^
            {
                flag = NO;
            }];
        });
    }
//    "server_error" = "无法连接到服务器";
    else if(error&&error.code != -999)
    {
        dispatch_once(&flag, ^{
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"server_error", nil) confirm:^
             {
                 flag = NO;
             }];
        });
    }
}

#pragma mark -- 配置参数
- (NSDictionary *)wrappedParameters:(NSDictionary *)parameters
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    NSMutableDictionary *md = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    if (pref.token && [self isEqual:[EBHttpClient sharedInstance]])
    {
        md[@"token"] = pref.token;
    } else if (pref.wapToken && [self isEqual:[EBHttpClient wapInstance]]) {
        md[@"token"] = pref.wapToken;
    }
    
    NSLog(@"md - token  =%@", md[@"token"] );
    md[@"b_p"] = @"iphone";
    md[@"b_v"] = [EBUpdater localVersion];
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970]*1000)];
    md[@"eagle_time"] = timeSp;
    md[@"eagle_key"]  = [[EBController sharedInstance] getEagleKeyWithDate:timeSp];
    
    NSArray *encryptedArgs = @[@"passwd", @"password", @"old_password", @"new_password", @"account"];

    for (NSString *key in encryptedArgs)
    {
        if (md[key])
        {
            md[key] = [AESCrypt encryptStr:md[key]];
        }
    }

    return md;
}

- (AFHTTPRequestOperation *)ebGet:(NSString *)url parameters:(NSDictionary *)parameters handler:(void(^)(BOOL successful, NSDictionary *response))handler
{
    
    [self logUrl:url parameters:[self wrappedParameters:parameters]];
    
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return nil;
    }
    NSLog(@"url = %@",url);
    
    if (PORT == 0) {
        if ([[EBPreferences sharedInstance].companyCode isEqualToString:@"25758352"]||[[EBPreferences sharedInstance].companyCode isEqualToString:@"25821142"]) {
//            self.baseURL = [NSURL URLWithString:@"http://218.65.86.80:8119/"];
        }
    }
    
    NSLog(@"url1 = %@",url);
    return [self GET:url parameters:[self wrappedParameters:parameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        if ([response isKindOfClass:[NSData class]]) {
            response = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingMutableLeaves error:nil];
            
        }

        [self handleData:response withHandler:handler];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withHandler:handler];
    }];
}
+ (void)ebManagerGet:(NSString *)url parameters:(NSDictionary *)parameters handler:(void(^)(BOOL successful, NSDictionary *response))handler
{
  
    [[self sharedInstance] logUrl:url parameters:[[self sharedInstance] wrappedParameters:parameters]];
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
   
    if (manager.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [[self sharedInstance] handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return ;
    }
    
    [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        if ([response isKindOfClass:[NSData class]]) {
            response = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingMutableLeaves error:nil];
        }
        [[self sharedInstance] handleData:response withHandler:handler];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[self sharedInstance] handleError:error withHandler:handler];

    }];
}
- (AFHTTPRequestOperation *)ebGetWithOutWarn:(NSString *)url parameters:(NSDictionary *)parameters handler:(void(^)(BOOL successful, NSDictionary *response))handler
{
    [self logUrl:url parameters:[self wrappedParameters:parameters]];
    
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return nil;
    }
    
    return [self GET:url parameters:[self wrappedParameters:parameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        [self handleDataWithOutWarn:response withHandler:handler];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleError:error withHandler:handler];
    }];
}

#pragma mark -- post请求

- (AFHTTPRequestOperation *)ebPost:(NSString *)url parameters:(NSDictionary *)parameters handler:(void(^)(BOOL successful, NSDictionary *response))handler
{
    NSLog(@"parameters1=%@",parameters);
    [self logUrl:url parameters:[self wrappedParameters:parameters]];
    
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return nil;
    }
    
    return [self POST:url parameters:[self wrappedParameters:parameters]
       success:^(AFHTTPRequestOperation *operation, id responseObject)
       {
           NSDictionary *response = (NSDictionary *)responseObject;
           [self handleData:response withHandler:handler];
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           [self handleError:error withHandler:handler];
    }];
}

- (void)requestArray:(NSString *)url withParameters:(NSDictionary*)parameters arrayKey:(NSString *)arrayKey modelClass:(Class)cls
          handler:(THandlerBlock)handler
{
    
    [self ebGet:url parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        if (successful)
        {
            id value = response[arrayKey];

            NSMutableArray *result;
            if ([value isKindOfClass:[NSArray class]])
            {
                NSArray *array = value;
                result = [[NSMutableArray alloc] initWithCapacity:array.count];
                NSError *error = nil;
                for (NSDictionary *item in array)
                {
                    [result addObject:[MTLJSONAdapter modelOfClass:cls fromJSONDictionary:item error:&error]];
                }
            }
            else
            {
                result = [[NSMutableArray alloc] init];
            }

            handler(YES, result);
        }
        else
        {
            handler(NO, response);
        }
    }];
}

- (void)requestData:(NSString *)url withParameters:(NSDictionary*)parameters dataKey:(NSString *)dataKey modelClass:(Class)cls
          handler:(THandlerBlock)handler
{
    [self ebGet:url parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        if (successful)
        {
            NSError *error = nil;
            id result = [MTLJSONAdapter modelOfClass:cls fromJSONDictionary:response[dataKey] error:&error];

            handler(YES, result);
        }
        else
        {
            handler(NO, response);
        }
    }];
}

- (void)requestDataWithOutWarn:(NSString *)url withParameters:(NSDictionary*)parameters dataKey:(NSString *)dataKey modelClass:(Class)cls
            handler:(THandlerBlock)handler
{
    [self ebGetWithOutWarn:url parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         if (successful)
         {
             NSError *error = nil;
             id result = [MTLJSONAdapter modelOfClass:cls fromJSONDictionary:response[dataKey] error:&error];
             
             handler(YES, result);
         }
         else
         {
             handler(NO, response);
         }
     }];
}

#pragma mark -- 登录接口
- (void)accountRequest:(NSDictionary *)parameters login:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_LOGIN parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)accountRequest:(NSDictionary *)parameters logout:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_LOGOUT parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)accountRequest:(NSDictionary *)parameters checkUpdate:(THandlerBlock)handler
{
    [self ebGet:BEAVER_VERSION_UPDATE_CHECK parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)accountRequest:(NSDictionary *)parameters registerPushToken:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_REGISTER_PUSH_TOKEN parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}


- (void)houseRequest:(NSDictionary *)parameters updateCondition:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_UPDATE_SPECIAL_CONDITION parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters deleteCondition:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_DELETE_SPECIAL_CONDITION parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters setShareData:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_SET_SHARE_DATA parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters shareToWeibo:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_SHARE_TO_WEIBO parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

//房源查看电话号码
- (void)houseRequest:(NSDictionary *)parameters viewPhoneNumber:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_VIEW_PHONE_NUMBER parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}
#pragma mark -- 验证码
- (void)accountRequest:(NSDictionary *)parameters verifyCode:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_VERIFY_CODE parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)accountRequest:(NSDictionary *)parameters resendCode:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_RESEND_CODE parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)accountRequest:(NSDictionary *)parameters changePassword:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_CHANGE_PASSWORD parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
       handler(successful, response);
    }];
}

- (void)accountRequest:(NSDictionary *)parameters verifyAnonymousTel:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_VERIFY_ANONYMOUSTEL parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
         handler(successful, response);
    }];
}

- (void)accountRequest:(NSDictionary *)parameters changeCallNumber:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_CHANGE_CALLNUMBER parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

#pragma mark -- 同步数据
- (void)dataRequest:(NSDictionary *)parameters prefetch:(THandlerBlock)handler
{
    NSLog(@"parameters = %@",parameters);
    [self ebGet:BEAVER_DATA_PREFETCH parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)dataRequest:(NSDictionary *)parameters filter:(THandlerBlock)handler
{
    [self ebGet:BEAVER_DATA_FILTER parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)dataRequest:(NSDictionary *)parameters contacts:(THandlerBlock)handler
{
    [self ebGet:BEAVER_DATA_CONTACTS parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)dataRequest:(NSDictionary *)parameters uploadImage:(UIImage *)image withHandler:(THandlerBlock)handler
{
    [self dataRequest:parameters uploadImage:image withCompression:0.5 progress:nil handler:handler];
}

#pragma mark -- 上传图片
- (AFHTTPRequestOperation *)dataRequest:(NSDictionary *)parameters uploadImage:(UIImage *)image
    withCompression:(CGFloat)compression progress:(THandlerProgress)progressHandler handler:(THandlerBlock)handler
{
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return nil;
    }
    NSLog(@"first= %@",parameters);

   parameters = [self wrappedParameters:parameters];
    
    
//    #define BEAVER_DATA_GET_IMAGE_URI @"upload/imageUri"
   return [self ebGet:BEAVER_DATA_GET_IMAGE_URI parameters:nil handler:^(BOOL successful, NSDictionary *responseData)
    {
        
        if (successful){
            NSString *targetUrl = responseData[@"url"];
   
            NSLog(@"targetUrl=%@",targetUrl);
            NSLog(@"parameters=%@",parameters);
            
            NSData *imageData = UIImageJPEGRepresentation(image, compression);
#pragma mark -- 重点
            AFHTTPRequestOperation *uploadOperation =
                    [self POST:targetUrl parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
                    {
                    #pragma mark -- 重点
                        //将image转data
                        [formData appendPartWithFileData:imageData name:@"image_file" fileName:@"image_file.jpg" mimeType:@"image/jpeg"];
                    }
                    success:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                       NSDictionary *response = (NSDictionary *)responseObject;
                        NSLog(@"respone = %@",response);
                       [self handleData:response withHandler:handler];
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                       [self handleError:error withHandler:handler];
                    }];

            if (progressHandler)
            {
                __block AFHTTPRequestOperation *operation = uploadOperation;
                [uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long int totalBytesWritten, long long int totalBytesExpectedToWrite)
                {
                    progressHandler(operation, (CGFloat)totalBytesWritten / totalBytesExpectedToWrite);
                }];
            }
        }
    else
    {
        handler(NO, responseData);
    }
    }];
}

- (void)dataRequest:(NSDictionary *)parameters uploadAudio:(NSURL *)fileUrl withHandler:(THandlerBlock)handler
{
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return;
    }

    parameters = [self wrappedParameters:parameters];
    [self ebGet:BEAVER_DATA_GET_AUDIO_URI parameters:nil handler:^(BOOL successful, NSDictionary *responseData)
    {
        if (successful)
        {
            NSString *targetUrl = responseData[@"url"];
            [self POST:targetUrl
            parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
            {
                [formData appendPartWithFileURL:fileUrl name:@"audio_file" fileName:@"chat_audio.amr" mimeType:@"audio/amr" error:nil];
            }
               success:^(AFHTTPRequestOperation *operation, id responseObject)
               {
                   NSDictionary *response = (NSDictionary *)responseObject;
                   [self handleData:response withHandler:handler];
               }
               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   [self handleError:error withHandler:handler];
               }];
        }
        else
        {
            handler(NO, responseData);
        }
    }];
}

- (void)downloadFile:(NSString *)url to:(NSString *)filePath withProgress:(THandlerProgress)progressHandler handler:(THandlerBlock)handler
{
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return;
    }
    if (url == nil) {
        [EBAlert alertError:@"播放语音失败" length:2.0f];
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];

//    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
//    }];

    if (progressHandler)
    {
        __block AFHTTPRequestOperation *op = operation;
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long int totalBytesRead, long long int totalBytesExpectedToRead)
        {
            progressHandler(op , (CGFloat)totalBytesRead / totalBytesExpectedToRead);
        }];
    }

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *requestOperation, id responseObject) {
        NSError *error;
        [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];

        if (error)
        {
            handler(NO, @{@"error":error.description});
        }
        else
        {
            handler(YES, nil);
        }

    } failure:^(AFHTTPRequestOperation *requestOperation, NSError *error) {
        handler(NO, @{@"error":error.description});
    }];

    [self.operationQueue addOperation:operation];
}

- (void)downloadFile:(NSString *)url to:(NSString *)filePath withHandler:(THandlerBlock)handler
{
   [self downloadFile:url to:filePath withProgress:nil handler:handler];
}

- (void)codeRequest:(NSDictionary *)parameters what:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CODE_ACTION parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters specialCategory:(THandlerBlock)handler
{
    BOOL forceRefresh = [parameters[@"force_refresh"] boolValue];

    if (!forceRefresh)
    {
        NSArray *result = [[EBCache sharedInstance] specialCategories];
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                handler(YES, result);
            });

            return;
        }
    }

    [self requestArray:BEAVER_HOUSE_SPECIAL_CATEGORY withParameters:parameters arrayKey:@"categories"
            modelClass:[EBHouseCategory class] handler:^(BOOL success, NSArray *result){
//        handler(success, result);
        if (success)
        {
            [[EBCache sharedInstance] cacheSpecialCategory:result];
        }
        handler(success, result);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters recentViewed:(THandlerBlock)handler
{
    
    BOOL forceRefresh = [parameters[@"force_refresh"] boolValue];

    if (!forceRefresh && [parameters[@"page"] integerValue] == 1)
    {
        NSArray *result = [[EBCache sharedInstance] recentViewedHouses:1 pageSize:[parameters[@"page_size"] integerValue]];
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                handler(YES, result);
            });

            return;
        }
    }

    [self requestArray:BEAVER_HOUSE_RECENT_VIEWED withParameters:parameters arrayKey:@"houses"
            modelClass:[EBHouse class] handler:^(BOOL success, NSArray *result){
        handler(success, result);
        if (success && [parameters[@"page"] integerValue] == 1)
        {
            [[EBCache sharedInstance] cacheRecentViewedHouses:result];
        }
    }];
}

- (void)houseRequest:(NSDictionary *)parameters visitLogs:(THandlerBlock)handler
{
    [self requestArray:BEAVER_HOUSE_VISIT_LOG withParameters:parameters arrayKey:@"visit_logs"
            modelClass:[EBHouseVisitLog class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)houseRequest:(NSDictionary *)parameters collect:(THandlerBlock)handler
{
    [self requestArray:BEAVER_HOUSE_COLLECT withParameters:parameters arrayKey:@"houses"
            modelClass:[EBHouse class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)houseRequest:(NSDictionary *)parameters follow:(THandlerBlock)handler
{
    [self requestArray:BEAVER_HOUSE_FOLLOW withParameters:parameters arrayKey:@"follow"
            modelClass:[EBHouseFollowLog class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)houseRequest:(NSDictionary *)parameters filter:(THandlerBlock)handler
{
    NSLog(@"parameters=%@",parameters);
    [self requestArray:BEAVER_HOUSE_FILTER withParameters:parameters arrayKey:@"houses"
            modelClass:[EBHouse class] handler:handler];
}

- (void)houseRequest:(NSDictionary *)parameters detail:(THandlerBlock)handler
{
    BOOL forceRefresh = [parameters[@"force_refresh"] boolValue];

    if (!forceRefresh)
    {
        EBHouse *result = [[EBCache sharedInstance] houseDetail:parameters[@"id"] type:parameters[@"type"]];
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                handler(YES, result);
            });

            return;
        }
    }

    [self requestData:BEAVER_HOUSE_DETAIL withParameters:parameters dataKey:@"detail"
           modelClass:[EBHouse class] handler:^(BOOL success, id result){
        handler(success, result);
        if (success)
        {
            [[EBCache sharedInstance] cacheHouseDetail:result];
        }
    }];
}

- (void)houseRequestWithOutWarn:(NSDictionary *)parameters detail:(THandlerBlock)handler
{
    [self requestDataWithOutWarn:BEAVER_HOUSE_DETAIL withParameters:parameters dataKey:@"detail"
           modelClass:[EBHouse class] handler:^(BOOL success, id result){
               handler(success, result);
               if (success)
               {
                   [[EBCache sharedInstance] cacheHouseDetail:result];
               }
           }];
}

- (void)houseRequest:(NSDictionary *)parameters matchClients:(THandlerBlock)handler
{
    [self requestArray:BEAVER_HOUSE_MATCH withParameters:parameters arrayKey:@"clients"
            modelClass:[EBClient class] handler:handler];
}
- (void)houseRequest:(NSDictionary *)parameters markedClients:(THandlerBlock)handler
{
    [self requestArray:BEAVER_HOUSE_MARKED withParameters:parameters arrayKey:@"clients"
            modelClass:[EBClient class] handler:handler];
}

- (void)houseRequest:(NSDictionary *)parameters recommendedClients:(THandlerBlock)handler
{
    [self requestArray:BEAVER_HOUSE_RECOMMENDED withParameters:parameters arrayKey:@"clients"
            modelClass:[EBClient class] handler:handler];
}

- (void)houseRequest:(NSDictionary *)parameters collectState:(BOOL)state toggleCollect:(THandlerBlock)handler
{
    NSString *url = state ? BEAVER_HOUSE_DELETE_COLLECT : BEAVER_HOUSE_ADD_COLLECT;
    [self ebPost:url parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)houseAnonymousCallRequest:(NSDictionary *)parameters handler:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_ANONYMOUSCALL parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         if (successful)
         {
             NSMutableArray *result = [[NSMutableArray alloc] init];
             id value = response[@"result"];
             result = value;
             
             handler(YES, result);
         }
         else
         {
             handler(NO, response);
         }
     }];
}

- (void)houseRequest:(NSDictionary *)parameters appointmentHouse:(THandlerBlock)handler
{
    [self requestArray:BEAVER_HOUSE_APPONITMENT withParameters:parameters arrayKey:@"houses" modelClass:[EBHouse class] handler:^(BOOL success, id result) {
        handler(success, result);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters addFollow:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_ADD_FOLLOWLOG parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)houseRequest:(NSDictionary *)parameters houseValidate:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_ADD_VALIDATE parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)houseRequest:(NSDictionary *)parameters houseParameter:(THandlerBlock)handler
{
    [self ebGet:BEAVER_HOUSE_ADD_PARAMETER parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters houseSave:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_ADD_SAVE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters houseEdit:(THandlerBlock)handler
{
    [self ebGet:BEAVER_HOUSE_EDIT parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters houseUpdate:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_UPDATE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters changeStatus:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_CHANGE_STATUS parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)houseRequest:(NSDictionary *)parameters changeRecommendTag:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_CHANGE_RECOMMEND_TAG parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)houseRequest:(NSDictionary *)parameters report:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_REPORT parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)houseRequest:(NSDictionary *)parameters addPhoto:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_ADD_PHOTO parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters validStatus:(THandlerBlock)handler
{
    [self ebGet:BEAVER_HOUSE_VALID_STATUS parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)houseRequest:(NSDictionary *)parameters communityAssociate:(THandlerBlock)handler
{
    
    [self requestArray:BEAVER_HOUSE_COMMUNITY_ASSOCIATE withParameters:parameters arrayKey:@"communities"
            modelClass:[EBCommunity class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
//    [self ebGet:BEAVER_HOUSE_COMMUNITY_ASSOCIATE parameters:parameters handler:^(BOOL successful, NSDictionary *response)
//     {
//         if (successful)
//         {
//             id value = response[@"communities"];
//             
//             NSMutableArray *result;
//             if ([value isKindOfClass:[NSArray class]])
//             {
//                 NSArray *array = value;
//                 result = [[NSMutableArray alloc] initWithCapacity:array.count];
//                 for (NSDictionary *item in array)
//                 {
//                     [result addObject:item[@"community"]];
//                 }
//             }
//             else
//             {
//                 result = [[NSMutableArray alloc] init];
//             }
//             handler(YES, result);
//         }
//         else
//         {
//             handler(NO, response);
//         }
//     }];
}

- (void)houseRequest:(NSDictionary *)parameters addFiling:(THandlerBlock)handler
{
    [self ebPost:BEAVER_HOUSE_ADD_FILING parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)houseRequest:(NSDictionary *)parameters nhFollowList:(THandlerBlock)handler
{
    [self requestArray:BEAVER_HOUSE_NH_FOLLOW_LIST withParameters:parameters arrayKey:@"follows"
            modelClass:[EBNewHouseFollow class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters filter:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_FILTER withParameters:parameters arrayKey:@"clients"
            modelClass:[EBClient class] handler:handler];
}

- (void)clientRequest:(NSDictionary *)parameters recentViewed:(THandlerBlock)handler
{
    BOOL forceRefresh = [parameters[@"force_refresh"] boolValue];

    if (!forceRefresh && [parameters[@"page"] integerValue] == 1)
    {
        NSArray *result = [[EBCache sharedInstance] recentViewedClients:1 pageSize:[parameters[@"page_size"] integerValue]];
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                handler(YES, result);
            });

            return;
        }
    }

    [self requestArray:BEAVER_CLIENT_RECENT_VIEWED withParameters:parameters arrayKey:@"clients"
            modelClass:[EBClient class] handler:^(BOOL success, NSArray *result){
        handler(success, result);
        if (success && [parameters[@"page"] integerValue] == 1)
        {
            [[EBCache sharedInstance] cacheRecentViewedClients:result];
        }
    }];
}

- (void)clientRequest:(NSDictionary *)parameters visitLogs:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_VISIT_LOG withParameters:parameters arrayKey:@"visit_logs"
            modelClass:[EBClientVisitLog class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)clientRequest:(NSDictionary *)parameters collect:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_COLLECT withParameters:parameters arrayKey:@"clients"
            modelClass:[EBClient class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)clientRequest:(NSDictionary *)parameters appointHistory:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_APPOINTMENTHISTORY withParameters:parameters arrayKey:@"history"
            modelClass:[EBAppointment class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)clientRequest:(NSDictionary *)parameters follow:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_FOLLOW withParameters:parameters arrayKey:@"follow"
            modelClass:[EBClientFollowLog class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)clientRequest:(NSDictionary *)parameters listAppointment:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_LIST_APPOINTMENT withParameters:parameters arrayKey:@"appointments"
            modelClass:[EBAppointment class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)clientRequest:(NSDictionary *)parameters detail:(THandlerBlock)handler
{
    BOOL forceRefresh = [parameters[@"force_refresh"] boolValue];

    if (!forceRefresh)
    {
        EBClient *result = [[EBCache sharedInstance] clientDetail:parameters[@"id"] type:parameters[@"type"]];
        if (result)
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                handler(YES, result);
            });

            return;
        }
    }

    [self requestData:BEAVER_CLIENT_DETAIL withParameters:parameters dataKey:@"detail"
           modelClass:[EBClient class] handler:^(BOOL success, id result){
        handler(success, result);
        if (success)
        {
            [[EBCache sharedInstance] cacheClientDetail:result];
        }
    }];
}

- (void)clientRequest:(NSDictionary *)parameters matchHouses:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_MATCH withParameters:parameters arrayKey:@"houses"
            modelClass:[EBHouse class] handler:handler];
}

- (void)clientRequest:(NSDictionary *)parameters markedHouses:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_MARKED withParameters:parameters arrayKey:@"houses"
            modelClass:[EBHouse class] handler:handler];
}

- (void)clientRequest:(NSDictionary *)parameters recommendedHouses:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_RECOMMENDED withParameters:parameters arrayKey:@"houses"
            modelClass:[EBHouse class] handler:handler];
}

- (void)clientRequest:(NSDictionary *)parameters recommend:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_RECOMMEND_HOUSE parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters newAppointment:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_NEW_APPOINTMENT parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}
//客源查看电话号码
- (void)clientRequest:(NSDictionary *)parameters viewPhoneNumber:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_VIEW_PHONE_NUMBER parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters telList:(THandlerBlock)handler
{
    [self requestArray:BEAVER_CLIENT_TEL_LIST withParameters:parameters arrayKey:@"tel_list"
            modelClass:[EBClient class] handler:handler];
}

- (void)clientRequest:(NSDictionary *)parameters newVisitLog:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_ADD_VISIT_LOG parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters markState:(BOOL)state toggleMark:(THandlerBlock)handler
{
    NSString *url = state ? BEAVER_CLIENT_DELETE_MARK : BEAVER_CLIENT_ADD_MARK;
    [self ebPost:url parameters:parameters handler:^(BOOL successful, NSDictionary *response)
    {
       handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters collectState:(BOOL)state toggleCollect:(THandlerBlock)handler
{
    NSString *url = state ? BEAVER_CLIENT_DELETE_COLLECT : BEAVER_CLIENT_ADD_COLLECT;
    [self ebPost:url parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)clientAnonymousCallRequest:(NSDictionary *)parameters handler:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_ANONYMOUSCALL parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         if (successful)
         {
             NSMutableArray *result = [[NSMutableArray alloc] init];
             id value = response[@"result"];
             result = value;
             
//             if ([value isKindOfClass:[NSArray class]])
//             {
//                 NSArray *array = value;
//                 result = [[NSMutableArray alloc] initWithCapacity:array.count];
//                 NSError *error = nil;
//                 for (NSDictionary *item in array)
//                 {
//                     [result addObject:[MTLJSONAdapter modelOfClass:nil fromJSONDictionary:item error:&error]];
//                 }
//             }
//             else
//             {
//                 result = [[NSMutableArray alloc] init];
//             }
             handler(YES, result);
         }
         else
         {
             handler(NO, response);
         }
//         handler(successful, response);
     }];
}

- (void)clientRequest:(NSDictionary *)parameters addFollow:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_ADD_FOLLOWLOG parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)clientRequest:(NSDictionary *)parameters changeStatus:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_CHANGE_STATUS parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)clientRequest:(NSDictionary *)parameters changeRecommendTag:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_CHANGE_RECOMMEND_TAG parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)clientRequest:(NSDictionary *)parameters validStatus:(THandlerBlock)handler
{
    [self ebGet:BEAVER_CLIENT_VALID_STATUS parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters clientValidate:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_ADD_VALIDATE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters clientParameter:(THandlerBlock)handler
{
    [self ebGet:BEAVER_CLIENT_ADD_PARAMETER parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters clientSave:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_ADD_SAVE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters clientEdit:(THandlerBlock)handler
{
    [self ebGet:BEAVER_CLIENT_EIDT parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters clientUpdate:(THandlerBlock)handler
{
    [self ebPost:BEAVER_CLIENT_UPDATE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)clientRequest:(NSDictionary *)parameters chowDetail:(THandlerBlock)handler
{
    [self ebGet:BEAVER_CLIENT_CHOWDETAIL parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)accountRequest:(NSDictionary *)parameters getCallNum:(THandlerBlock)handler
{
//    [self requestArray:BEAVER_ACCOUNT_GET_CALLNUMBER withParameters:parameters arrayKey:@"number"
//            modelClass:nil handler:handler];
    [self ebGet:BEAVER_ACCOUNT_GET_CALLNUMBER parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         if (successful)
         {
             id value = response[@"number"];
             
             NSMutableArray *result = [[NSMutableArray alloc] init];
             [result addObject:(NSString *)value];
//             if ([value isKindOfClass:[NSArray class]])
//             {
//                 NSArray *array = value;
//                 result = [[NSMutableArray alloc] initWithCapacity:array.count];
//                 NSError *error = nil;
//                 for (NSDictionary *item in array)
//                 {
//                     [result addObject:[MTLJSONAdapter modelOfClass:nil fromJSONDictionary:item error:&error]];
//                 }
//             }
//             else
//             {
//                 result = [[NSMutableArray alloc] init];
//             }
//             
             handler(YES, result);
         }
         else
         {
             handler(NO, response);
         }
     }];
}

- (void)accountRequest:(NSDictionary *)parameters getNumberStatus:(THandlerBlock)handler
{
    [self requestData:BEAVER_ACCOUNT_GET_NUMBERSTATUS withParameters:parameters dataKey:@"status"
           modelClass:[EBNumberStatus class] handler:handler];
}

- (void)accountRequest:(NSDictionary *)parameters setNumber:(THandlerBlock)handler
{
    [self ebPost:BEAVER_ACCOUNT_SET_CALLNUMBER parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         if (successful)
         {
             NSDictionary *result;
             if ([response isKindOfClass:[NSDictionary class]])
             {
                 result = response;
             }
             else
             {
                 result = [[NSDictionary alloc] init];
             }
             handler(YES, result);
         }
     }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portAuthList:(THandlerBlock)handler
{
    [self ebGet:GATHER_PUBLISH_TRANSCEIVER_PORTAUTHLIST parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portAvailableList:(THandlerBlock)handler
{
    [self ebGet:GATHER_PUBLISH_TRANSCEIVER_PORTAVAILABLELIST parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portEditAuth:(THandlerBlock)handler
{
    [self ebGet:GATHER_PUBLISH_TRANSCEIVER_PORTEDITAUTH parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters houseList:(THandlerBlock)handler
{
    [self requestArray:BEAVER_TRANSCEIVER_HOUSE_LIST withParameters:parameters arrayKey:@"data"
            modelClass:[EBGatherHouse class] handler:handler];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters viewHouse:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_VIEW_HOUSE parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters subscriptionList:(THandlerBlock)handler
{
    [self requestArray:BEAVER_TRANSCEIVER_SUBSCRIPTION_LIST withParameters:parameters arrayKey:@"data"
            modelClass:[EBHouseCategory class] handler:handler];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters subscriptionEdit:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_SUBSCRIPTION_EDIT parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters subscriptionDelete:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_SUBSCRIPTION_DELETE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters subscriptionHouseList:(THandlerBlock)handler
{
    [self requestArray:BEAVER_TRANSCEIVER_SUBSCRIPTION_HOUSE_LIST withParameters:parameters arrayKey:@"data"
            modelClass:[EBGatherHouse class] handler:handler];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters bookmarkList:(THandlerBlock)handler
{
    [self requestArray:BEAVER_TRANSCEIVER_BOOKMARK_LIST withParameters:parameters arrayKey:@"data"
            modelClass:[EBGatherHouse class] handler:handler];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters toggleBookmark:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_TOGGLE_BOOKMARK parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters reportHouse:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_REPORT_HOUSE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portToggleVote:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_TOGGLE_VOTE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters getSetting:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_GET_SETTING parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters updateSetting:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_UPDATE_SETTING parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters getUnreadCount:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_UNREAD_COUNT parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portProposalList:(THandlerBlock)handler
{
    [self requestArray:BEAVER_TRANSCEIVER_PORT_PROPOSAL_LIST withParameters:parameters arrayKey:@"data"
            modelClass:[EBVote class] handler:^(BOOL success, NSArray *result){
                handler(success, result);
            }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portAddProposal:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_PORT_ADD_PROPOSAL parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters publishHouseEditor:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_PUBLISHHOUSEEDITOR parameters:parameters handler:^(BOOL successful, NSDictionary *response)
     {
         handler(successful, response);
     }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters publishTaskList:(THandlerBlock)handler
{
    [self ebGet:BEAVER_REANSCEIVER_PUBLISHTASKLIST parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portAuthStatus:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_PORTAUTHSTATUS parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portRefreshCaptcha:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_PORTREFRESHCAPTCHA parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters publishHouse:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_PUBLISHHOUSE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}


- (void)gatherPublishRequest:(NSDictionary *)parameters portCheckAuthStatus:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_PORTCHECKAUTHSTATUS parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portAuthStatusList:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_PORTAUTHSTATUSLIST parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters portDeleteAuth:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_PORTDELETEAUTH parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters republishHouse:(THandlerBlock)handler
{
    [self ebPost:BEAVER_TRANSCEIVER_REPUBLISHHOUSE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters deletePublishedHouse:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_DELETEPUBLISHEDHOUSE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters refreshPublishHouse:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_REFRESHPUBLISHHOUSE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)gatherPublishRequest:(NSDictionary *)parameters addPublishPhoto:(THandlerBlock)handler
{
    [self ebGet:BEAVER_TRANSCEIVER_ADDPUBLISHPHOTO parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)customerRequest:(NSDictionary *)parameters getSignature:(THandlerBlock)handler
{
    [self ebGet:BEAVER_CUSTOMER_GET_SIGNATURE parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}

- (void)customerRequest:(NSDictionary *)parameters mapRoomAudioUri:(THandlerBlock)handler
{
    [self ebGet:BEAVER_CUSTOMER_MAPROOMAUDIOURI parameters:parameters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful, response);
    }];
}


# pragma mark - wap
- (void)wapRequest:(NSDictionary *)paramters desktop:(THandlerBlock)handler
{
    [self ebGet:WAP_INDEX_DESKTOP parameters:paramters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful,response);
    }];
}
#pragma mark -- wap
- (void)wapRequest:(NSDictionary *)paramters foundList:(THandlerBlock)handler
{
    [self ebGet:WAP_INDEX_FOUNDLIST parameters:paramters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful,response);
    }];
}

- (void)wapRequest:(NSDictionary *)paramters checkUpdate:(THandlerBlock)handler
{
    NSLog(@"paramters=%@",paramters);
    [self ebGet:WAP_INDEX_CHECK_UPDATE parameters:paramters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful,response);
    }];
}
#pragma mark -- 地图获取所有的经纬度
- (void)wapRequest:(NSDictionary *)paramters nearbyList:(THandlerBlock)handler
{
    NSLog(@"paramters=%@",paramters);
    [self ebGet:WAP_INDEX_NEARBYLIST parameters:paramters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful,response);
    }];
}

- (void)wapRequest:(NSDictionary *)paramters qrcode:(THandlerBlock)handler
{
//    [self ebGet:WAP_INDEX_QRCODE parameters:paramters handler:^(BOOL successful, NSDictionary *response) {
//        handler(successful,response);
//    }];
    
    
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return ;
    }
    
    [self GET:WAP_INDEX_QRCODE parameters:[self wrappedParameters:paramters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = (NSDictionary *)responseObject;
        if ([response isKindOfClass:[NSData class]]) {
            response = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingMutableLeaves error:nil];
        }
        if ([response[@"code"] integerValue]== 0) {
            handler(YES,response[@"data"]);
        }else{
            if (response[@"desc"]) {
                handler(NO,response[@"desc"]);
            }

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(NO,nil);
    }];


    
}

- (void)wapRequest:(NSDictionary *)paramters shareToFound:(THandlerBlock)handler
{
    [self ebGet:WAP_INDEX_SHARETOFOUND parameters:paramters handler:^(BOOL successful, NSDictionary *response) {
        handler(successful,response);
    }];
}

- (void)wapRequest:(NSDictionary *)parameters uploadImage:(UIImage *)image withHandler:(THandlerBlock)handler
{
    [self wapRequest:parameters uploadImage:image withCompression:0.5 progress:nil handler:handler];
}

- (AFHTTPRequestOperation *)wapRequest:(NSDictionary *)parameters uploadImage:(UIImage *)image
                        withCompression:(CGFloat)compression progress:(THandlerProgress)progressHandler handler:(THandlerBlock)handler
{
    if (self.reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        [self handleError:[[NSError alloc] initWithDomain:@"network" code:-1009 userInfo:nil] withHandler:handler];
        return nil;
    }
    
    parameters = [self wrappedParameters:parameters];
    
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    return [self POST:WAP_INDEX_UPLOADIMAGE parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
            {
                [formData appendPartWithFileData:imageData name:@"image_file" fileName:@"image_file.jpg" mimeType:@"image/jpeg"];
            }
              success:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                NSDictionary *response = (NSDictionary *)responseObject;
                if ([response isKindOfClass:[NSData class]]) {
                    response = [NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingMutableLeaves error:nil];
                }
                [EBAlert hideLoading];
                [self handleData:response withHandler:handler];
            }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self handleError:error withHandler:handler];
              }];
}
//    return [self ebGet:WAP_INDEX_UPLOADIMAGE parameters:nil handler:^(BOOL successful, NSDictionary *responseData)
//            {
//                if (successful)
//                {
//                    NSString *targetUrl = responseData[@"url"];
//                    
//                    NSData *imageData = UIImageJPEGRepresentation(image, compression);
//                    AFHTTPRequestOperation *uploadOperation =
//                    [self POST:targetUrl parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
//                     {
//                         [formData appendPartWithFileData:imageData name:@"image_file" fileName:@"image_file.jpg" mimeType:@"image/jpeg"];
//                     }
//                       success:^(AFHTTPRequestOperation *operation, id responseObject)
//                     {
//                         NSDictionary *response = (NSDictionary *)responseObject;
//                         [self handleData:response withHandler:handler];
//                     }
//                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                           [self handleError:error withHandler:handler];
//                       }];
//                    
//                    if (progressHandler)
//                    {
//                        __block AFHTTPRequestOperation *operation = uploadOperation;
//                        [uploadOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long int totalBytesWritten, long long int totalBytesExpectedToWrite)
//                         {
//                             progressHandler(operation, (CGFloat)totalBytesWritten / totalBytesExpectedToWrite);
//                         }];
//                    }
//                }
//                else
//                {
//                    handler(NO, responseData);
//                }
//            }];
//}



@end
