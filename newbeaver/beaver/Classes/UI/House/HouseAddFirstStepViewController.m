//
//  HouseAddFirstStepViewController.m
//  beaver
//
//  Created by LiuLian on 7/30/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "HouseAddFirstStepViewController.h"
#import "EBHttpClient.h"
#import "HouseAddSecondStepViewController.h"
#import "EBRadioGroup.h"
#import "EBSelectView.h"
#import "EBInputView.h"
#import "HouseDataSource.h"
#import "MTLJSONAdapter.h"
#import "EBHouse.h"
#import "EBAlert.h"
#import "RegexKitLite.h"
#import "HouseClientExistViewController.h"


@interface HouseAddFirstStepViewController ()
{
    
}
@end

@implementation HouseAddFirstStepViewController
@synthesize purpose;

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
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"%@-%@", NSLocalizedString(@"house", nil), self.purpose];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSDictionary *params = @{@"purpose": self.purpose, @"type": self.wantNew[self.wantRadioGroup.selectedIndex][@"value"], @"access": self.wantNew[self.wantRadioGroup.selectedIndex][@"access"][self.accessoryRadioGroup.selectedIndex][@"value"], @"appellation": (self.nameSelectView ? [self.nameSelectView valueOfView] : @""), @"tel": [self.telInputView valueOfView], @"memo": (self.telSelectView ? [self.telSelectView valueOfView] : @""), @"agent_name": [self.nameInputView valueOfView]};
    [super nextStep];
    __weak HouseAddFirstStepViewController *weakSelf = self;
    [EBAlert showLoading:nil];
    
    [[EBHttpClient sharedInstance] houseRequest:params houseValidate:^(BOOL success, id result) {
        [EBAlert hideLoading];
        HouseAddFirstStepViewController *strongSelf = weakSelf;
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
                HouseAddFirstStepViewController *strongSelf = weakSelf;
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

- (void)doNextStep:(NSDictionary *)params{
    HouseAddSecondStepViewController *controller = [HouseAddSecondStepViewController new];
    controller.inputDisks = self.inputDisks;
    controller.params = [NSDictionary dictionaryWithDictionary:params];
    controller.purpose = self.purpose;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
