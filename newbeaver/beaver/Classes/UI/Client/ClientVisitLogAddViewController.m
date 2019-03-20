//
//  ClientVisitLogAddViewController.m
//  beaver
//
//  Created by ChenYing on 14-7-21.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientVisitLogAddViewController.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "ClientInviteViewController.h"
#import "EBAlert.h"
#import "SZTextView.h"
#import "EBHttpClient.h"
#import "EBClient.h"
#import "EBAlert.h"
#import "EBCompatibility.h"
#import "EBNavigationController.h"
#import "MainTabViewController.h"
#import "EBMapService.h"
#import <CoreLocation/CoreLocation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "EBUtil.h"
#import "ERPWebViewController.h"
#define MAX_VISIT_LOG_TEXT_LENGTH 200

@interface ClientVisitLogAddViewController ()
{
    SZTextView *_visitLogTextView;
    UIButton *_addClientButton;
    NSArray *_selectedHouses;
    UIBarButtonItem *_commitButton;
    UILabel *_countLabel;
}

@end

@implementation ClientVisitLogAddViewController

- (void)loadView
{
    [super loadView];
    NSString *title = NSLocalizedString(@"add_visit_log", nil);
    self.navigationItem.title = title;
    
    _commitButton = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"commit", nil) target:self action:@selector(commitVisitLog:)];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.alwaysBounceVertical = YES;
    if ( [EBCompatibility isIOS7Higher])
    {
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    [self.view addSubview:scrollView];
    CGFloat height = 165.0;
    if ([EBStyle isUnder_iPhone5])
    {
        height = 135.0;
    }
    
    _visitLogTextView = [[SZTextView alloc] initWithFrame:CGRectMake(15.0, 15.0, [EBStyle screenWidth] -30, height)];
    _visitLogTextView.layer.borderWidth = 1.0;
    _visitLogTextView.layer.borderColor = [[EBStyle grayClickLineColor] CGColor];
    _visitLogTextView.textColor = [EBStyle blackTextColor];
    _visitLogTextView.font = [UIFont systemFontOfSize:16.0];
    _visitLogTextView.backgroundColor = [UIColor clearColor];
    _visitLogTextView.placeholder = NSLocalizedString(@"visit_log_placeholder", nil);
    _visitLogTextView.delegate = self;
    [scrollView addSubview:_visitLogTextView];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake([EBStyle screenWidth] - 46, height - 6, 30, 20)];
    _countLabel.text = [NSString stringWithFormat:@"%d",MAX_VISIT_LOG_TEXT_LENGTH];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textAlignment = NSTextAlignmentRight;
    _countLabel.font = [UIFont systemFontOfSize:16.0];
    _countLabel.textColor = [EBStyle grayTextColor];
    [scrollView addSubview:_countLabel];
    
    _addClientButton = [EBViewFactory blueButtonWithFrame:CGRectMake(15.0, _visitLogTextView.frame.origin.y + _visitLogTextView.frame.size.height + 15.0, [EBStyle screenWidth] - 30, 35.0) title:[NSString stringWithFormat:@"+ %@", NSLocalizedString(@"btn_add_visit_house", nil)] target:self action:@selector(addVisitHouse:)];
    [scrollView addSubview:_addClientButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self checkCommitButtonEnable];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_visitLogTextView becomeFirstResponder];
}

- (void)dealloc
{
    
}

- (BOOL)shouldPopOnBack
{
    if (_visitLogTextView.text.length > 0 || _selectedHouses.count > 0)
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"alert_save_visit_house", nil)
                              yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
         {
             [self.navigationController popViewControllerAnimated:YES];
         }];
    }
    else
    {
        return YES;
    }
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![EBCompatibility isIOS7Higher])
    {
        [_visitLogTextView resignFirstResponder];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length > 0)
    {
        if (_visitLogTextView.text.length >= MAX_VISIT_LOG_TEXT_LENGTH)
        {
            return NO;
        }
        else
        {
            NSString *log = [NSString stringWithFormat:@"%@%@",_visitLogTextView.text, text];
            if (log.length > MAX_VISIT_LOG_TEXT_LENGTH)
            {
                _visitLogTextView.text = [log substringToIndex:MAX_VISIT_LOG_TEXT_LENGTH];
                [self textViewDidChange:_visitLogTextView];
                return NO;
            }
            else
            {
                return YES;
            }
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView;
{
    _countLabel.text = [NSString stringWithFormat:@"%ld", MAX_VISIT_LOG_TEXT_LENGTH - _visitLogTextView.text.length];
    [self checkCommitButtonEnable];
}

#pragma mark - Action Method

- (void)commitVisitLog:(id)sender
{
    [_visitLogTextView resignFirstResponder];
    if (_selectedHouses && _selectedHouses.count > 0)
    {
        [EBAlert showLoading:nil allowUserInteraction:NO];
        __weak typeof(self) weakSelf = self;
        
        [[EBMapService sharedInstance] requestUserLocation:^(id location) {
            
            __strong typeof(self) strongSelf = weakSelf;
            
            if ([location isKindOfClass:[NSError class]]) {
                [EBAlert alertError:NSLocalizedString(@"location_fetch_error", nil)];
                return;
            }
            CLLocation *loc = [(MAUserLocation *)location location];
            
            CLLocationCoordinate2D coordinate = [EBUtil bd_encrypt:loc.coordinate];
            
            NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
            parameters[@"client_id"] = strongSelf->_clientDetail.id;
            parameters[@"type"] = strongSelf->_clientDetail.rentalState == EClientRequireTypeRent ? @"rent" : @"sale";
            parameters[@"house_id"] = [strongSelf getSelectedHousesIdsStr];
            parameters[@"content"] = strongSelf->_visitLogTextView.text;
            parameters[@"coordinate"] = [NSString stringWithFormat:@"%@,%@",[NSNumber numberWithDouble:coordinate.longitude],[NSNumber numberWithDouble:coordinate.latitude]];
            
            [[EBHttpClient sharedInstance] clientRequest:parameters newVisitLog:^(BOOL success, id result)
             {
                 if (success)
                 {
                     

                     
                     if (strongSelf.addVisitLogcompletion)
                     {
                         strongSelf.addVisitLogcompletion();
                     }
                     [EBAlert hideLoading:^(BOOL finished) {
                         [self.delegate openPage:result];
                         [strongSelf.navigationController popViewControllerAnimated:YES];

                     }];
                 }
                 else {
                     [EBAlert hideLoading];
                 }
             }];
            
        }superview:weakSelf.view];
    }
    else
    {
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"alert_add_visit_house", nil)];
    }
}

- (void)addVisitHouse:(id)sender
{
    ClientInviteViewController *viewController = [[ClientInviteViewController alloc] init];
    viewController.clientDetail = _clientDetail;
    viewController.hidesBottomBarWhenPushed = YES;
    viewController.viewType = EClientInviteViewTypeAddVisited;
    if (_selectedHouses)
    {
        viewController.preSelectedHouses = _selectedHouses;
    }
    viewController.handleCompleted = ^(NSArray *result)
    {
        if (result)
        {
            _selectedHouses = result;
            [_addClientButton setTitle:[NSString stringWithFormat:@"+ %@%@", NSLocalizedString(@"btn_add_visit_house", nil),_selectedHouses.count > 0 ?[NSString stringWithFormat:@"(%ld)",_selectedHouses.count] : @""] forState:UIControlStateNormal];
        }
        [self checkCommitButtonEnable];
        
    };
    
    EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:viewController];
    [[EBController sharedInstance].mainTabViewController presentViewController:naviController animated:YES completion:nil];
}

#pragma mark - Private Method

- (NSString *)getSelectedHousesIdsStr
{
    if (_selectedHouses && _selectedHouses.count > 0)
    {
        NSMutableString *housesIds = [[NSMutableString alloc] init];
        for (EBHouse *house in _selectedHouses)
        {
            [housesIds appendString:[NSString stringWithFormat:@"%@;",house.id]];
            
        }
//        return [housesIds substringToIndex:housesIds.length - 1];
        return housesIds;
    }
    return @"";
}

- (void)checkCommitButtonEnable
{
    if ([_visitLogTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0 && _selectedHouses && _selectedHouses.count > 0)
    {
        _commitButton.enabled = YES;
    }
    else
    {
        _commitButton.enabled = NO;
    }
}

@end
