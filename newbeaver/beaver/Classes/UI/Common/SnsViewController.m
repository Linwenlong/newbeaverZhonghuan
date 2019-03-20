//
//  RecommendViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBStyle.h"
#import "EBSnsDataSource.h"
#import "SnsViewController.h"
#import "EBIMConversation.h"
#import "EBIMManager.h"
#import "EBController.h"
#import "ChatViewController.h"
#import "EBHouse.h"
#import "ConversationViewController.h"
#import "EBAlert.h"
#import "EBShare.h"
#import "ShareConfig.h"
#import "SendShareViewController.h"
#import "EBFilter.h"
#import "ClientListViewController.h"
#import "ClientInviteViewController.h"
#import "PublishHouseViewController.h"
#import "MHTextField.h"
#import "EBHttpClient.h"

#import "EBController.h"

#import <MessageUI/MessageUI.h>
#import <UShareUI/UShareUI.h>

@interface SnsViewController ()<UITextFieldDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate>
{
    EBSnsDataSource *_snsDs;
    UICollectionView *_collectionView;
    UIScrollView * _ExtraView;
    MHTextField * _sendTF;
}

@end

@implementation SnsViewController

- (void)loadView{
    [super loadView];
//"spread" = "传播";
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, [EBStyle screenWidth] - 20, 20)];
    labelTitle.font = [UIFont boldSystemFontOfSize:18];
    labelTitle.textColor = [EBStyle blackTextColor];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.text = NSLocalizedString(@"spread", nil);
    [self.view addSubview:labelTitle];

    _snsDs = [[EBSnsDataSource alloc] init];
    
    NSMutableArray *choices = [[NSMutableArray alloc] initWithArray:[EBShare shareEntries:_shareItems.count == 1 ? NO : YES]];
    if (choices){
        if (_shareType == EBShareTypeNewHouse){
            [choices removeObject:@(EShareTypeworkmate)];
        }
    }
    
    _snsDs.choices = choices;
    NSInteger rows = choices.count / 4 + (choices.count % 4 ? 1 : 0);
    CGFloat collectionsViewHeight = 105.f * rows;

    _collectionView = [_snsDs setupCollectionViewWithFrame:CGRectMake(8.f, 65, self.view.frame.size.width - 16, collectionsViewHeight)
                                                                   cellSize:CGSizeMake(76, 105) direction:UICollectionViewScrollDirectionVertical];

    __block SnsViewController *snsViewController = self;
    //分享的block回调
    _snsDs.selectBlock = ^(NSInteger index)
    {
        [[EBController sharedInstance] dismissPopUpView:^(){
            if (snsViewController.shareType == EBShareTypeHouse || snsViewController.shareType == EBShareTypeNewHouse){
                NSInteger choice = [choices[index] integerValue];
                if (choice == 7)//同事
                {
                    [snsViewController shareViaIM];
                }
                else if (choice == 8)//客户
                {
                    [snsViewController shareToClients];
                }
                else if (choice == 9)//发布到端口
                {
                    [snsViewController shareToExtra];//lwl
//                    [snsViewController shareToPorts];
                }
//                else if (choice == 10)//发布到户外
//                {
//                    [snsViewController shareToExtra];
//                }//分享到第三方平台
                else
                {
                    [snsViewController shareViaManager:choice];
                }
            }
        }];
    };

    [self.view addSubview:_collectionView];

    self.view.frame = CGRectMake(0, 0, [EBStyle screenWidth], collectionsViewHeight + 65);
}

- (void)shareViaManager:(EShareType)shareType{
  
//    if (_isShowList == YES) {
//        [EBAlert alertError:@"暂时不支持列表分享房源到QQ、微信等,分享请点击进入详情分享" length:2.0f];
//        return;
//    }
    
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    content[@"key"] = [EBShare contentShareKey];
    NSLog(@"contentkey=%@",content[@"key"]);
    content[@"url"] = self.shareType == EBShareTypeHouse ? [EBShare contentShareUrl:content[@"key"]] : [EBShare contentShareNewHouseUrl:self.shareItems.firstObject];
    NSLog(@"contentkey = %@",content[@"key"]);
    NSLog(@"contenturl = %@",content[@"url"]);
    content[@"viewController"] = self;
    UMSocialPlatformType type;
    
    if (shareType == EShareTypeSinaWeibo)
    {
        
        
        UINavigationController *currentNav = [[EBController sharedInstance] currentNavigationController];

        content[@"text"] = self.shareType == EBShareTypeHouse ? [EBShare wbContentForHouses:self.shareItems] : [EBShare wbContentForNewHouse:self.shareItems.firstObject];
        type = UMSocialPlatformType_Sina;

        SendShareViewController *shareViewController = [[SendShareViewController alloc] init];
        shareViewController.content = content;
        shareViewController.shareType = shareType;
        shareViewController.CheckLabelHidden = _shareType == EBShareTypeNewHouse ? YES : NO;

        shareViewController.title = NSLocalizedString(@"sns_4", nil);

        shareViewController.shareHandler = ^(BOOL success, NSDictionary *info){
            if (success){
               [self setShareDataForShareKey:content[@"key"]];
               [currentNav popViewControllerAnimated:YES];
               self.shareHandler(YES, nil);
            }else{
               self.shareHandler(NO, info);
            }
        };
        [currentNav pushViewController:shareViewController animated:YES];
    }else{
        [self setShareDataForShareKey:content[@"key"]];
        if (shareType == EShareTypeWeChat){
            type = UMSocialPlatformType_WechatSession;
            if (self.shareType == EBShareTypeHouse)
            {
                content[@"image"] = [EBShare coverForHouses:self.shareItems];
                content[@"text"] = [EBShare wxContentForHouses:self.shareItems];
                NSLog(@"contentimage = %@",content[@"image"]);
                NSLog(@"contenttext = %@",content[@"text"]);
            }
            else if (self.shareType == EBShareTypeNewHouse)
            {
                content[@"image"] = [UIImage imageNamed:@"pl_house"];
                content[@"text"] = [EBShare wxContentForNewHouse:self.shareItems.firstObject];
                content[@"title"] = NSLocalizedString(@"share_new_house_title", nil);
            }
        }else if (shareType == EShareTypeWeChatFriend){
            type = UMSocialPlatformType_WechatTimeLine;
            if (self.shareType == EBShareTypeHouse)
            {
                content[@"image"] = [EBShare coverForHouses:self.shareItems];
                content[@"text"] = [EBShare wxFriendsContentForHouses:self.shareItems];
            }
            else if (self.shareType == EBShareTypeNewHouse)
            {
                content[@"image"] = [UIImage imageNamed:@"pl_house"];
                content[@"text"] = [EBShare wxFriendsContentForNewHouse:self.shareItems.firstObject];
                content[@"title"] = NSLocalizedString(@"share_new_house_title", nil);
            }
        }else if (shareType == EShareTypeQQ || shareType == EShareTypeQQZone){
            
            if (shareType == EShareTypeQQ) {
                type = UMSocialPlatformType_QQ;
            }else{
                type = UMSocialPlatformType_Qzone;
            }
            
            if (self.shareType == EBShareTypeHouse)
            {
                content[@"image"] = [EBShare coverForHouses:self.shareItems];
                content[@"text"] = [EBShare qqContentForHouses:self.shareItems];
            }
            else if (self.shareType == EBShareTypeNewHouse)
            {
                content[@"image"] = [UIImage imageNamed:@"pl_house"];
                content[@"text"] = [EBShare qqContentForNewHouse:self.shareItems.firstObject];
                content[@"title"] = NSLocalizedString(@"share_new_house_title", nil);
            }
        }
        else if (shareType == EShareTypeMessage)
        {
            type = UMSocialPlatformType_Sms;
            if (self.shareType == EBShareTypeHouse)
            {
                content[@"text"] = [EBShare smsContentForHouses:self.shareItems];
            }
            else if (self.shareType == EBShareTypeNewHouse)
            {
                content[@"text"] = [EBShare smsContentForNewHouse:self.shareItems.firstObject];
            }
        }else if (shareType == EShareTypeMail){
            type = UMSocialPlatformType_Email;
            if (self.shareType == EBShareTypeHouse)
            {
                content[@"text"] = [EBShare mailContentForHouses:self.shareItems withKey:content[@"key"]];
                content[@"title"] = [EBShare mailSubjectForHouses:self.shareItems];
            }
            else if (self.shareType == EBShareTypeNewHouse)
            {
                content[@"text"] = [EBShare mailContentForNewHouse:self.shareItems.firstObject];
                content[@"title"] = [EBShare mailSubjectForNewHouse:self.shareItems.firstObject];
            }
//            if (self.shareItems.count > 1)
//            {
                [content removeObjectForKey:@"url"];
//            }
        }
        
        if (shareType == EShareTypeSinaWeibo || shareType == EShareTypeWeChat || shareType == EShareTypeWeChatFriend || shareType == EShareTypeQQ || shareType == EShareTypeQQZone) {
            [self shareWebPageToPlatformType:type withShareConfig:content];
        }else if(shareType == EShareTypeMessage || shareType == EShareTypeMail){
            [self shareContent:content withType:shareType];
        }
    }
}

- (void)shareContent:(NSDictionary *)content withType:(EShareType)shareType {
    
    if (shareType == EShareTypeMessage) {
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

    }else{
    
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


// mail sms
#pragma -mark message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [[EBController sharedInstance].currentNavigationController dismissViewControllerAnimated:YES completion:^(){
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


#pragma mark -- 分享


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


//分享到第三方
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType withShareConfig:(NSDictionary*)shareConfig
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    NSString *title = @"";
    NSString *desc = @"";
    
    if (platformType == UMSocialPlatformType_WechatSession || platformType == UMSocialPlatformType_WechatTimeLine || platformType == UMSocialPlatformType_QQ || platformType == UMSocialPlatformType_Qzone) {
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


- (void)setShareDataForShareKey:(NSString *)key
{
    [EBShare setShareHouses:self.shareItems forKey:key];
}

- (void)shareToClients
{
    if (self.shareType == EBShareTypeHouse)
    {
        ClientListViewController *clientListViewController = [[EBController sharedInstance] showClientListWithType:EClientListTypeForShare
                                                                                                            filter:self.extraInfo
                                                                                                             title:NSLocalizedString(@"share_to_clients", nil)
                                                                                                             house:[self.shareItems firstObject]];
        
        NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
        content[@"key"] = [EBShare contentShareKey];
        content[@"url"] = [EBShare contentShareUrl:content[@"key"]];
        content[@"text"] = self.shareType == EBShareTypeHouse ? [EBShare smsContentForHouses:self.shareItems] : [EBShare smsContentForNewHouse:self.shareItems.firstObject];
        clientListViewController.userInfo = content;
        clientListViewController.houses = self.shareItems;
        
        [EBShare setShareHouses:self.shareItems forKey:content[@"key"]];
    }
    else if (self.shareType == EBShareTypeNewHouse)
    {
        NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
        content[@"text"] = [EBShare smsContentForNewHouse:_shareItems.firstObject];
        content[@"url"] = [EBShare contentShareNewHouseUrl:_shareItems.firstObject];
        ClientInviteViewController *viewController = [[ClientInviteViewController alloc] init];
        viewController.userInfo = content;
        viewController.viewType = EClientInviteViewTypeShareNewHouse;
        viewController.houseDetail = _shareItems.firstObject;
        [[EBController sharedInstance].currentNavigationController pushViewController:viewController animated:YES];
    }
}

- (void)shareViaIM
{
    UINavigationController *currentNav = [[EBController sharedInstance] currentNavigationController];
    ConversationViewController *viewController = [[ConversationViewController alloc] init];
    viewController.selectBlock = ^(EBIMConversation *conversation)
    {
        if (self.shareType == EBShareTypeHouse || self.shareType == EBShareTypeNewHouse)
        {
            NSMutableArray *messages = [[NSMutableArray alloc] init];
            for (EBHouse *house in self.shareItems)
            {
                EBIMMessage *message = [[EBIMMessage alloc] init];
                message.status = EMessageStatusSending;
                message.type = self.shareType == EBShareTypeHouse ? EMessageContentTypeHouse : EMessageContentTypeNewHouse;
                message.content = self.shareType == EBShareTypeHouse ? [EBIMMessage buildHouseContent:house] : [EBIMMessage buildNewHouseContent:house];
                message.to = conversation.objId;
                message.conversationType = conversation.type;
                [messages addObject:message];
            }

            [EBAlert showLoading:NSLocalizedString(@"loading_sending", nil)];
            [[EBIMManager sharedInstance] sendMessages:messages inConversation:conversation handler:^(BOOL success, NSDictionary *result)
            {
                [EBAlert hideLoading];
                if (success)
                {
                    self.shareHandler(success, result);
                }
            }];

            [EBTrack event:EVENT_CLICK_IM_SEND_HOUSE];
        }

        [currentNav popViewControllerAnimated:YES];
    };
    [currentNav pushViewController:viewController animated:YES];
}

- (void)shareToPorts
{
    [EBTrack event:EVENT_CLICK_HOUSE_SHARE_POST];
    if (!self.shareItems || self.shareItems.count == 0) {
        return;
    }
    EBHouse *house = self.shareItems[0];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *item in house.pictures) {
        [array addObject:item[@"image"]];
    }
//    NSString *type = house.rentalState == EHouseRentalTypeSale ? @"sale" : @"rent";
    NSDictionary *parmas = @{@"erp_house_id": house.id};
    
    UINavigationController *currentNav = [[EBController sharedInstance] currentNavigationController];
    PublishHouseViewController *viewController = [[PublishHouseViewController alloc] init];
    viewController.params = [NSMutableDictionary dictionaryWithDictionary:parmas];
    viewController.erp_photo_urls = [NSMutableArray arrayWithArray:array];
    viewController.showActionSheet = YES;
    [currentNav pushViewController:viewController animated:YES];
}


//分享到号外
- (void)shareToExtra
{
    UINavigationController *vc = [[EBController sharedInstance] currentNavigationController];
//    UIViewController *vc = currentNav.viewControllers.lastObject;
    
    _ExtraView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _ExtraView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [vc.view addSubview:_ExtraView];
    
    UIView *subView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 300, 210)];
    subView.backgroundColor = [UIColor colorWithRed:0xf7/255.f green:0xf6/255.f blue:0xf9/255.f alpha:1];
    [_ExtraView addSubview:subView];
    subView.layer.cornerRadius = 3;
    subView.layer.masksToBounds = YES;
    subView.center=CGPointMake(_ExtraView.width/2.0, _ExtraView.height/2.0 );
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, subView.width-20, 20)];
    titleLabel.text = @"分享到号外";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [subView addSubview:titleLabel];
    
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom +15, 50, 50)];
    iconImageView.image = [EBShare coverForHouses:self.shareItems];
    [subView addSubview:iconImageView];
    
    UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImageView.right + 10, iconImageView.top, subView.width - iconImageView.right - 10, iconImageView.height)];
    contentLabel.text = [EBShare wxContentForHouses:self.shareItems];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.numberOfLines = 0 ;
    contentLabel.adjustsFontSizeToFitWidth = YES;
    [subView addSubview:contentLabel];
    

    
    UIView *tfView = [[UIView alloc]initWithFrame:CGRectMake(iconImageView.left, iconImageView.bottom + 15, subView.width - iconImageView.left*2, 30)];
    tfView.layer.cornerRadius = 2;
    tfView.layer.masksToBounds = YES;
    tfView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tfView.layer.borderWidth = 0.5;
    [subView addSubview:tfView];
    
    _sendTF = [[MHTextField alloc]initWithFrame:CGRectMake(10, 5, tfView.width - 20, 20)];
    _sendTF.font = [UIFont systemFontOfSize:14];
    _sendTF.scrollView = _ExtraView;
    [tfView addSubview:_sendTF];
    
    
    UIButton *cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, tfView.bottom + 20, subView.width/2.0, 40)];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancleBtn addTarget:self action:@selector(cancaleBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [subView addSubview:cancleBtn];
    
    
    UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(subView.width/2.0, tfView.bottom + 20, subView.width/2.0, 40)];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[EBStyle greenTextColor] forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [sendBtn addTarget:self action:@selector(sendBtnOnClick) forControlEvents:UIControlEventTouchUpInside];

    [subView addSubview:sendBtn];
    
    UIView  *line = [[UIView alloc]initWithFrame:CGRectMake(0, cancleBtn.top-0.5, subView.width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [subView addSubview:line];
    
    UIView  *lineVertical = [[UIView alloc]initWithFrame:CGRectMake(subView.width/2.0, cancleBtn.top, 0.5, 50)];
    lineVertical.backgroundColor = [UIColor lightGrayColor];
    [subView addSubview:lineVertical];

}

- (void)cancaleBtnOnClick
{
    [_ExtraView removeFromSuperview];
}

- (void)sendBtnOnClick
{
    if ([_sendTF.text length]<1) {
        [EBAlert alertError:@"请输入留言内容"];
        return;
    }
    EBFilter *filer = (EBFilter *)self.extraInfo;

    for (NSInteger i =0 ; i<self.shareItems.count; i++) {
        EBHouse *houses = self.shareItems[i];
        NSDictionary *paramater = @{@"content":_sendTF.text,
                                    @"type":filer.houseType,
                                    @"house_id":houses.id,
                                    @"img_url":houses.cover,
                                    @"title":houses.title};
        [[EBHttpClient wapInstance] wapRequest:paramater shareToFound:^(BOOL success, id result) {
            if (success) {
                [_ExtraView removeFromSuperview];
                [EBAlert  alertSuccess:@"分享成功"];
            }
        }];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setShareItems:(NSArray *)shareItems
{
    _shareItems = shareItems;
    NSMutableArray *choices = [[NSMutableArray alloc] initWithArray:[EBShare shareEntries:_shareItems.count == 1 ? NO : YES]];
    if (choices)
    {
        if (_shareType == EBShareTypeNewHouse)
        {
            [choices removeObject:@(EShareTypeworkmate)];
            [choices removeObject:@(EShareTypePublishToPort)];
        }
    }
    
    NSInteger rows = choices.count / 4 + (choices.count % 4 ? 1 : 0);
    CGFloat collectionsViewHeight = 105.f * rows;
    
    _collectionView.frame = CGRectMake(8.f, 65, self.view.frame.size.width - 16, collectionsViewHeight);
    self.view.frame = CGRectMake(0, 0, [EBStyle screenWidth], collectionsViewHeight + 65);
    _snsDs.choices = choices;
}


@end
