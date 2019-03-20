//
//  HouseEditFirstStepViewController.m
//  beaver
//
//  Created by LiuLian on 8/7/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "HouseEditFirstStepViewController.h"
#import "EBHouse.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "EBCache.h"
#import "EBFilter.h"
#import "HouseDetailViewController.h"
#import "EBController.h"

@interface HouseEditFirstStepViewController ()
{
    BOOL backAlert;
}
@end

@implementation HouseEditFirstStepViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"house_edit_owner_title", nil);
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil) target:self action:@selector(endEdit)];
    
    NSString *type = self.house.rentalState == EHouseRentalTypeRent ? @"rent" : @"sale";
    NSDictionary *params = @{@"house_id": self.house.id, @"type": type, @"chunk":[NSNumber numberWithInt:1]};
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[EBHttpClient sharedInstance] houseRequest:params houseEdit:^(BOOL success, id result) {
        if (success) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            [self initParserContainer:result];
        } else {
            
        }
    }];
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

- (void)endEdit
{
    NSString *type = self.house.rentalState == EHouseRentalTypeRent ? @"rent" : @"sale";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.house.id, @"house_id", type, @"type", [NSNumber numberWithInt:1], @"chunk", nil];
    params = [self setReqParams:params];
    if (!params) {
        return;
    }
    
    [self.currentElementView deSelect:nil];
    [EBAlert showLoading:nil];
    __block HouseEditFirstStepViewController *weakSelf = self;
    [[EBHttpClient sharedInstance] houseRequest:params houseUpdate:^(BOOL success, id result) {
        if (success) {
            HouseEditFirstStepViewController *strongSelf = weakSelf;
            [[EBController sharedInstance] refreshHouseDetailWhenEdited:strongSelf];
//            [[EBHttpClient sharedInstance] houseRequest:@{@"id":strongSelf.house.id, @"force_refresh":@(YES),
//                                                          @"type":[EBFilter typeString:strongSelf.house.rentalState]}
//                                                 detail:^(BOOL success, id result){
//                 [EBAlert hideLoading];
//                 if (success)
//                 {
//                     strongSelf.house = result;
//                     [[EBCache sharedInstance] updateCacheByViewHouseDetail:strongSelf.house];
//                     id viewController = [self.navigationController.viewControllers objectAtIndex: ([self.navigationController.viewControllers count] -3)];
//                     if ([viewController isKindOfClass:[HouseDetailViewController class]])
//                     {
//                         HouseDetailViewController *temp = (HouseDetailViewController*)viewController;
//                         temp.houseDetail = result;
//                         dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
//                                        {
//                                            [self.navigationController popToViewController:temp animated:YES];
//                                        });
//                         
//                     }
//                 }
//                 [EBAlert alertSuccess:NSLocalizedString(@"house_edit_alert_text_success", nil)];
//                 [self.navigationController popViewControllerAnimated:YES];
//             }];
            
        } else {
            [EBAlert hideLoading];
            [EBAlert alertError:NSLocalizedString(@"house_edit_alert_text_failed", nil)];
        }
    }];
}

#pragma mark - ebelementview delegate
- (void)viewDidSelect:(EBElementView *)elementView
{
    backAlert = YES;
    
    [super viewDidSelect:elementView];
}

- (void)inputViewDidBeginEditing:(EBInputView *)inputView
{
    backAlert = YES;
    
    [super inputViewDidBeginEditing:inputView];
}

- (void)textareaViewDidBeginEditing:(EBTextareaView *)textareaView
{
    backAlert = YES;
    
    [super textareaViewDidBeginEditing:textareaView];
}

- (void)selectViewShouldShowOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSInteger)index
{
    backAlert = YES;
    
    [super selectViewShouldShowOptions:selectView options:options selectedIndex:index];
}

- (void)checkViewDidChanged:(EBCheckView *)checkView
{
    backAlert = YES;
    
    [super checkViewDidChanged:checkView];
}

#pragma mark - back popup
- (BOOL)shouldPopOnBack
{
    if (backAlert) {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"edit_giveup_alert", nil) yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return NO;
    }
    return YES;
}
@end
