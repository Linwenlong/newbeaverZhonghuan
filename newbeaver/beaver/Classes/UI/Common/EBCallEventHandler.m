//
// Created by 何 义 on 14-7-11.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBCallEventHandler.h"
#import "EBViewFactory.h"
#import "EBNumberStatus.h"
#import "EBAlert.h"
#import "EBHttpClient.h"
#import "RIButtonItem.h"
#import "UIActionSheet+Blocks.h"
#import "AnonymousCallViewController.h"
#import "EBController.h"

@implementation EBCallEventHandler

+(void)clickPhoneButton:(UIButton *)btn withParams:(NSDictionary *)params  numStatus:(EBNumberStatus *)numberStatus
            timesRemain:(NSInteger)timesRemain phoneNumbers:(NSArray *)phoneNumbers
                   type:(ECallEventType)type phoneGotHandler:(void(^)(BOOL success, id result))handler inView:(UIView *)view
{

    NSString *viewPhoneNumberUri = type == ECallEventTypeHouse ? BEAVER_HOUSE_VIEW_PHONE_NUMBER : BEAVER_CLIENT_VIEW_PHONE_NUMBER;
    if ((btn.tag == EBPhoneTypeEnableOtherCall) || (btn.tag == EBPhoneTypeEnableOwnCall))
    {
        if (type == ECallEventTypeHouse)
        {
            [EBTrack event:EVENT_CLICK_HOUSE_MARKED_ANONYMOUSE];
        }
        else
        {
            [EBTrack event:EVENT_CLICK_CLIENT_VIEW_ANONYMOUSE];
        }
        if (([numberStatus.anonymousNumber length] > 0) && numberStatus.canShowNumber)
        {
            dispatch_block_t alertCallOut = ^(){
                NSString *title = nil;
                if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                    if (title == nil) {
                        title = @"";
                    }
                }
                [[[UIAlertView alloc] initWithTitle:title
                                            message:NSLocalizedString(@"anonymous_call_end_title", nil)
                                           delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil] show];
            };

            dispatch_block_t callOut = ^(){
                [EBAlert showLoading:nil];
                NSString *anonymousCallUri = type == ECallEventTypeHouse ? BEAVER_HOUSE_ANONYMOUSCALL : BEAVER_CLIENT_ANONYMOUSCALL;
                [[EBHttpClient sharedInstance] ebPost:anonymousCallUri parameters:params handler:^(BOOL success, id result)
                {
                    [EBAlert hideLoading];
                    if (success)
                    {
                        NSArray *numbers = result[@"result"][@"numbers"];
                        if ([numbers count] <= 1)
                        {
                            alertCallOut();
                        }
                        else
                        {
                            NSInteger count = [numbers count];
                            NSMutableArray *buttons = [[NSMutableArray alloc] init];
                            for (int i = 0; i < count; i++)
                            {
                                NSDictionary *numAndType = [numbers objectAtIndex:i];
                                NSString *desc = [numAndType objectForKey:@"desc"];
                                NSString *index = [numAndType objectForKey:@"number_index"];

                                [buttons addObject:[RIButtonItem itemWithLabel:desc
                                                                        action:^
                                                                        {
                                                                            [EBAlert showLoading:nil];
                                                                            NSMutableDictionary *paramsNext = [NSMutableDictionary dictionaryWithDictionary:params];
                                                                            if (phoneNumbers && phoneNumbers.count > 1)
                                                                            {
                                                                                paramsNext[@"number"] = phoneNumbers[i];
                                                                            }
                                                                            else
                                                                            {
                                                                                paramsNext[@"number_index"] = index;
                                                                            }

                                                                            [[EBHttpClient sharedInstance] ebPost:anonymousCallUri parameters:paramsNext handler:^(BOOL success, id result)
                                                                            {
                                                                                [EBAlert hideLoading];
                                                                                if (success)
                                                                                {
                                                                                    alertCallOut();
                                                                                }
                                                                            }];
                                                                        }]];
                            }
                            [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"mutli_phone_title", nil) buttons:buttons] showInView:view];
                        }
                    }
                }];
            };

            NSString *titleFormat = NSLocalizedString(@"anonymous_confirm_phone", nil);

            NSMutableArray *alertButtons = [[NSMutableArray alloc] init];
            [alertButtons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"title_right", nil) action:^
            {
                callOut();
            }]];

            [alertButtons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"title_wrong", nil) action:^
            {
               [[EBController sharedInstance] promptChangeNumberInView:view withVerifySuccess:^(){
                   callOut();
               }];
            }]];

            [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:titleFormat,
                            numberStatus.anonymousNumber] buttons:alertButtons] showInView:view];
        }
        else
        {
            NSString *phoneNumber = numberStatus.anonymousNumber && numberStatus.anonymousNumber.length > 0 ? numberStatus.anonymousNumber : numberStatus.tel;
            [[EBController sharedInstance] showAnonymousCallWnd:^{} type:([numberStatus.anonymousNumber length] > 0 ? EAnonymousWait :EAnonymousUnstart)
                                                            num:phoneNumber];
        }
    }
    else if ((btn.tag == EBPhoneTypeDisableOther) || (btn.tag == EBPhoneTypeEnableOtherView))
    {
        if (timesRemain <= 0)
        {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"view_phone_no_chance_help", nil)
                                yes:NSLocalizedString(@"yes_known", nil) confirm:^{}];
        }
        else
        {
            [EBAlert showLoading:nil];
            [[EBHttpClient sharedInstance] ebPost:viewPhoneNumberUri parameters:params handler:handler];
        }
    }
    else if ((btn.tag == EBPhoneTypeDisableOwn) || (btn.tag == EBPhoneTypeEnableOwnView))
    {
        [EBAlert showLoading:nil];
        [[EBHttpClient sharedInstance] ebPost:viewPhoneNumberUri parameters:params handler:handler];
    }
}

@end