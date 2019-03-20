//
//  GatherHouseAddViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-29.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseAddViewController.h"
#import "EBHttpClient.h"
#import "EBRadioGroup.h"
#import "EBSelectView.h"
#import "EBInputView.h"
#import "HouseDataSource.h"
#import "MTLJSONAdapter.h"
#import "EBHouse.h"
#import "EBAlert.h"
#import "RegexKitLite.h"
#import "HouseClientExistViewController.h"
#import "GatherHouseAddSecondViewController.h"

@interface GatherHouseAddViewController ()

@end

@implementation GatherHouseAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.addType = 0;
    [super viewDidLoad];
    [self.nameInputView setValueOfView:_gatherHouse.owner_name];
    int i = 0;
    for (; i < self.wantRadioGroup.radios.count; i ++)
    {
        if(_gatherHouse.type == EGatherHouseRentalTypeSale)
        {
            if ([self.wantRadioGroup.radios[i][@"value"] isEqualToString:@"sale"]) {
                break;
            }
        }
        else if (_gatherHouse.type == EGatherHouseRentalTypeRent)
        {
            if ([self.wantRadioGroup.radios[i][@"value"] isEqualToString:@"rent"]) {
                break;
            }
        }
        else
        {
            if ([self.wantRadioGroup.radios[i][@"value"] isEqualToString:@"sale_rent"]) {
                break;
            }
        }
    }
    if (i < self.wantRadioGroup.radios.count)
    {
        [self.wantRadioGroup setSelectedIndex:i];
    }
    else
    {
        [self.wantRadioGroup setSelectedIndex:0];
    }
    [self.accessoryRadioGroup setSelectedIndex:0];
    if (_gatherHouse.tel_type != 3)
    {
        [self.telInputView setValueOfView:_gatherHouse.owner_tel];
    }
    self.navigationItem.title = NSLocalizedString(@"gather_house_add_erp_title", nil);
    [self setBackAlert:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - next step btn action
- (void)nextStep
{
    [super inputviewresignFirstResponder];
    if (![self.nameInputView valid]) {
        [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_5", nil)];
        return;
    }
    if (![self.nameSelectView checkEmpty]) {
        [EBAlert alertError:NSLocalizedString(@"need_add_name_code", nil)];
        return;
    }
    
    if (![self.telInputView valid]) {
        [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_0", nil)];
        return;
    }
    //    if (![self.telInputView matchRegex]) {
    //        [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
    //        return;
    //    }
    if (![[EBController sharedInstance] checkInputNum:[self.telInputView valueOfView]])
    {
        return;
    }
    
    NSDictionary *params = @{@"relate_house_id":_gatherHouse.id, @"purpose": self.purpose, @"type": self.wantNew[self.wantRadioGroup.selectedIndex][@"value"], @"access": self.wantNew[self.wantRadioGroup.selectedIndex][@"access"][self.accessoryRadioGroup.selectedIndex][@"value"], @"appellation": (self.nameSelectView ? [self.nameSelectView valueOfView] : @""), @"tel": [self.telInputView valueOfView], @"memo": (self.telSelectView ? [self.telSelectView valueOfView] : @""), @"agent_name": [self.nameInputView valueOfView]};
    
    [super nextStep];
    
    __weak GatherHouseAddViewController *weakSelf = self;
    [EBAlert showLoading:nil];
    [[EBHttpClient sharedInstance] houseRequest:params houseValidate:^(BOOL success, id result) {
        [EBAlert hideLoading];
        GatherHouseAddViewController *strongSelf = weakSelf;
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (!success) {
            return;
        }
        
        NSArray *tmparr = result[@"validate"][@"houses"];
        if (tmparr.count > 0) {
            HouseClientExistViewController *controller = [HouseClientExistViewController new];
            controller.data = result;
            controller.title = self.navigationItem.title;
            controller.goon = ^(void) {
                GatherHouseAddViewController *strongSelf = weakSelf;
                [strongSelf doNextStep:params];
            };
            [strongSelf.navigationController pushViewController:controller animated:YES];
        } else {
            NSNumber *number = (NSNumber*)result[@"validate"][@"can_continue"];
            BOOL canContinue = [number boolValue];
            //            BOOL canContinue = (BOOL)result[@"validate"][@"can_continue"];
            if (canContinue) {
                [strongSelf doNextStep:params];
            }
        }
    }];
}

- (void)doNextStep:(NSDictionary *)params
{
    GatherHouseAddSecondViewController *controller = [GatherHouseAddSecondViewController new];
    controller.params = [NSDictionary dictionaryWithDictionary:params];
    controller.gatherHouse = _gatherHouse;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
