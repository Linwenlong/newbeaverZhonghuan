//
//  visitViewController.m
//  beaver
//
//  Created by wangyuliang on 14-5-30.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "VisitSendViewController.h"
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

@interface VisitSendViewController ()

@end

@implementation VisitSendViewController

- (void)loadView
{
    [super loadView];
}

- (void)sendToClient:(NSMutableDictionary *)content withShareType:(EShareType) shareType
{
    [EBShare setShareVisitLogs:self.houses forKey:content[@"key"]];
    
    
    [[EBController sharedInstance] dismissPopUpView:^(){
        [[ShareManager sharedInstance] shareContent:content withType:shareType handler:
         ^(BOOL success, NSDictionary *info){
             if (success)
             {
                 
             }
             self.completionHandler(success, info);
         }];
    }];
}

- (NSMutableDictionary *)getShareContent:(EShareType)shareType
{
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    content[@"key"] = [EBShare contentShareKey];
    content[@"url"] = [EBShare contentShareUrl:content[@"key"]];
    
    NSMutableArray *houseArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.houses count]; i++) {
        EBClientVisitLog *visitLog = (EBClientVisitLog*)self.clientVisitLog[i];
        [houseArray addObject:visitLog.house];
    }
    if (shareType == EShareTypeWeChat)
    {
        content[@"image"] = [EBShare coverForHouses:houseArray];
        content[@"text"] = [EBShare wxContentForHouses:houseArray];
    }
    else if (shareType == EShareTypeQQ)
    {
        content[@"image"] = [EBShare coverForHouses:houseArray];
        content[@"text"] = [EBShare qqContentForHouses:houseArray];
    }
    else if (shareType == EShareTypeMessage)
    {
        if (self.client.phoneNumbers.count)
        {
            content[@"to"] = self.client.phoneNumbers[0];
        }
        content[@"text"] = [EBShare smsContentForHouses:houseArray];
    }
    else if (shareType == EShareTypeMail)
    {
        content[@"text"] = [EBShare mailContentForHouses:houseArray withKey:content[@"key"]];
        //            if (recommendViewController.houses.count > 1)
        //            {
        [content removeObjectForKey:@"url"];
        //            }
    }
    
    return content;
}

@end
