//
//  ClientAddFirstStepViewController.m
//  beaver
//
//  Created by LiuLian on 7/31/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "ClientAddFirstStepViewController.h"
#import "EBInputView.h"
#import "EBSelectView.h"
#import "EBRadioGroup.h"
#import "EBHttpClient.h"
#import "ClientAddViewController.h"
#import "ClientDataSource.h"
#import "MTLJSONAdapter.h"
#import "EBClient.h"
#import "EBAlert.h"
#import "RegexKitLite.h"
#import "HouseClientExistViewController.h"

@interface ClientAddFirstStepViewController ()
{
    
}
@end

@implementation ClientAddFirstStepViewController

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
    self.addType = 1;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"%@-%@", NSLocalizedString(@"client", nil), self.purpose];
    
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

#pragma mark -
#pragma next step btn action
- (void)nextStep
{
//    [super nextStep];//!wyl
    [super inputviewresignFirstResponder];
    if (![self.nameInputView valid]) {
        [EBAlert alertError:NSLocalizedString(@"client_add_alert_text_1", nil)];
        return;
    }
    if (![self.nameSelectView checkEmpty]) {
        [EBAlert alertError:NSLocalizedString(@"need_add_name_code", nil)];
        return;
    }
    if (![self.telInputView valid]) {
        [EBAlert alertError:NSLocalizedString(@"client_add_alert_text_2", nil)];
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
    
    [EBAlert showLoading:nil];
    __weak ClientAddFirstStepViewController *weakSelf = self;
    [[EBHttpClient sharedInstance] clientRequest:params clientValidate:^(BOOL success, id result) {
        [EBAlert hideLoading];
        ClientAddFirstStepViewController *strongSelf = weakSelf;
        strongSelf.navigationItem.rightBarButtonItem.enabled = YES;
        
        if (!success) {
            return;
        }
        NSArray *tmparr = result[@"validate"][@"clients"];
        if (tmparr.count > 0) {
            HouseClientExistViewController *controller = [HouseClientExistViewController new];
            controller.data = result;
            controller.title = self.navigationItem.title;
            controller.clientFlag = YES;
            controller.goon = ^(void ) {
                ClientAddFirstStepViewController *strongSelf = weakSelf;
                [strongSelf doNextStep:params];
            };
            [strongSelf.navigationController pushViewController:controller animated:YES];
        } else {
//            BOOL canContinue = (BOOL)result[@"validate"][@"can_continue"];
            NSNumber *number = (NSNumber*)result[@"validate"][@"can_continue"];
            BOOL canContinue = [number boolValue];
            if (canContinue) {
                [strongSelf doNextStep:params];
            }
        }
    }];
}

- (void)doNextStep:(NSDictionary *)params
{
    ClientAddViewController *controller = [ClientAddViewController new];
    controller.params = [NSDictionary dictionaryWithDictionary:params];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
