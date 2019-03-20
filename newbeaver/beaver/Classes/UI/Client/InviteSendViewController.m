//
// Created by 何 义 on 14-5-28.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "InviteSendViewController.h"
#import "ShareConfig.h"
#import "EBShare.h"
#import "EBClient.h"
#import "ShareManager.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "EBAppointment.h"
#import "RTLabel.h"
#import "EBFilter.h"
#import "EBContactManager.h"
#import "EBContact.h"
#import "EBPreferences.h"
#import "EBController.h"
#import "ClientHisInviteViewController.h"

#import <MessageUI/MessageUI.h>
#import <UShareUI/UShareUI.h>

/**
 *  发送给客户，微信 ,qq,或者短信
 */

@interface InviteSendViewController ()<MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate>

@end

@implementation InviteSendViewController
{
    BOOL _appointmentUploaded;
    NSMutableDictionary *_shareContent;
    BOOL _sendNewInvite;
}


- (void)loadView{
    [super loadView];
    //邀请看房
    self.title = NSLocalizedString(@"invite_title", nil);
//    "invite_hint_format" = "如果您有<font>%@</font>其他的联系方式，请选择并发送邀请：";
    RTLabel *secondLabel = (RTLabel *)[self.view viewWithTag:2222];
    secondLabel.text = [NSString stringWithFormat:NSLocalizedString(@"invite_hint_format", nil), _appointment.client.name];
    _sendNewInvite = NO;
    UIImage *backImage = [UIImage imageNamed:@"icon_back"];
    UIBarButtonItem *buttonback =[[UIBarButtonItem alloc]initWithImage:backImage style:UIBarButtonItemStyleDone target:self action:@selector(leftBack)];
    self.navigationItem.leftBarButtonItem = buttonback;
}

//这里代码作怪
- (void) leftBack{
//    _sendNewInvite 修改这个就可以
    if (_sendNewInvite){
        NSArray *viewControllers = self.navigationController.viewControllers;
        UIViewController *popToViewController = nil;
        for (UIViewController *viewController in viewControllers){
            if ([viewController isKindOfClass:[ClientHisInviteViewController class]]){
                popToViewController = viewController;
                break;
            }      
        }
        if (popToViewController){
            ClientHisInviteViewController *viewController = (ClientHisInviteViewController*)popToViewController;
            viewController.appointArray = _appointArray;
            viewController.clientDetail = _appointment.client;
            dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2,dispatch_get_main_queue(), ^{
                               [self.navigationController popToViewController:viewController animated:YES];
            });
        }else{
            ClientHisInviteViewController *viewController = [[ClientHisInviteViewController alloc] init];
            viewController.appointArray = _appointArray;
            viewController.clientDetail = _appointment.client;
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupHeaderView
{

}

- (CGFloat)yOffsetStart
{
    return 15;
}


//分享到第三方
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType withShareConfig:(NSDictionary*)shareConfig
{
    NSLog(@"点击了分享按钮: %@",shareConfig);
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    NSString *title = @"";
    NSString *desc = @"";
    
    if (platformType == UMSocialPlatformType_WechatSession || platformType == UMSocialPlatformType_WechatTimeLine||platformType == UMSocialPlatformType_QQ || platformType == UMSocialPlatformType_Qzone) {
        if([shareConfig objectForKey:@"title"]){
            title = shareConfig[@"title"];
            desc = shareConfig[@"text"];
        }else{
            title = NSLocalizedString(@"share_house", nil);
            desc = shareConfig[@"text"];
        }
        
        if (platformType == UMSocialPlatformType_WechatTimeLine){
            title = shareConfig[@"text"];
        }
    }
    
    UIImage *img = [self resizeImage:shareConfig[@"image"] size:CGSizeMake(15, 15)];
    
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:img];
    
    //设置网页地址
    shareObject.webpageUrl =shareConfig[@"url"];
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    NSLog(@"self = %@",self);
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
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
        [self alertWithError:error];
    }];
}

- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
    [image drawInRect:imageRect];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}



- (void)alertWithError:(NSError *)error
{
    NSString *result = nil;
    if (!error) {
        //result = [NSString stringWithFormat:@"Share succeed"];  //原代码
        result = [NSString stringWithFormat:@"分享成功"];
    }
    else{
        NSMutableString *str = [NSMutableString string];
        if (error.userInfo) {
            for (NSString *key in error.userInfo) {
                [str appendFormat:@"%@ = %@\n", key, error.userInfo[key]];
            }
        }
        if (error) {
            //result = [NSString stringWithFormat:@"Share fail with error code: %d\n%@",(int)error.code, str];  //原代码
            
            //NSLog(@"分享出错信息: %@",error);
            if (error.code == 2009) {
                result = [NSString stringWithFormat:@"分享取消"];
            } else {
                result = [NSString stringWithFormat:@"Share fail with error code: %d\n%@",(int)error.code, str];
            }
        }
        else{
            result = [NSString stringWithFormat:@"Share fail"];
        }
    }
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"share" message:result delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"确定") otherButtonTitles:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:result delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
}


// mail sms
#pragma -mark message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [[EBController sharedInstance].currentNavigationController dismissViewControllerAnimated:YES completion:^(){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
//    if (!self.shareHandler) {
//        return;
//    }
//    if (result == MessageComposeResultSent)
//    {
//        self.shareHandler(YES, nil);
//    }
//    else
//    {
//        NSString *desc = result == MessageComposeResultCancelled ? @"canceled" : NSLocalizedString(@"send_fail", nil);
//        self.shareHandler(NO, @{@"desc":desc});
//    }
    
}

#pragma -mark mail delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [[EBController sharedInstance].currentNavigationController dismissViewControllerAnimated:YES completion:^(){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
//    if (!self.shareHandler) {
//        return;
//    }
//    if (result == MFMailComposeResultSent)
//    {
//        self.shareHandler(YES, nil);
//    }
//    else
//    {
//        NSString *desc = result == MFMailComposeResultCancelled ? @"canceled" : @"failed";
//        self.shareHandler(NO, @{@"desc":desc});
//    }
}




- (void)shareViaManager:(EShareType)shareType content:(NSDictionary *)content{
    if (shareType == EShareTypeWeChat || shareType == EShareTypeQQ){
        UMSocialPlatformType type;
        if (shareType == EShareTypeWeChat) {
            type = UMSocialPlatformType_WechatSession;
        }else{
            type = UMSocialPlatformType_QQ;
        }
        [self shareWebPageToPlatformType:type withShareConfig:content];
    }else if(shareType == EShareTypeMessage){
        MFMessageComposeViewController *  messageViewController = [[MFMessageComposeViewController alloc] init];
        messageViewController.messageComposeDelegate = self;
        if (content[@"text"])
        {
            if(content[@"url"])
            {
                messageViewController.body = [NSString stringWithFormat:@"%@ %@", content[@"text"], content[@"url"]];
            }
            else
            {
                messageViewController.body = [NSString stringWithFormat:@"%@", content[@"text"]];
            }
        }
        id to = content[@"to"];
        if (to)
        {
            if ([to isKindOfClass:[NSString class]])
            {
                messageViewController.recipients = @[to];
            }
            else if ([to isKindOfClass:[NSArray class]])
            {
                messageViewController.recipients = to;
            }
        }
        //        [viewController disableUserAttachments];
        messageViewController.delegate = self;
        //        viewController.recipients
        
        [[EBController sharedInstance].currentNavigationController presentViewController:messageViewController animated:YES completion:^(){
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            messageViewController.navigationBar.hidden = YES;
        }];

    }else if (shareType == EShareTypeMail){
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
    }
}

#pragma mark -- 无用的方法
- (void)sendToClient:(NSMutableDictionary *)content withShareType:(EShareType) shareType
{
    dispatch_block_t handler = ^{
        [self shareViaManager:shareType content:content];
    };

    if (!_appointmentUploaded)
    {
       [EBAlert showLoading:nil];

        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

        params[@"type"] = [EBFilter typeString:_appointment.client.rentalState];
        params[@"house_ids"] = [_appointment.houseIds componentsJoinedByString:@";"];
        params[@"client_id"] = _appointment.client.id;
        params[@"customer_name"] = _appointment.client.name;
        params[@"look_date"] = @(_appointment.timestamp);
        if (_appointment.latitude > 0)
        {
            params[@"longitude"] = @(_appointment.longitude);
            params[@"latitude"] = @(_appointment.latitude);
        }
        if(_appointment.addressDetail)
        {
            params[@"location"] = _appointment.addressDetail;
        }
        params[@"address"] = _appointment.addressTitle == nil ? @"" : _appointment.addressTitle;
        params[@"share_key"] = content[@"key"];
        EBContact *contact = [EBContactManager sharedInstance].myContact;
        params[@"user_name"] = contact.name;
        if (contact.phone)
        {
            params[@"user_tel"] = contact.phone;
        }
        params[@"gender"] = contact.gender;
        params[@"company_name"] = [EBPreferences sharedInstance].companyName;

       [[EBHttpClient sharedInstance] clientRequest:params newAppointment:^(BOOL success, id result)
       {
           [EBAlert hideLoading];
           if (success)
           {
               _sendNewInvite = YES;
               [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_INVITE_ADDED object:nil]];
               _appointmentUploaded = YES;
               handler();
               [self refreshAppoint];
           }
       }];
    }
    else
    {
        handler();
    }
}

- (NSMutableDictionary *)getShareContent:(EShareType)shareType
{
    if (_shareContent == nil)
    {
        _shareContent = [[NSMutableDictionary alloc] init];
        _shareContent[@"key"] = [EBShare contentShareKey];
        _shareContent[@"url"] = [EBShare contentShareUrl:_shareContent[@"key"]];
    }
    _shareContent[@"url"] = [EBShare contentShareUrl:_shareContent[@"key"]];

    _shareContent[@"image"] = [UIImage imageNamed:@"icon_invite"];
    if (shareType == EShareTypeWeChat)
    {
        _shareContent[@"text"] = [EBShare imContentForAppointment:_appointment];
        _shareContent[@"title"] = NSLocalizedString(@"send_invite", nil);
    }
    else if (shareType == EShareTypeQQ || shareType == EShareTypeQQZone)
    {
        _shareContent[@"text"] = [EBShare imContentForAppointment:_appointment];
        _shareContent[@"title"] = NSLocalizedString(@"send_invite", nil);
    }
    else if (shareType == EShareTypeMessage)
    {
        if (self.client.phoneNumbers.count)
        {
            _shareContent[@"to"] = self.client.phoneNumbers[0];
        }
        _shareContent[@"url"] = [EBShare contentShareUrl:_shareContent[@"key"]];
        _shareContent[@"text"] = [EBShare smsContentForAppointment:_appointment url:_shareContent[@"url"]];
        [_shareContent removeObjectForKey:@"url"];
    }
    else if (shareType == EShareTypeMail)
    {
        _shareContent[@"title"] = [EBShare mailTitleForAppointment:_appointment];
        _shareContent[@"text"] = [EBShare mailContentForAppointment:_appointment url:_shareContent[@"url"]];
        [_shareContent removeObjectForKey:@"url"];
    }

    return _shareContent;
}

- (void)refreshAppoint
{
    [[EBHttpClient sharedInstance] clientRequest:@{@"client_id":_appointment.client.id, @"force_refresh":@(YES)} appointHistory:^(BOOL success, id result){
         if (success){
             _appointArray = result;
         }
     }];
}

@end
