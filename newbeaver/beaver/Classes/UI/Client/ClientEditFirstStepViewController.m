//
//  ClientEditFirstStepViewController.m
//  beaver
//
//  Created by LiuLian on 8/7/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "ClientEditFirstStepViewController.h"
#import "EBClient.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "EBController.h"

@interface ClientEditFirstStepViewController ()
{
    BOOL backAlert;
}
@end

@implementation ClientEditFirstStepViewController

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
    self.navigationItem.title = NSLocalizedString(@"client_edit_basic_title", nil);
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil) target:self action:@selector(endEdit)];
    
    NSString *type = self.clientDetail.rentalState == EClientRequireTypeRent ? @"rent" : @"sale";
    NSDictionary *params = @{@"client_id": self.clientDetail.id, @"type": type, @"chunk":[NSNumber numberWithInt:1]};
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [[EBHttpClient sharedInstance] clientRequest:params clientEdit:^(BOOL success, id result) {
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
    NSString *type = self.clientDetail.rentalState == EClientRequireTypeRent ? @"rent" : @"sale";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.clientDetail.id, @"client_id", type, @"type", [NSNumber numberWithInt:1], @"chunk", nil];
    params = [self setReqParams:params];
    if (!params) {
        return;
    }
    
    [self.currentElementView deSelect:nil];
    [EBAlert showLoading:nil];
    __weak ClientEditFirstStepViewController *weakSelf = self;
    [[EBHttpClient sharedInstance] clientRequest:params clientUpdate:^(BOOL success, id result) {
        ClientEditFirstStepViewController *strongSelf = weakSelf;
        [EBAlert hideLoading];
        if (success) {
            [[EBController sharedInstance] refreshClientDetailWhenEdited:strongSelf];
        } else {
            [EBAlert hideLoading];
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
