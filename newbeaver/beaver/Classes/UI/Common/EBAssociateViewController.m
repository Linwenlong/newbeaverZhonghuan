//
//  EBAssociateViewController.m
//  beaver
//
//  Created by wangyuliang on 14-7-30.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBAssociateViewController.h"
#import "EBViewFactory.h"
#import "EBFilter.h"
#import "EBController.h"
#import "EBHttpClient.h"

@interface EBAssociateTextField : UITextField
{
    
}

@end

@interface EBAssociateViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
    EBAssociateTextField *_keywordTextField;
    UITableView *_tableView;
    EBFilter *_filter;
    UILabel *_districtLabel;
    NSArray *_districtArray;
    UILabel *_resultLabel;
}

@end

@implementation EBAssociateViewController

- (void)loadView
{
    [super loadView];
    
    _filter = [[EBFilter alloc] init];
    _districtArray = nil;
    
    CGFloat yOffset = 0.0;
    
    UIView *statusBarBg = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 20)];
    statusBarBg.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarBg];
    
    CGRect Frame = [EBStyle fullScrTableFrame:NO];
    _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Frame.size.height / 2 - 10, [EBStyle screenWidth], 20)];
    _resultLabel.textAlignment = NSTextAlignmentCenter;
    _resultLabel.font = [UIFont systemFontOfSize:14.0];
    _resultLabel.textColor = [EBStyle grayTextColor];
    _resultLabel.text = NSLocalizedString(@"associate_search_empty", nil);
    [self.view addSubview:_resultLabel];
    _resultLabel.hidden = YES;
    
    [self setupTextEditBar];
    [self setupTableView];
}

- (void)setupTextEditBar
{
    CGFloat yOffset = 20.0;
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 88)];
//    navBar.backgroundColor = [UIColor colorWithWhite:248/255.0f alpha:1.0];
    
    _keywordTextField = [[EBAssociateTextField alloc] initWithFrame:CGRectMake(54, 7, 255, 30)];
    _keywordTextField.backgroundColor = [UIColor colorWithWhite:222/255.0f alpha:1.0];
    _keywordTextField.layer.cornerRadius = 4.0f;
    _keywordTextField.placeholder = NSLocalizedString(@"search_subregion", nil);
    _keywordTextField.clearButtonMode = UITextFieldViewModeAlways;
    _keywordTextField.enablesReturnKeyAutomatically = YES;
    [navBar addSubview:_keywordTextField];
    _keywordTextField.delegate = self;
    _keywordTextField.returnKeyType = UIReturnKeyDone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keywordTextFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_keywordTextField];
    
    UIImageView *BackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"associate_back"]];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 44)];
    BackView.frame = CGRectOffset(BackView.frame, 10, 22 - BackView.frame.size.height / 2);
    [cancelButton addSubview:BackView];
    [cancelButton addTarget:self action:@selector(cancelAssociate:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:cancelButton];
    
//    UIButton *districtBtn = [[UIButton alloc] initWithFrame:CGRectMake(7, 46, 306, 40)];
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
//    titleLabel.textAlignment = NSTextAlignmentLeft;
//    titleLabel.textColor = [EBStyle blackTextColor];
//    titleLabel.font = [UIFont systemFontOfSize:14.0];
//    titleLabel.text = NSLocalizedString(@"filter_district", nil);
//    [districtBtn addSubview:titleLabel];
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow"]];
//    imageView.frame = CGRectOffset(imageView.frame, 296 - imageView.frame.size.width , 20 - imageView.frame.size.height / 2);
//    [districtBtn addSubview:imageView];
    
    UIView *districtView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, [EBStyle screenWidth], 30)];
    districtView.backgroundColor = [UIColor colorWithRed:255/255.0 green:169/255.0 blue:34/255.0 alpha:1];
    
    _districtLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 296, 30)];
    _districtLabel.font = [UIFont systemFontOfSize:14.0];
    _districtLabel.textColor = [UIColor whiteColor];
    _districtLabel.textAlignment = NSTextAlignmentLeft;
    if (_district&&_district.length > 0)
    {
        if (_region && _region.length > 0)
        {
            _districtLabel.text = [NSString stringWithFormat:@"区域：%@-%@", _district, _region];
        }
        else
        {
            _districtLabel.text = [NSString stringWithFormat:@"区域：%@",_district];
        }
    }
    else
    {
        _districtLabel.text = @"区域：不限";
    }
    [districtView addSubview:_districtLabel];
    
//    [districtBtn addTarget:self action:@selector(selectDistrict:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:districtView];
    
    [self.view addSubview:navBar];
}

- (void)cancelAssociate:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)selectDistrict:(UIButton*)btn
{
    NSInteger rChoice,lChoice=0;
    lChoice = _filter.district1;
    rChoice = _filter.district2;
    
    NSArray *choices = [_filter choicesByIndex:0];
    if (choices)
    {
        [[EBController sharedInstance] promptChoices:choices withRightChoice:rChoice leftChoice:lChoice title:NSLocalizedString(@"filter_district", nil)
                                           houseType:_filter.requireOrRentalType
                                          completion:^(NSInteger rightChoice, NSInteger leftChoice)
         {
             _filter.district1 = leftChoice;
             _filter.district2 = rightChoice;
//             [_tableView reloadData];
             NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
             NSString *title = district1[@"title"];
             if (_filter.district2 > 0)
             {
                 title = [title stringByAppendingFormat:@" %@", district1[@"children"][_filter.district2]];
             }
             _districtLabel.text = title;
         }];
    }
}

- (void)setupTableView
{
    CGRect tableFrame = [EBStyle fullScrTableFrame:NO];
    
    tableFrame.size.height -= 30;
    tableFrame.origin.y += 95;
    
    _tableView = [[UITableView alloc] initWithFrame:tableFrame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self communityAssociate];
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_keywordTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (_districtArray)
    {
        EBCommunity *community = (EBCommunity *)_districtArray[row];
        if (self.handleSelection)
        {
            NSString *district, *region;
            if (_filter.district1 != 0)
            {
                NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
                NSLog(@"district1=%@",district1);
                district = district1[@"title"];
                if (_filter.district2 != 0)
                {
                    region = district1[@"children"][_filter.district2];
                }
                else
                {
                    region = @"";
                }
            }
            else
            {
                district = @"";
                region = @"";
            }
            self.handleSelection(district, region, community);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_keywordTextField resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_districtArray)
        return _districtArray.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSString *identifier = @"associateCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UIView *line = [EBViewFactory defaultTableViewSeparator];
        line.backgroundColor = [EBStyle blackTextColor];
        [cell addSubview:line];
        cell.textLabel.textColor = [EBStyle blackTextColor];
        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, 300, 18)];
        textLabel.tag = 101;
        textLabel.textColor = [EBStyle blackTextColor];
        textLabel.font = [UIFont systemFontOfSize:14.0];
        textLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:textLabel];
    }
    
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:101];
    if (_districtArray && (row < _districtArray.count))
    {
        EBCommunity *community = (EBCommunity *)_districtArray[row];
        textLabel.text = community.community;
    }
    
    return cell;
}

//LWL请求小区信息
- (void)communityAssociate
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"keyword"] = _keywordTextField.text;
    if (_district && _district.length > 0)
    {
        params[@"district"] = _district;
        if (_region && _region.length > 0)
        {
            params[@"region"] = _region;
        }
        else
        {
            params[@"region"] = @"";
        }
    }
    else
    {
        if (_filter.district1 != 0)
        {
            NSDictionary *district1 = [EBFilter rawDistrictChoices][_filter.district1];
            params[@"district"] = district1[@"title"];
            if (_filter.district2 != 0)
            {
                params[@"region"] = district1[@"children"][_filter.district2];
            }
            else
            {
                params[@"region"] = @"";
            }
        }
        else
        {
            params[@"district"] = @"";
            params[@"region"] = @"";
        }
    }
    NSLog(@"params=%@",params);
    [[EBHttpClient sharedInstance] houseRequest:params communityAssociate:^(BOOL success, id result) {
        NSLog(@"result=%@",result);
        if (!success) {
            return;
        }
        
        _districtArray = (NSArray*)result;
        if (_districtArray.count > 0)
        {
            _resultLabel.hidden = YES;
            [self.view sendSubviewToBack:_resultLabel];
        }
        else
        {
            _resultLabel.hidden = NO;
            [self.view bringSubviewToFront:_resultLabel];
        }
        [_tableView reloadData];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //    [_tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_keywordTextField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [_tableView reloadData];
    return YES;
}

#pragma mark - Associate
- (void)keywordTextFieldTextChanged:(id)sender
{
    [self communityAssociate];
//    [_tableView reloadData];
}

@end

@implementation EBAssociateTextField

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 5.0, 3.0);
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 5.0, 3.0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 5.0, 3.0);
}

@end


