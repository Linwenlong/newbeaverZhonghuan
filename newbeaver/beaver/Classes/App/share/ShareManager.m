//
//  ShareManager.m
//  ShareManagerExample
//
//

#import <MessageUI/MessageUI.h>
#import "TencentOpenAPI/QQApiInterface.h"
#import "TencentOpenAPI/TencentOAuth.h"
#import "ShareManager.h"
#import "EBController.h"
#import "MainTabViewController.h"
#import "EBHttpClient.h"
#import "SinaWeiboPreferences.h"
#import "WeiboApi.h"
#import "WeiboSDK.h"

#import <UShareUI/UShareUI.h>

@interface ShareManager()<MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate,UINavigationControllerDelegate,
                             WXApiDelegate, WeiboAuthDelegate,WeiboRequestDelegate,WeiboSDKDelegate,
                            WBHttpRequestDelegate, QQApiInterfaceDelegate, TencentSessionDelegate>

@property (nonatomic, copy) void(^shareHandler)(BOOL success, NSDictionary *info);
@property (nonatomic, copy) void(^loginHandler)(BOOL success, NSDictionary *info);
@property (nonatomic, strong) TencentOAuth *tencentOAuth;

@end

@implementation ShareManager

+ (ShareManager *) sharedInstance
{
    static ShareManager *_sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        //腾讯微博注册
//        _qqWeibo = [[WeiboApi alloc] initWithAppKey:kQQAppKey andSecret:kQQAppSecret andRedirectUri:kQQRedirectUri];
        [WeiboSDK registerApp:kSinaAppKey];
//        _sinaWeibo = [[SinaWeibo alloc] initWithAppKey:kSinaAppKey appSecret:kSinaSecret appRedirectURI:kSinaRedirectURI andDelegate:self];
        [WXApi registerApp:kWeChatAppId];
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:kQQAppId andDelegate:self];
    }
    return self;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    if ([url.absoluteString hasPrefix:[NSString stringWithFormat:@"wb%@",kSinaAppKey]])
    {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }


    return NO;
}

#pragma mark - weibo method

/**
 * @description 存储内容读取
 */
- (void)registerApp
{
    //向微信注册
    [WXApi registerApp:kWeChatAppId];
}

- (BOOL)isLogin:(EShareType)shareType
{
    if (EShareTypeSinaWeibo == shareType)
    {
        return [[SinaWeiboPreferences sharedInstance] isAuthValid];
    }
//    else if(EShareTypeQQWeibo == shareType)
//    {
//        return [_qqWeibo isAuthed];
//    }
    else
    {
        return YES;
    }
}

- (void)loginWithType:(EShareType)shareType  handler:(void(^)(BOOL success, NSDictionary *info))handler
{
    self.loginHandler = handler;

    if (EShareTypeSinaWeibo == shareType)
    {
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = kSinaRedirectURI;
        //        request.scope = @"all";
        [WeiboSDK sendRequest:request];
    }
//    else if(EShareTypeQQWeibo == shareType)
//    {
//        [_qqWeibo loginWithDelegate:self andRootController:[EBController sharedInstance].mainTabViewController];
//    }
    else
    {
        
    }
}

- (void)logOutWithType:(EShareType)shareType
{
    if (EShareTypeSinaWeibo == shareType)
    {
//        [_sinaWeibo logOut];
    }
//    else if(EShareTypeQQWeibo == shareType)
//    {
//        [_qqWeibo cancelAuth];
//    }
    else
    {
        
    }
}

//设置图片
- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
    [image drawInRect:imageRect];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType withShareConfig:(NSDictionary*)shareConfig
{
    NSLog(@"点击了分享按钮: %@",shareConfig);
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    NSString *title = @"";
    if (![shareConfig.allKeys containsObject:@"title"]) {
         title = @"分享房源";
    }else{
         title = shareConfig[@"title"];
    }
    NSString *desc = shareConfig[@"text"];
    NSString* thumbURL = [NSString stringWithFormat:@"%@",shareConfig[@"image"]];
    
    NSURL *url = [NSURL URLWithString:thumbURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [self resizeImage:[UIImage imageWithData:data scale:0.10] size:CGSizeMake(15, 15)];

    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:img];
    
    //设置网页地址
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@",shareConfig[@"url"]];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    NSLog(@"self = %@",self);
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:shareConfig[@"viewController"] completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
//        [self alertWithError:error];
    }];
}


- (void)shareContentWithReccmmond:(NSDictionary *)content withType:(EShareType)shareType{

    if (shareType == EShareTypeQQ) {
        UIImage *image = content[@"image"];
        QQApiNewsObject *newsObject;
        newsObject = [QQApiNewsObject objectWithURL:[[NSURL alloc] initWithString:content[@"url"]]
                                              title:content[@"title"]
                                        description:content[@"text"] previewImageData:UIImageJPEGRepresentation(image, 1)];
        
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObject];
        
        [QQApiInterface sendReq:req];
    }else if (shareType == EShareTypeWeChat){
        
            WXMediaMessage *message = [WXMediaMessage message];
            enum WXScene scene = shareType == EShareTypeWeChatFriend ? WXSceneTimeline : WXSceneSession;
            message.title = content[@"title"];
            message.description = content[@"text"];
            NSLog(@"title = %@",content[@"title"]);
            NSLog(@"description = %@",content[@"text"]);
            NSLog(@"image = %@",content[@"image"]);
            [message setThumbImage:content[@"image"]];
        
        
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = content[@"url"];
            message.mediaObject = ext;
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText =NO;
            req.message = message;
            req.scene = scene;
            req.scene = scene;
        
            [WXApi sendReq:req];
        }
}

- (void)sendContent:(NSDictionary *)content withType:(EShareType)shareType
{
    NSLog(@"content = %@",content);
    if (EShareTypeSinaWeibo == shareType)
    {
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                content[@"text"], @"status", nil];
//        NSString *api = @"statuses/update.json";
//        if (content[@"image"])
//        {
//            params[@"pic"] = content[@"image"];
//            api = @"statuses/upload.json";
//        }
//
//        [_sinaWeibo requestWithURL:api params:params httpMethod:@"POST" delegate:self];

        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        NSString *contentStr = content[@"text"];
        if (content[@"url"])
        {
            contentStr = [NSString stringWithFormat:@"%@ %@", contentStr, content[@"url"]];
        }
        params[@"content"] = contentStr;
        params[@"key"] = content[@"key"];
        params[@"weibo_token"] = [SinaWeiboPreferences sharedInstance].accessToken;
        params[@"weibo"] = @"sina";
        [[EBHttpClient sharedInstance] houseRequest:params shareToWeibo:^(BOOL success, id result)
        {
            if (self.shareHandler) {
                self.shareHandler(success, result);
            }
        }];

//        NSString *str = @"";

    }
    else if(EShareTypeWeChat == shareType || EShareTypeWeChatFriend == shareType)
    {
        
        [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession withShareConfig:content];
        
//        WXMediaMessage *message = [WXMediaMessage message];
//
//        enum WXScene scene = shareType == EShareTypeWeChatFriend ? WXSceneTimeline : WXSceneSession;
        
//        if([content objectForKey:@"title"]){
//            message.title = content[@"title"];
//            message.description = content[@"text"];
//        }else{
//            message.title = NSLocalizedString(@"share_house", nil);
//            message.description = content[@"text"];
//        }
//        if (EShareTypeWeChatFriend == shareType){
//            message.title = content[@"text"];
//        }
//        [message setThumbImage:content[@"image"]];
//        WXWebpageObject *ext = [WXWebpageObject object];
//        ext.webpageUrl = content[@"url"];
//        message.mediaObject = ext;
//        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//        req.bText = NO;
//        req.message = message;
//        req.scene = scene;
//
//        [WXApi sendReq:req];
    }else if (EShareTypeQQ == shareType || EShareTypeQQZone == shareType){
        UIImage *image = content[@"image"];

        QQApiNewsObject *newsObject;
        if([content objectForKey:@"title"])
        {
            newsObject = [QQApiNewsObject objectWithURL:[[NSURL alloc] initWithString:content[@"url"]]
                                                  title:content[@"title"]
                                            description:content[@"text"] previewImageData:UIImageJPEGRepresentation(image, 1)];
        }
        else
        {
            newsObject = [QQApiNewsObject objectWithURL:[[NSURL alloc] initWithString:content[@"url"]]
                                                  title:NSLocalizedString(@"share_house", nil)
                                            description:content[@"text"] previewImageData:UIImageJPEGRepresentation(image, 1)];
        }
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObject];
        if (EShareTypeQQZone == shareType ) {
            [QQApiInterface SendReqToQZone:req];
        }
        else{
            [QQApiInterface sendReq:req];
        }
    }
    else if(EShareTypeMessage == shareType)
    {
        MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
        viewController.messageComposeDelegate = self;
        if (content[@"text"])
        {
            if(content[@"url"])
            { 
                viewController.body = [NSString stringWithFormat:@"%@ %@", content[@"text"], content[@"url"]];
            }
            else
            {
                viewController.body = [NSString stringWithFormat:@"%@", content[@"text"]];
            }
        }
        id to = content[@"to"];
        if (to)
        {
            if ([to isKindOfClass:[NSString class]])
            {
                viewController.recipients = @[to];
            }
            else if ([to isKindOfClass:[NSArray class]])
            {
                viewController.recipients = to;
            }
        }
//        [viewController disableUserAttachments];
        viewController.delegate = self;
//        viewController.recipients
        
        [[EBController sharedInstance].currentNavigationController presentViewController:viewController animated:YES completion:^(){
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            viewController.navigationBar.hidden = YES;
        }];
    }
    else if (EShareTypeMail == shareType)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
            viewController.mailComposeDelegate = self;

            id to = content[@"to"];
            if (to)
            {
                if ([to isKindOfClass:[NSString class]])
                {
                    [viewController setToRecipients:@[to]];
                }
                else if ([to isKindOfClass:[NSArray class]])
                {
                    [viewController setToRecipients:to];
                }
            }

            if (content[@"url"])
            {
                [viewController setMessageBody:[NSString stringWithFormat:@"%@ %@", content[@"text"], content[@"url"]] isHTML:NO];
            }
            else
            {
                [viewController setMessageBody:content[@"text"] isHTML:NO];
            }

            [viewController setSubject:content[@"title"]];
            viewController.delegate = self;

            [[EBController sharedInstance].currentNavigationController presentViewController:viewController animated:YES completion:^(){
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
        }
        else
        {
            if (self.shareHandler) {
                self.shareHandler(NO, @{@"desc":@"cannot_send_mail"});
            }
        }
    }
}

- (void)shareContent:(NSDictionary *)content withType:(EShareType)shareType handler:(void(^)(BOOL success, NSDictionary *info))handler
{
    NSLog(@"content=%@",content);
    id loginHandler = ^(BOOL success, NSDictionary *loginInfo)
    {
        if (success)
        {
            [self sendContent:content withType:shareType];
        }
        else
        {
            if (loginInfo[@"isExpired"])
            {
               [self loginWithType:shareType handler:loginHandler];
            }
            else
            {
                handler(NO, loginInfo);
            }
        }
    };

    self.shareHandler = handler;
    if (![self isLogin:shareType])
    {
        [self loginWithType:shareType handler:loginHandler];
    }
    else
    {
        [self sendContent:content withType:shareType];
    }
}

#pragma mark - Sina WeiboSDKDelegate

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response;
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSInteger statusCode = response.statusCode;
        if (statusCode == WeiboSDKResponseStatusCodeSuccess) {
            SinaWeiboPreferences *pref = [SinaWeiboPreferences sharedInstance];
            pref.userID = [(WBAuthorizeResponse *)response userID];
            pref.accessToken = [(WBAuthorizeResponse *)response accessToken];
            pref.expirationDate = [(WBAuthorizeResponse *)response expirationDate];
            pref.refreshToken = [(WBAuthorizeResponse *)response refreshToken];
            [[SinaWeiboPreferences sharedInstance] writePreferences];
            if (self.loginHandler) {
                self.loginHandler(YES, nil);
            }
        }
        else if (statusCode == WeiboSDKResponseStatusCodeUserCancel){
            if (self.loginHandler) {
                self.loginHandler(NO, @{@"desc":@"login canceled"});
            }
        }
        else{
            if (self.loginHandler) {
                self.loginHandler(NO, @{@"desc":NSLocalizedString(@"auth_fail", nil)});
            }
        }
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

#pragma mark  -sinaWeibo request Delegate

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    if (!self.shareHandler) {
        return;
    }
    NSDictionary *info = (NSDictionary *)result;
    if (info[@"error"]){
        self.shareHandler(NO, @{@"desc":info[@"error"]});
    }
    else{
        self.shareHandler(YES, nil);
    }
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    if (self.shareHandler) {
        self.shareHandler(NO, @{@"desc":error.description});
    }
}

#pragma mark - qq weibo login Delegate

- (void)DidAuthFinished:(WeiboApi *)wbapi
{
    if (self.loginHandler) {
        self.loginHandler(YES, nil);
    }
}

- (void)DidAuthCanceled:(WeiboApi *)wbapi
{
    if (self.loginHandler) {
        self.loginHandler(NO, @{@"desc":@"login canceled"});
    }
}

- (void)DidAuthFailWithError:(NSError *)error
{
    if (self.loginHandler) {
        self.loginHandler(NO, @{@"desc":NSLocalizedString(@"auth_fail", nil)});
    }
}

#pragma - qq weibo request delegate

- (void)didReceiveRawData:(NSData *)data reqNo:(int)reqno
{
    if (self.shareHandler) {
        self.shareHandler(YES, nil);
    }
}

- (void)didFailWithError:(NSError *)error reqNo:(int)reqno
{
    if (self.shareHandler) {
        self.shareHandler(NO, @{@"desc":error.description});
    }
}


#pragma mark- wechat delegate and qq delegate

-(void) onReq:(id)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {

    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
//        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
//        [self onShowMediaMessage:temp.message];
    }
    
}

-(void)onResp:(id)resp
{
    if (!self.shareHandler) {
        return;
    }
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        BaseResp *wxResp = (BaseResp *)resp;
        if (wxResp.errCode == 0)
        {
            self.shareHandler(YES, nil);
        }
        else
        {
//            NSString *errorStr = wxResp.errStr ? wxResp.errStr : @"canceled";
            NSString *errorStr = wxResp.errStr ? wxResp.errStr : @"取消分享";
            self.shareHandler(NO, @{@"desc":errorStr});
        }
    }
    else if ([resp isKindOfClass:[SendMessageToQQResp class]])
    {
        QQBaseResp *qqResp = (QQBaseResp *)resp;
        if (qqResp.errorDescription == nil || qqResp.errorDescription.length == 0)
        {
            self.shareHandler(YES, nil);
        }
        else
        {
            self.shareHandler(NO, @{@"desc":@"取消分享"});
            
//            self.shareHandler(NO, @{@"desc":qqResp.errorDescription});
        }
    }

}

// mail sms
#pragma -mark message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [[EBController sharedInstance].mainTabViewController dismissViewControllerAnimated:YES completion:^(){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    if (!self.shareHandler) {
        return;
    }
    if (result == MessageComposeResultSent)
    {
        self.shareHandler(YES, nil);
    }
    else
    {
        NSString *desc = result == MessageComposeResultCancelled ? @"canceled" : NSLocalizedString(@"send_fail", nil);
        self.shareHandler(NO, @{@"desc":desc});
    }
}

#pragma -mark mail delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [[EBController sharedInstance].currentNavigationController dismissViewControllerAnimated:YES completion:^(){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    if (!self.shareHandler) {
        return;
    }
    if (result == MFMailComposeResultSent)
    {
        self.shareHandler(YES, nil);
    }
    else
    {
        NSString *desc = result == MFMailComposeResultCancelled ? @"canceled" : @"failed";
        self.shareHandler(NO, @{@"desc":desc});
    }
}

//#pragma -mark UINavigationControllerDelegate
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
//            initWithTitle:@" "
//                    style:UIBarButtonItemStyleBordered
//                   target:nil
//                   action:nil];
//}

@end
