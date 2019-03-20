//
//  AddFollowLogViewController.m
//  beaver
//
//  Created by wangyuliang on 14-7-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "AddFollowLogViewController.h"
#import "EBIconLabel.h"
#import "EBController.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "SZTextView.h"
#import "EBMapService.h"
#import <CoreLocation/CoreLocation.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "EBUtil.h"

@interface AddFollowLogViewController () <UIScrollViewDelegate, UITextViewDelegate>
{
    SZTextView *_followLogText;
    UIBarButtonItem *_rightButtonItem;
    UILabel *_iconLabel;
    NSInteger _followWayChoice;
}

@end

@implementation AddFollowLogViewController

- (void)loadView
{
    [super loadView];
    _followWayChoice = -1;
    
    self.navigationItem.title = NSLocalizedString(@"followlog_add_title", nil);
    _rightButtonItem = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"followlog_commit", nil) target:self action:@selector(commitFollowLog:)];
    _rightButtonItem.enabled = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15.0, 10, [EBStyle screenWidth] - 30, 50)];
    UILabel *clause = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width, btn.frame.size.height)];
    clause.textAlignment = NSTextAlignmentLeft;
    clause.font = [UIFont systemFontOfSize:14.0];
    clause.textColor = [EBStyle blackTextColor];
    clause.text = NSLocalizedString(@"followlog_way_title", nil);
    [btn addSubview:clause];
    
    [btn addTarget:self action:@selector(chooseFollowWay:) forControlEvents:UIControlEventTouchUpInside];
//    UIView *iconView = [[UIView alloc] initWithFrame:btn.frame];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_accessory"]];
    imageView.frame = CGRectOffset(imageView.frame, btn.frame.size.width - imageView.frame.size.width, (btn.frame.size.height - imageView.frame.size.height) / 2);
    _iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width - imageView.frame.size.width - 5, btn.frame.size.height)];
    _iconLabel.textAlignment = NSTextAlignmentRight;
    _iconLabel.font = [UIFont systemFontOfSize:14.0];
    _iconLabel.textColor = [EBStyle grayTextColor];
    [self setWayText];
    [btn addSubview:imageView];
    [btn addSubview:_iconLabel];
    [scrollView addSubview:btn];
    
    _followLogText = [[SZTextView alloc] initWithFrame:CGRectMake(15.0, 60.0, [EBStyle screenWidth] - 30, 150.0)];
//    [_followLogText.layer setCornerRadius:6.0];
    _followLogText.layer.borderWidth = 1.0;
    _followLogText.layer.borderColor = [[EBStyle grayClickLineColor] CGColor];
    _followLogText.textColor = [EBStyle blackTextColor];
    _followLogText.font = [UIFont systemFontOfSize:14.0];
    _followLogText.placeholderTextColor = [UIColor lightGrayColor];
    _followLogText.placeholder = NSLocalizedString(@"followlog_placeholder", nil);
    _followLogText.delegate = self;
    [scrollView addSubview:_followLogText];
}

- (void)dealloc
{
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [_followLogText resignFirstResponder];
}

- (void)chooseFollowWay:(UIButton*)btn
{
    [_followLogText resignFirstResponder];
    NSArray *choices;
    EBBusinessConfig *config = [[EBCache sharedInstance] businessConfig];
    NSDictionary *followDic = nil;
    if (_isHouse)
    {
        followDic = config.houseConfig.followTypes;
        if (_house.rentalState == EHouseRentalTypeRent)
        {
            choices = followDic[@"rent"];
        }
        else
        {
            choices = followDic[@"sale"];
        }
    }
    else
    {
        followDic = config.clientConfig.followTypes;
        if (_client.rentalState == EClientRequireTypeRent)
        {
            choices = followDic[@"rent"];
        }
        else
        {
            choices = followDic[@"sale"];
        }
    }
    
    [[EBController sharedInstance] promptChoices:choices withChoice:_followWayChoice title:NSLocalizedString(@"followlog_way_add_warn", nil)
                                          header:nil
                                          footer:nil completion:^(NSInteger rightChoice)
     {
         _iconLabel.text = choices[rightChoice];
         _followWayChoice = rightChoice;
     }];
}

- (void)setWayText
{
    _iconLabel.text = NSLocalizedString(@"followlog_way_add_please", nil);
}

- (void)commitFollowLog:(id)sender
{
    [_followLogText resignFirstResponder];
    [self addFollowLogNote];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addFollowLogNote
{
    if (_followWayChoice < 0){
        [EBAlert alertError:NSLocalizedString(@"followlog_way_add_warn", nil) length:2.0];
        return;
    }
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
        parameters[@"coordinate"] = [NSString stringWithFormat:@"%@,%@",[NSNumber numberWithDouble:coordinate.longitude  ],[NSNumber numberWithDouble:coordinate.latitude  ]];
   

        if (strongSelf->_isHouse)
        {
            parameters[@"house_id"] = strongSelf->_house.id;
            parameters[@"way"] = strongSelf->_iconLabel.text;
            if (strongSelf->_house.rentalState == EHouseRentalTypeRent)
            {
                parameters[@"type"] = @"rent";
            }
            else
            {
                parameters[@"type"] = @"sale";
            }
            parameters[@"content"] = strongSelf->_followLogText.text;
            [[EBHttpClient sharedInstance] houseRequest:parameters addFollow:^(BOOL success, id result){
                [EBAlert hideLoading];
                if (success)
                {
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                    if (strongSelf->_complete)
                    {
                        strongSelf.complete();
                    }
                }
            }];
        }
        else
        {
            parameters[@"client_id"] = strongSelf->_client.id;
            parameters[@"way"] = strongSelf->_iconLabel.text;
            if (strongSelf->_client.rentalState == EClientRequireTypeRent)
            {
                parameters[@"type"] = @"rent";
            }
            else
            {
                parameters[@"type"] = @"sale";
            }
            parameters[@"content"] = strongSelf->_followLogText.text;
            [[EBHttpClient sharedInstance] clientRequest:parameters addFollow:^(BOOL success, id result){
                [EBAlert hideLoading];
                if (success)
                {
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                    if (strongSelf->_complete)
                    {
                        strongSelf.complete();
                    }
                }
            }];
        }
        
    } superview:weakSelf.view];
    
}

- (BOOL)shouldPopOnBack
{
    if (_followWayChoice >= 0 || _followLogText.text.length > 0)
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"edit_give_up_warn", nil)
                              yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
         {
             
             [self.navigationController popViewControllerAnimated:YES];
         }];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView;
{
    if (_followLogText.text.length > 0)
    {
        _rightButtonItem.enabled = YES;
    }
    else
    {
        _rightButtonItem.enabled = NO;
    }
}

@end
