//
//  VoteToAddViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-31.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "VoteToAddViewController.h"
#import "EBListView.h"
#import "EBHttpClient.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "UIImage+Alpha.h"
#import "EBPreferences.h"
#import "EBAlert.h"

@interface VoteToAddViewController ()
{
    EBListView *_listView;
    UIView *_headerView;
    UIBarButtonItem *_addCandidateButton;
    UITextField *_nameTextField;
    UITextField *_urlTextField;
}

@end

@implementation VoteToAddViewController

- (void)loadView
{
    [super loadView];
    self.title = _voteType == EVoteTypeAddPort ? NSLocalizedString(@"vote_to_add_publish_port", nil) : NSLocalizedString(@"vote_to_add_gather_source", nil);
    _addCandidateButton = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"vote_add_candidate", nil)
                                                target:self action:@selector(addCandidate:)];
    
    _listView = [[EBListView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    EBVoteDataSource *ds = [[EBVoteDataSource alloc] init];
    ds.voteBlock = ^{
        [_listView.tableView reloadData];
    };
    _listView.emptyText = _voteType == EVoteTypeAddPort ? NSLocalizedString(@"empty_candidate_publish_port", nil) : NSLocalizedString(@"empty_candidate_gather_source", nil);
    ds.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id))
    {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:params];
        temp[@"type"] = _voteType == EVoteTypeAddPort ? @1 : @0;
        [[EBHttpClient sharedInstance] gatherPublishRequest:temp portProposalList:^(BOOL success, id result)
         {
             done(success, result);
         }];
    };
    _listView.dataSource = ds;
    [self.view addSubview:_listView];
    [_listView startLoading];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UIAction Method

- (void)addCandidate:(id)sender
{
    NSString *title = _voteType == EVoteTypeAddPort ? NSLocalizedString(@"alert_publish_port_title", nil): NSLocalizedString(@"alert_add_source_title", nil);
    [self showCustomCondtionAlertView:title];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if ([_nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            [EBAlert alertError:_voteType == EVoteTypeAddPort ? NSLocalizedString(@"alert_publish_port_name", nil) : NSLocalizedString(@"alert_add_source_name", nil)];
            return;
        }
        else if ([_urlTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            [EBAlert alertError:_voteType == EVoteTypeAddPort ? NSLocalizedString(@"alert_publish_port_website", nil) : NSLocalizedString(@"alert_add_source_website", nil)];
            return;
        }
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        params[@"name"] = _nameTextField.text;
        params[@"url"] = _urlTextField.text;
        params[@"type"] = _voteType == EVoteTypeAddPort ? @1 : @0;
        params[@"company_name"] = [EBPreferences sharedInstance].companyName;
        
        [[EBHttpClient sharedInstance] gatherPublishRequest:params portAddProposal:^(BOOL success, id result)
         {
             if (success)
             {
                 [_listView refreshList:YES];
             }
         }];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        _nameTextField = [alertView textFieldAtIndex:0];
        _urlTextField = [alertView textFieldAtIndex:1];
        [_urlTextField setSecureTextEntry:NO];
    }
    _urlTextField.keyboardType = UIKeyboardTypeURL;
    
    if (_voteType == EVoteTypeAddSource)
    {
        _nameTextField.placeholder = NSLocalizedString(@"alert_add_source_hint_name", nil);
        _urlTextField.placeholder = NSLocalizedString(@"alert_add_source_hint_website", nil);
    }
    else if(_voteType == EVoteTypeAddPort)
    {
        _nameTextField.placeholder = NSLocalizedString(@"alert_publish_port_hint_name", nil);
        _urlTextField.placeholder = NSLocalizedString(@"alert_publish_port_hint_website", nil);
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    [_nameTextField becomeFirstResponder];
}

#pragma mark - Private Method

- (void)showCustomCondtionAlertView:(NSString *)title
{
    NSString *temp = nil;
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (temp == nil) {
            temp = @"";
        }
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:temp message:title delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") otherButtonTitles:NSLocalizedString(@"title_add", @"add"), nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        UIView *view = [self alertViewCustomInputViewForSysEight];
        [alertView setValue:view forKey:@"accessoryView"];
    }
    else if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
//        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        UIView *view = [self alertViewCustomInputView];
        [alertView setValue:view forKey:@"accessoryView"];
    }
    else
    {
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    }
    [alertView show];
}

- (UIView *)alertViewCustomInputView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15.0, 0.0, 240.0, 60.5)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0, 0.0, 232, 30)];
    _nameTextField.font = _urlTextField.font = [UIFont systemFontOfSize:13.0];
    _urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0, 30.5, 232, 30)];
    _urlTextField.font = [UIFont systemFontOfSize:13.0];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 30.0, 240.0, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    
    [view addSubview:_nameTextField];
    [view addSubview:lineView];
    [view addSubview:_urlTextField];
    return view;
}

- (UIView *)alertViewCustomInputViewForSysEight
{
    UIView *groundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 80.5)];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15.0, 0.0, 240.0, 60.5)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0, 0.0, 232, 30)];
    _nameTextField.font = _urlTextField.font = [UIFont systemFontOfSize:13.0];
    _urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0, 30.5, 232, 30)];
    _urlTextField.font = [UIFont systemFontOfSize:13.0];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 30.0, 240.0, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    
    [view addSubview:_nameTextField];
    [view addSubview:lineView];
    [view addSubview:_urlTextField];
    
    [groundView addSubview:view];
    return groundView;
}

@end


@implementation EBVote

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"voteCount": @"vote_count",
    };
}

@end

@interface EBVoteDataSource()
{
    UIView *_headerView;
}
@end

@implementation EBVoteDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
    return 48.0;
}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    NSString *cellIdentifier= @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:48.0 leftMargin:0.0]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 10.0, 135.0, 18.0)];
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:16.0];
        label.tag = 66;
        [cell.contentView addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 28.0, 135.0, 14.0)];
        label.textColor = [EBStyle grayTextColor];
        label.font = [UIFont systemFontOfSize:12.0];
        label.tag = 77;
        [cell.contentView addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(150.0, 15.0, 60.0, 20.0)];
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 88;
        [cell.contentView addSubview:label];
        
        UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(255.0, 10.0, 50.0, 25.0) title:@"+1" target:self action:@selector(toggleVote:)];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        indicator.center = CGPointMake(25.0, 12.5);
        indicator.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
        indicator.hidesWhenStopped = YES;
        [btn addSubview:indicator];
        [cell.contentView addSubview:btn];
        
    }
    EBVote *vote = self.dataArray[row];
    if (vote)
    {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:66];
        label.text = vote.name;
        label = (UILabel *)[cell.contentView viewWithTag:77];
        label.text = vote.url;
        label = (UILabel *)[cell.contentView viewWithTag:88];
        label.text = vote.voteCount;
        
        for (UIView *view in cell.contentView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn = (UIButton *)view;
                btn.tag = 1000 + row;
                btn.enabled = !vote.voted;
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    [self buildHeaderView];
    return _headerView;
}

- (void)buildHeaderView
{
    if (_headerView == nil)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], 24.0)];
        _headerView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, 135.0, 24.0)];
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:12.0];
        label.text = NSLocalizedString(@"vote_gather_source_name", nil);
        [_headerView addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(150.0, 0.0, 60.0, 24.0)];
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"vote_gather_source_numbers", nil);
        [_headerView addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(255.0, 0.0, 50.0, 24.0)];
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"vote_gather_source_vote", nil);
        [_headerView addSubview:label];
        [_headerView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:24.0 leftMargin:0.0]];
    }
}

- (void)toggleVote:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    UIActivityIndicatorView *indicator = nil;
    for (UIView *view in btn.subviews)
    {
        if ([view isKindOfClass:[UIActivityIndicatorView class]])
        {
            indicator = (UIActivityIndicatorView *)view;
        }
    }
    NSInteger row = btn.tag - 1000;
    EBVote *vote = self.dataArray[row];
    NSString *portId = vote.id;
    if (portId.length > 0)
    {
        if (indicator)
        {
            [indicator startAnimating];
            [btn setTitle:nil forState:UIControlStateNormal];
        }
        [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"port_id":portId, @"company_name":[EBPreferences sharedInstance].companyName} portToggleVote:^(BOOL success, id result)
         {
             if (indicator)
             {
                 [indicator stopAnimating];
                 [btn setTitle:@"+1" forState:UIControlStateNormal];
             }
             if (success)
             {
                 vote.voted = !vote.voted;
                 vote.voteCount = [NSString stringWithFormat:@"%ld", vote.voteCount.integerValue + (vote.voted ? 1 : -1)];
                 btn.enabled = !vote.voted;
                 if (self.voteBlock)
                 {
                     self.voteBlock();
                 }
             }
         }];
    }
}

@end
