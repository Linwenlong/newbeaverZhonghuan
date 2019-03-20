//
//  ChangeStatusViewController.m
//  beaver
// 修改房源的状态
//  Created by ChenYing on 14-7-24.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ChangeStatusViewController.h"
#import "EBStyle.h"
#import "EBRadioGroup.h"
#import "SZTextView.h"
#import "EBCompatibility.h"
#import "EBViewFactory.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
#import "EBTimeFormatter.h"
#import "EBAlert.h"
#import "EBHttpClient.h"
#import "EBFilter.h"

@interface ChangeStatusViewController ()
{
    UITableView *_tableView;
    UITextView *_reasonTextView;
    UIView *_rentExpirationTimeView;
    UIView *_validView;
    UIView *_belongView;
    UIView *_reasonView;
    RTLabel *_dataLabel;
    UIView *_line;
    CGFloat _preHeight;
    UIView *_dateView;
    NSMutableArray *_validArray;
    NSArray *_belongArray;
    NSString *_status;
    NSInteger _public; //0---私盘   1---公盘
    NSInteger _close_date;
    
    BOOL _hasChanged;
    UIBarButtonItem *_saveButton;
}

@end

@implementation ChangeStatusViewController

- (void)loadView
{
    [super loadView];
//    operation_modify_status 变更状态
    NSString *title = NSLocalizedString(@"operation_modify_status", nil);
    self.navigationItem.title = title;
    
    _saveButton = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil) target:self action:@selector(saveStatus:)];
    
//    _status = _isClient ? _client.changeStatus : _house.status;
    [self belongView];
    [self rentExpirationTimeView];
    [self reasonView];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([EBCompatibility isIOS7Higher])
    {
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    _tableView.clipsToBounds = NO;
    [self.view addSubview:_tableView];
    [self setupDatePickerView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkSaveButtonEnable];
    [self getValidStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (BOOL)shouldPopOnBack
{
    if (_reasonTextView.text.length > 0 || _hasChanged)
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"alert_save_change_tag", nil)
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            if (_validView == nil)
            {
                return 26.0 + 30.0 + 30;
            }
            else
            {
                return _validView.frame.size.height;
            }
        case 1:
            if ([_status isEqualToString:NSLocalizedString(@"house_status_valid", nil)])
            {
                return 26.0 + 30.0 + 30;
            }
            else
            {
                return 0.0;
            }
            
        case 2:
            //realize it later
//            if ([_status isEqualToString:NSLocalizedString(@"house_status_other_rent", nil)])
//            {
//                return 45.0;
//            }
//            else
//            {
//                return 0.0;
//            }
            return 0.0;
        case 3:
            return _reasonView.frame.size.height;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.clipsToBounds = YES;
        cell.clipsToBounds = YES;
    }
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    switch (indexPath.row) {
        case 0:
            [cell.contentView addSubview:[self validView]];
            break;
        case 1:
            [cell.contentView addSubview:_belongView];
            break;
        case 2:
            [cell.contentView addSubview:_rentExpirationTimeView];
            break;
        case 3:
            [cell.contentView addSubview:_reasonView];
            break;
            
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 2)
//    {
//        [_reasonTextView resignFirstResponder];
//        [UIView animateWithDuration:0.5 animations:^
//         {
//             CGRect frame = [EBStyle fullScrTableFrame:NO];
//             _dateView.frame = CGRectMake(0, frame.size.height - 250, 320, 260);
//         }];
//    }
//    else
    if (indexPath.row == 3)
    {
        [_reasonTextView becomeFirstResponder];
        [self dismissDatePicker:nil];
    }
}

#pragma mark - Cell View
- (UIView *)validView
{
    if (_validView == nil)
    {
        _validView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        for (UIView *view in _validView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    
    CGFloat yOffset = 15.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 22.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [EBStyle blackTextColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.text = NSLocalizedString(@"validity_title", nil);
    [_validView addSubview:titleLabel];
    yOffset += titleLabel.frame.size.height + 8.0;
    
    EBRadioGroup *radioGroup = [[EBRadioGroup alloc] initWithFrame:CGRectMake(20.0, yOffset, 290.0, 26.0)];
    radioGroup.radios = [self getRadiosArray:_validArray];
    if (_validArray.count > 0)
    {
        _status = _validArray[0];
    }
    radioGroup.checkBlock = ^(NSInteger checked){
        _hasChanged = YES;
        if (![_status isEqualToString:_validArray[checked]])
        {
            NSString *tempStatus = _status;
            _status = _validArray[checked];
            if ([_status isEqualToString:NSLocalizedString(@"house_status_valid", nil)] || [tempStatus isEqualToString:NSLocalizedString(@"house_status_valid", nil)])
            {
                [_tableView beginUpdates];
//                [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [_tableView endUpdates];
            }

//            if ([_status isEqualToString:NSLocalizedString(@"house_status_other_rent", nil)] || [tempStatus isEqualToString:NSLocalizedString(@"house_status_other_rent", nil)] )
//            {
//                [_tableView beginUpdates];
//                [_tableView endUpdates];
//                [self checkSaveButtonEnable];
//            }
        }
    };
    [_validView addSubview:radioGroup];
    yOffset += radioGroup.frame.size.height + 15;
    _validView.frame = CGRectMake(0.0, 0.0, [EBStyle screenWidth], yOffset);
    [self parentView:_validView addLine:yOffset - 0.5 leftMargin:15.0];
    [_validView setNeedsLayout];
    return _validView;
}
//"access_title"            = "归属";
- (UIView *)belongView
{
    _belongView = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat yOffset = 15.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 22.0)];
    titleLabel.text = NSLocalizedString(@"access_title", nil);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [EBStyle blackTextColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_belongView addSubview:titleLabel];
    yOffset += titleLabel.frame.size.height + 8.0;
    
    EBRadioGroup *radioGroup = [[EBRadioGroup alloc] initWithFrame:CGRectMake(20.0, yOffset, 290.0, 26.0)];
    _belongArray = @[NSLocalizedString(@"tag_can_access", nil), NSLocalizedString(@"tag_cannot_access", nil)];
    radioGroup.radios = [self getRadiosArray:_belongArray];
    radioGroup.checkBlock = ^(NSInteger checked){
        _hasChanged = YES;
        _public = checked == 0 ? 1 : 0;
    };
    if (_isClient)
    {
        radioGroup.selectedIndex = _client.access == EClientAccessTypePrivate ? 1 : 0;
        _public = _client.access == EClientAccessTypePrivate ? 0 : 1;
    }
    else
    {
        radioGroup.selectedIndex = _house.access == EHouseAccessTypePrivate ? 1 : 0;
        _public = _house.access == EHouseAccessTypePrivate ? 0 : 1;
    }
    
    [_belongView addSubview:radioGroup];
    yOffset += radioGroup.frame.size.height + 15.0;
    _belongView.frame = CGRectMake(0.0, 0.0, [EBStyle screenWidth], yOffset);
    [self parentView:_belongView addLine:yOffset - 0.5 leftMargin:15.0];
    [_belongView setNeedsLayout];
    return _belongView;
}

//"rent_expiration_title"   = "租期截止日期";
- (UIView *)rentExpirationTimeView
{
    _rentExpirationTimeView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], 45.0)];
    CGFloat yOffset = 15.0;
    
    RTLabel *rtLabel = [[RTLabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 110.0, 24.0)];
    rtLabel.text = NSLocalizedString(@"rent_expiration_title", nil);
    rtLabel.backgroundColor = [UIColor clearColor];
    rtLabel.textColor = [EBStyle blackTextColor];
    rtLabel.font = [UIFont systemFontOfSize:14.0];
    [_rentExpirationTimeView addSubview:rtLabel];
    
    UIView *seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(rtLabel.frame.origin.x + rtLabel.frame.size.width, yOffset - 4.0, 0.5, 28.0 + 5.0)];
    seperatorLine.backgroundColor = [EBStyle grayClickLineColor];
    [_rentExpirationTimeView addSubview:seperatorLine];
    
    _dataLabel = [[RTLabel alloc] initWithFrame:CGRectMake(seperatorLine.frame.origin.x + 15.0, yOffset, 180.0, 24.0)];
    _dataLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rent_expiration_time", nil),NSLocalizedString(@"select_data_hint", nil)];
    _dataLabel.backgroundColor = [UIColor clearColor];
    _dataLabel.linkAttributes = @{@"color":@"#a8a9aa"};
    _dataLabel.selectedLinkAttributes = @{@"color":@"#a8a9aa44"};
    _dataLabel.font = [UIFont systemFontOfSize:14.0];
    _dataLabel.delegate = self;
    [_rentExpirationTimeView addSubview:_dataLabel];
    yOffset += _dataLabel.frame.size.height + 5.0;
    
    seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(15.0, yOffset, 305.0, 0.5)];
    seperatorLine.backgroundColor = [EBStyle grayClickLineColor];
    [_rentExpirationTimeView addSubview:seperatorLine];
    [_rentExpirationTimeView setNeedsLayout];
    return _rentExpirationTimeView;
}

- (UIView *)reasonView
{
    _reasonView = [[UIView alloc] initWithFrame:CGRectZero];
    
    CGFloat yOffset = 35.0;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 22.0)];
//    "change_status_reason"    = "变更状态原因";
    titleLabel.text = NSLocalizedString(@"change_status_reason", nil);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [EBStyle blackTextColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_reasonView addSubview:titleLabel];
    yOffset += titleLabel.frame.size.height;
    
    _reasonTextView = [[UITextView alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 40.0)];
    _reasonTextView.bounces = NO;
    _reasonTextView.textColor = [EBStyle blackTextColor];
    _reasonTextView.font = [UIFont systemFontOfSize:14.0];
    _reasonTextView.delegate = self;
    [_reasonView addSubview:_reasonTextView];
    yOffset += _reasonTextView.frame.size.height + 20;
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(15.0, yOffset - 0.5, 305.0, 0.5)];
    _line.backgroundColor = [EBStyle grayClickLineColor];
    [_reasonView addSubview:_line];
    _reasonView.frame = CGRectMake(0.0, 0.0, [EBStyle screenWidth], yOffset + 15);
    [_reasonView setNeedsLayout];
    
    return _reasonView;
}

#pragma mark - Action Method

- (void)saveStatus:(id)sender
{
    [_reasonTextView resignFirstResponder];
    [self dismissDatePicker:nil];
    NSString *reason = _reasonTextView.text;
    if (reason == nil || [reason stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
//        alert_input_status_reason"   = "请填写“变更状态原因”";
        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"alert_input_status_reason", nil)];
    }
    else
    {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        parameters[@"status"] = _status == nil ? @"" : _status;
        parameters[@"reason"] = reason;
//        parameters[@"public"] = _public == 0 ? @0 : @1;
        parameters[@"access"] = _public == 0 ? @"private" : @"public";
        parameters[@"close_date"] = [NSString stringWithFormat:@"%ld",_close_date];
        if (_isClient)
        {
            parameters[@"client_id"] = _client.id;
            parameters[@"type"] = [EBFilter typeString:_client.rentalState];
            [[EBHttpClient sharedInstance] clientRequest:parameters changeStatus:^(BOOL success, id result) {
                if (success)
                {
                    [EBAlert alertSuccess:nil length:1.0 allowUserInteraction:NO];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }];
        }
        else
        {
            parameters[@"house_id"] = _house.id;
            parameters[@"type"] = [EBFilter typeString:_house.rentalState];
            [[EBHttpClient sharedInstance] houseRequest:parameters changeStatus:^(BOOL success, id result) {
                if (success)
                {
                    [EBAlert alertSuccess:nil length:1.0 allowUserInteraction:NO];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
            }];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![EBCompatibility isIOS7Higher])
    {
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
        if (translation.y > 30.0)
        {
            [_reasonTextView resignFirstResponder];
        }
        
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self dismissDatePicker:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self checkSaveButtonEnable];
    CGFloat height = _reasonTextView.contentSize.height;
    if (height > 40 && fabs(height - _preHeight) >= 15)
    {
        CGRect frame = _reasonTextView.frame;
        frame.size.height = height ; //Give it some padding
        _reasonTextView.frame = frame;
        frame = _line.frame;
        frame.origin.y = _reasonTextView.frame.origin.y + _reasonTextView.frame.size.height + 20;
        _line.frame = frame;
        frame = _reasonView.frame;
        frame.size.height = _line.frame.origin.y + _line.frame.size.height + 20;
        _reasonView.frame = frame;
        [_tableView beginUpdates];
        [_tableView endUpdates];
        _preHeight = height;
    }
}

#pragma mark - RTLabelDelegate

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    [_reasonTextView resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^
     {
         CGRect frame = [EBStyle fullScrTableFrame:NO];
         _dateView.frame = CGRectMake(0, frame.size.height - 250, [EBStyle screenWidth], 260);
     }];
}

#pragma mark - Notification Method

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    NSString *durationStr = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSString *curveStr = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:durationStr.floatValue];
    [UIView setAnimationCurve:curveStr.intValue];
    CGRect frame = _tableView.frame;
    frame.size.height = self.view.bounds.size.height - keyboardBounds.size.height;
    _tableView.frame = frame;
    [self scrollToBottom];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
//    _scrollView.frame = self.view.bounds;
    _tableView.frame = self.view.bounds;
}

#pragma mark - Private Method

- (void)getValidStatus
{
    if (_isClient)
    {
        [[EBHttpClient sharedInstance] clientRequest:@{@"client_id":_client.id,@"type":[EBFilter typeString:_client.rentalState]}
                                        validStatus:^(BOOL success, id result)
         {
             if (success)
             {
                 if (_validArray == nil)
                 {
                     _validArray = [[NSMutableArray alloc] init];
                 }
                 else
                 {
                     [_validArray removeAllObjects];
                 }
                 [_validArray addObjectsFromArray:result[@"status"]];
//                 [_validArray insertObject:_client.changeStatus atIndex:0];
                 [self validView];
                 [_tableView beginUpdates];
                 [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],nil] withRowAnimation:UITableViewRowAnimationFade];
                 [_tableView endUpdates];
//                 [self buildContentView];
             }
         }];
    }
    else
    {
        [[EBHttpClient sharedInstance] houseRequest:@{@"house_id":_house.id,@"type":[EBFilter typeString:_house.rentalState]}
                                        validStatus:^(BOOL success, id result)
         {
             if (success)
             {
                 if (_validArray == nil)
                 {
                     _validArray = [[NSMutableArray alloc] init];
                 }
                 else
                 {
                     [_validArray removeAllObjects];
                 }
                 [_validArray addObjectsFromArray:result[@"status"]];
//               [_validArray insertObject:_house.status atIndex:0];
                 [self validView];
                 [_tableView beginUpdates];
                 [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],/*[NSIndexPath indexPathForRow:1 inSection:0],[NSIndexPath indexPathForRow:2 inSection:0],*/nil] withRowAnimation:UITableViewRowAnimationFade];
                 [_tableView endUpdates];
             }
         }];
    }
}

- (void)setupDatePickerView
{
    _dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 640, [EBStyle screenWidth], 300)];
    _dateView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 40)];
    label.backgroundColor = [UIColor colorWithRed:65/255.0 green:65/255.0 blue:70/255.0 alpha:1];
    [_dateView addSubview:label];
    
    UIButton *cancelBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 60, 40)];
    [cancelBt setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [_dateView addSubview:cancelBt];
    [cancelBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBt.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBt addTarget:self action:@selector(dismissDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *certainBt = [[UIButton alloc] initWithFrame:CGRectMake(250, 0, 60, 40)];
    [certainBt setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [certainBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    certainBt.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [certainBt addTarget:self action:@selector(confirmDatetime:) forControlEvents:UIControlEventTouchUpInside];
    [_dateView addSubview:certainBt];
    
    UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, [EBStyle screenWidth], 260)];
    pickerView.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    pickerView.datePickerMode = UIDatePickerModeDate;
    pickerView.tag = 301;
    NSInteger time = (NSInteger)NSDate.date.timeIntervalSince1970;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    [pickerView setDate:date];
    [_dateView addSubview:pickerView];
    [self.view addSubview:_dateView];
}

- (NSArray *)getRadiosArray:(NSArray *)radios
{
    if (radios == nil)
    {
        return nil;
    }
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:radios.count];
    for (int i = 0; i < radios.count; i++)
    {
        [array addObject:@{@"title": radios[i], @"value":@(i + 1)}];
    }
    return array;
}

- (void)scrollToBottom
{
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]
                      atScrollPosition:UITableViewScrollPositionNone animated:YES];
    
}

-(void)dismissDatePicker:(UIButton *)btn
{
    [UIView animateWithDuration:0.5 animations:^
     {
         CGRect frame = [EBStyle fullScrTableFrame:NO];
         _dateView.frame = CGRectMake(0, frame.size.height, [EBStyle screenWidth], 260);
     }];
}

-(void)confirmDatetime:(UIButton *)btn
{
    [UIView animateWithDuration:0.5 animations:^
     {
         CGRect frame = [EBStyle fullScrTableFrame:NO];
         _dateView.frame = CGRectMake(0, frame.size.height, [EBStyle screenWidth], 260);
     }];
    UIDatePicker *datePicker = (UIDatePicker *)[_dateView viewWithTag:301];
    _close_date = (NSInteger)datePicker.date.timeIntervalSince1970;
    _dataLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rent_expiration_time", nil), [EBTimeFormatter formatRentExpirationTime:_close_date]];
    _dataLabel.linkAttributes = @{@"color":@"#197add"};
    _dataLabel.selectedLinkAttributes = @{@"color":@"#197add44"};
    _hasChanged = YES;
    [self checkSaveButtonEnable];
}

- (void)parentView:(UIView *)parent addLine:(CGFloat)yOffset leftMargin:(CGFloat)leftMargin
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, yOffset, [EBStyle screenWidth] - leftMargin, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [parent addSubview:line];
}

- (void)checkSaveButtonEnable
{
    if ([_reasonTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        _saveButton.enabled = YES;
    }
    else
    {
        _saveButton.enabled = NO;
    }
}

@end
