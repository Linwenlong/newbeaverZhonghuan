//
//  RecommendViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "RecommendViewController.h"
#import "EBHouse.h"
#import "EBClient.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "EBSnsDataSource.h"
#import "RTLabel.h"
#import "EBController.h"
#import "EBHttpClient.h"
#import "EBFilter.h"
#import "ShareConfig.h"
#import "EBShare.h"
#import "UIImage+ImageWithColor.h"
#import "EBCache.h"
#import "EBAlert.h"
#import "EBClientVisitLog.h"

#import <MessageUI/MessageUI.h>
#import <UShareUI/UShareUI.h>

@interface RecommendViewController ()<MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate>
{
    EBSnsDataSource *_snsDs;
    UIButton *_currentButton;
    RTLabel *_firstLabel;
    RTLabel *_secondLabel;
    UILabel *_nameLabel;
    UILabel *_lastNameLabel;
}

@property (nonatomic) CGFloat yOffsetStart;

@end

@implementation RecommendViewController

- (void)loadView
{
    [super loadView];

    [self setupHeaderView];

    self.view.backgroundColor = [UIColor whiteColor];
    _firstLabel = [[RTLabel alloc] initWithFrame:CGRectMake(10, self.yOffsetStart, 300, 21)];
    _firstLabel.font = [UIFont systemFontOfSize:14];
    _firstLabel.textColor = [EBStyle blackTextColor];
    _firstLabel.text = [NSString stringWithFormat:NSLocalizedString(@"recommend_format", nil), _client.name];
    [self.view addSubview:_firstLabel];

    _secondLabel = [[RTLabel alloc] initWithFrame:CGRectMake(10, self.yOffsetStart + 115, 300, 50)];
    _secondLabel.font = [UIFont systemFontOfSize:14];
    _secondLabel.textColor = [EBStyle blackTextColor];
    _secondLabel.text = [NSString stringWithFormat:NSLocalizedString(@"recommend_hint_format", nil), _client.name];
    _secondLabel.tag = 2222;
    [self.view addSubview:_secondLabel];

    _snsDs = [[EBSnsDataSource alloc] init];

    NSArray *choices = [EBShare sendEntries];
    _snsDs.choices = choices;

    __block RecommendViewController *recommendViewController = self;
    _snsDs.selectBlock = ^(NSInteger choice)
    {
        EShareType shareType = [choices[choice] integerValue];
        [recommendViewController sendToClient:[recommendViewController getShareContent:shareType] withShareType:shareType];
    };

    UICollectionView *collectionView = [_snsDs setupCollectionViewWithFrame:CGRectMake(3.0f, self.yOffsetStart + 165,
            self.view.frame.size.width, 85) cellSize:CGSizeMake(74, 85) direction:UICollectionViewScrollDirectionHorizontal];

    [self.view addSubview:collectionView];

    self.view.frame = CGRectMake(0, 0, [EBStyle screenWidth], 358);
}

- (void)setupHeaderView
{
    UIButton *headerView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 78)];

    [headerView setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:228/255.0 green:238/255.0 blue:250/255.0 alpha:1.0]]
                          forState:UIControlStateHighlighted];

    _lastNameLabel = [EBViewFactory lastNameLabel];
    _lastNameLabel.text = [_client.name substringToIndex:1];
    _lastNameLabel.frame = CGRectOffset(_lastNameLabel.frame, 15, 15);
    [headerView addSubview:_lastNameLabel];

    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 17, 140, 18)];
    _nameLabel.textColor = [EBStyle blackTextColor];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    _nameLabel.text = _client.name;
    [headerView addSubview:_nameLabel];

    [headerView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:78 leftMargin:0]];

    UILabel *viewDetail = [[UILabel alloc] initWithFrame:CGRectMake(72, 40, 140, 18)];
    viewDetail.textColor = [EBStyle blackTextColor];
    viewDetail.font = [UIFont systemFontOfSize:14.0];
    viewDetail.text = NSLocalizedString(@"view_detail", nil);
    [headerView addSubview:viewDetail];

    [headerView addTarget:self action:@selector(viewDetail:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:headerView];
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


- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
    [image drawInRect:imageRect];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
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


- (void)sendToClient:(NSMutableDictionary *)content withShareType:(EShareType) shareType
{
    if(_tagHouseOrVisit == 0)
    {
        [EBShare setShareHouses:self.sendDataArray forKey:content[@"key"]];
    }
    else if(_tagHouseOrVisit == 1)
    {
        [EBShare setShareVisitLogs:self.sendDataArray forKey:content[@"key"] forCustomName:_client.name];
    }
    //分享
    [[EBController sharedInstance] dismissPopUpView:^(){
         [self shareViaManager:shareType content:content];
    }];
}

// mail sms
#pragma -mark message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [[EBController sharedInstance].currentNavigationController dismissViewControllerAnimated:YES completion:^(){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

#pragma -mark mail delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [[EBController sharedInstance].currentNavigationController dismissViewControllerAnimated:YES completion:^(){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}



- (NSMutableDictionary *)getShareContent:(EShareType)shareType
{
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    content[@"key"] = [EBShare contentShareKey];
    content[@"url"] = [EBShare contentShareUrl:content[@"key"]];

    if(_tagHouseOrVisit == 0)
    {
        if (shareType == EShareTypeWeChat)
        {
            content[@"image"] = [EBShare coverForHouses:self.sendDataArray];
            content[@"text"] = [EBShare wxContentForHouses:self.sendDataArray];
        }
        else if (shareType == EShareTypeQQ || shareType == EShareTypeQQZone)
        {
            content[@"image"] = [EBShare coverForHouses:self.sendDataArray];
            content[@"text"] = [EBShare qqContentForHouses:self.sendDataArray];
        }
        else if (shareType == EShareTypeMessage)
        {
            if (self.client.phoneNumbers.count)
            {
                content[@"to"] = self.client.phoneNumbers[0];
            }
            content[@"text"] = [EBShare smsContentForHouses:self.sendDataArray];
        }
        else if (shareType == EShareTypeMail)
        {
            content[@"text"] = [EBShare mailContentForHouses:self.sendDataArray withKey:content[@"key"]];
            //            if (recommendViewController.houses.count > 1)
            //            {
            [content removeObjectForKey:@"url"];
            //            }
        }
    }
    else if(_tagHouseOrVisit == 1)
    {
//        NSMutableArray *houseArray = [[NSMutableArray alloc] init];
//        for (int i = 0; i < [self.sendDataArray count]; i++) {
//            EBClientVisitLog *visitLog = (EBClientVisitLog*)self.sendDataArray[i];
//            [houseArray addObject:visitLog.house];
//        }
        if (shareType == EShareTypeWeChat)
        {
//            content[@"image"] = [EBShare coverForVisitLogs:_sendDataArray];
            content[@"image"] = [UIImage imageNamed:@"icon_visit"];
            content[@"text"] = [EBShare wxContentForVisitLogs:_sendDataArray client:self.client];
            content[@"title"] = NSLocalizedString(@"share_visitlogs", nil);
        }
        else if (shareType == EShareTypeQQ || shareType == EShareTypeQQZone)
        {
            content[@"image"] = [EBShare coverForVisitLogs:_sendDataArray];
            content[@"text"] = [EBShare qqContentForVisitLogs:_sendDataArray client:self.client];
            content[@"title"] = NSLocalizedString(@"share_visitlogs", nil);
        }
        else if (shareType == EShareTypeMessage)
        {
            if (self.client.phoneNumbers.count)
            {
                content[@"to"] = self.client.phoneNumbers[0];
            }
            content[@"text"] = [EBShare smsContentForVisitLogs:_sendDataArray client:self.client withKey:content[@"key"]];
            [content removeObjectForKey:@"url"];
        }
        else if (shareType == EShareTypeMail)
        {
            content[@"title"] = [EBShare mailTitleForVisitLogs];
            content[@"text"] = [EBShare mailContentForVisitLogs:_sendDataArray client:self.client withKey:content[@"key"]];
            //            if (recommendViewController.houses.count > 1)
            //            {
            [content removeObjectForKey:@"url"];
            //            }
        }
    }
    

    return content;
}

- (void)viewDetail:(UIButton *)btn
{
    [[EBController sharedInstance] dismissPopUpView:^(){
        [[EBController sharedInstance] showClientDetail:_client];
    }];
}

- (void)accessPhone:(UIButton *)btn
{
    if (_client.timesRemain == 0)
    {
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"view_phone_no_chance_help", nil)
                            yes:NSLocalizedString(@"yes_known", nil) confirm:^
        {

        }];
    }
    else
    {
        [[EBHttpClient sharedInstance] clientRequest:@{@"id":_client.id, @"type": [EBFilter typeString:_client.rentalState]}
                                     viewPhoneNumber:^(BOOL success, id result)
                                     {
                                         if (success)
                                         {
                                             NSDictionary *detail = result[@"detail"];
                                             _client.phoneNumbers = detail[@"phone_numbers"];
                                             [self showSmsButton];

                                             [[EBCache sharedInstance] cacheClientDetail:_client];
                                         }
                                     }];
    }
}

- (void)showSmsButton
{
    //bug 0001224 fixed by liulian 2014-07-15
    
//    [_currentButton removeFromSuperview];
//    _currentButton = [EBViewFactory smsPhoneNumberBtn:_client.phoneNumbers[0]];
//    _currentButton.frame = CGRectOffset(_currentButton.frame, 0, self.yOffsetStart + 20);
//    [_currentButton addTarget:self action:@selector(sms:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_currentButton];
    
    [_currentButton removeFromSuperview];
    for (int i = 0; i < _client.phoneNumbers.count; i++) {
        UIButton *phoneBtn = [EBViewFactory smsPhoneNumberBtn:_client.phoneNumbers[i]];
        phoneBtn.frame = CGRectOffset(phoneBtn.frame, 0, self.yOffsetStart + 20 + i*(phoneBtn.frame.size.height+8));
        [phoneBtn addTarget:self action:@selector(sms:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:phoneBtn];
        phoneBtn = nil;
    }
}

- (void)showAccessButton
{
    [_currentButton removeFromSuperview];
    _currentButton = [EBViewFactory accessPhoneNumberBtn:_client.timesRemain isHouse:NO];
    _currentButton.frame = CGRectOffset(_currentButton.frame, 0, self.yOffsetStart + 20);
    [_currentButton addTarget:self action:@selector(accessPhone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_currentButton];
}

- (void)setClient:(EBClient *)client
{
   [_currentButton removeFromSuperview];
   _client = client;

    dispatch_async(dispatch_get_main_queue(), ^
    {
       [self updateCurrentButton];
    });
}

- (void)updateCurrentButton
{
    _nameLabel.text = _client.name;
    _lastNameLabel.text = [_client.name substringToIndex:1];
    _firstLabel.text = [NSString stringWithFormat:NSLocalizedString(@"recommend_format", nil), _client.name];
    _secondLabel.text = [NSString stringWithFormat:NSLocalizedString(@"recommend_hint_format", nil), _client.name];
    if (_client.phoneNumbers.count > 0)
    {
        [self showSmsButton];
    }
    else if (_client.timesRemain > 0 || _client.timesRemain < 0)
    {
        [self showAccessButton];
    }
    else
    {
        [[EBHttpClient sharedInstance] clientRequest:@{@"type": [EBFilter typeString:_client.rentalState], @"id":_client.id}
                                              detail:^(BOOL success, id result)
                                              {
                                                  if (success)
                                                  {
                                                      _client = result;
                                                      if (_client.phoneNumbers.count > 0)
                                                      {
                                                          [self showSmsButton];
                                                      }
                                                      else
                                                      {
                                                          [self showAccessButton];
                                                      }
                                                  }
                                              }];
    }
}

- (void)recordRecommend
{
    NSMutableArray *houseIds = [[NSMutableArray alloc] init];
    for (EBHouse *house in _sendDataArray)
    {
        [houseIds addObject:house.id];
    }

    [[EBHttpClient sharedInstance] clientRequest:@{@"house_ids":[houseIds componentsJoinedByString:@";"],
            @"client_id":_client.id, @"type": [EBFilter typeString:_client.rentalState]}
                                       recommend:^(BOOL success, id result)
    {
        if (success)
        {
            _client.recommended = YES;
        }
    }];
}

- (void)sms:(UIButton *)btn
{
    [self sendToClient:[self getShareContent:EShareTypeMessage] withShareType:EShareTypeMessage];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _client = nil;
    _sendDataArray = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)yOffsetStart
{
    return 88;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
